import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/domain/algorithms/algorithm_names.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';

import 'api_client.dart';
import 'what_to_mine_api_keys.dart';

class WhatToMineException implements Exception {
  final String messageKey;
  final int? statusCode;

  const WhatToMineException(this.messageKey, {this.statusCode});

  @override
  String toString() => messageKey.tr();
}

class WhatToMineClient implements ApiClient {
  static const minimumRefreshInterval = Duration(minutes: 1);
  static const calculationTtl = Duration(hours: 2);
  static const coinsTtl = Duration(hours: 24);
  static const catalogTtl = Duration(days: 7);
  static const algorithmsTtl = Duration(days: 30);
  static const _baseUrl = 'https://whattomine.com/api/v1';

  final http.Client _client;
  final SharedPreferences _preferences;
  final DateTime Function() _now;
  final String? _configuredApiKey;
  final List<String>? _configuredApiKeys;
  final Map<String, Future<List<Map<String, dynamic>>>> _inFlight = {};
  Future<void> _networkQueue = Future.value();

  WhatToMineClient({
    required this._preferences,
    http.Client? client,
    DateTime Function()? now,
    String? apiKey,
    List<String>? apiKeys,
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now,
       _configuredApiKey = apiKey,
       _configuredApiKeys = apiKeys == null ? null : List.of(apiKeys);

  // Quotas and responses retain their old per-token hashed namespaces. A pool
  // can reuse a fresh response from any of its tokens, including after adding
  // a backup key. Removing every previous token cannot expose its cached data.
  late final List<String> _apiKeys = _readApiKeys();
  late final List<String> _namespaces = _apiKeys
      .map((key) => 'wtm.v1.${sha256.convert(utf8.encode(key))}')
      .toList();
  late final String _selectionKey = _poolSelectionKey();

  List<String> _readApiKeys() {
    try {
      if (_configuredApiKeys != null) {
        return normalizeWhatToMineApiKeys(_configuredApiKeys);
      }
      if (_configuredApiKey != null) {
        return normalizeWhatToMineApiKeys([_configuredApiKey]);
      }
      const keys = String.fromEnvironment('WHAT_TO_MINE_API_KEYS');
      return keys.trim().isNotEmpty
          ? parseWhatToMineApiKeys(keys)
          : normalizeWhatToMineApiKeys([
              const String.fromEnvironment('WHAT_TO_MINE_API_KEY'),
            ]);
    } on FormatException {
      throw const WhatToMineException('error_wtm_api_keys_config');
    }
  }

  String _poolSelectionKey() {
    final sorted = [..._namespaces]..sort();
    return 'wtm.pool.v1.${sha256.convert(utf8.encode(jsonEncode(sorted)))}.active';
  }

  int get _preferredIndex {
    final index = _namespaces.indexOf(
      _preferences.getString(_selectionKey) ?? '',
    );
    return index < 0 ? 0 : index;
  }

  // Retained for single-key callers; this is the most recently selected token.
  String get apiKey => _apiKeys.isEmpty ? '' : _apiKeys[_preferredIndex];

  Map<String, dynamic>? get rateLimit {
    if (_apiKeys.isEmpty) return null;
    final stored = _preferences.getString(
      '${_namespaces[_preferredIndex]}.usage',
    );
    if (stored == null) return null;
    try {
      return jsonDecode(stored) as Map<String, dynamic>;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesListFromApi({
    bool forceRefresh = false,
  }) async {
    final coins = await _request('coins', coinsTtl, forceRefresh: forceRefresh);
    return coins
        .where((coin) => coin['testing'] != true && coin['lagging'] != true)
        .map(_coin)
        .toList();
  }

  CryptoCurrency _coin(Map<String, dynamic> coin) {
    final exchanges = _objects(coin['exchanges'] ?? []);
    final priced =
        exchanges.where((exchange) => _number(exchange['price']) > 0).toList()
          ..sort(
            (a, b) => _number(b['volume']).compareTo(_number(a['volume'])),
          );
    return CryptoCurrency(
      id: _text(coin['id']),
      coin: _text(coin['tag']),
      name: _text(coin['name']),
      type: 'coin',
      algorithm: _text(coin['algorithm']),
      // Exchange rates and volumes are quoted in BTC, unlike calculate's USD
      // revenue/profit. Keep the unit explicit throughout the UI.
      price: priced.isEmpty ? -1 : _number(priced.first['price']),
      quoteCurrency: 'BTC',
      reward: -1,
      rewardUnit: _text(coin['tag']),
      networkHashrate: _number(coin['nethash']),
      volume: exchanges.fold(
        0,
        (total, exchange) => total + _number(exchange['volume']),
      ),
    );
  }

  // /coins already supplies the calculation parameter for each active
  // algorithm. Only fetch /algorithms when that metadata is incomplete.
  Future<List<Map<String, dynamic>>> _algorithmRegistry() async {
    final coins = await _request('coins', coinsTtl);
    final registry = <String, Map<String, dynamic>>{};
    var incomplete = coins.isEmpty;
    for (final coin in coins) {
      final name = coin['algorithm'];
      final param = coin['algo_param_name'];
      if (name is! String ||
          name.isEmpty ||
          param is! String ||
          param.isEmpty) {
        incomplete = true;
        continue;
      }
      registry[algorithmKey(name)] = {'name': name, 'param_name': param};
    }
    if (incomplete) {
      final fallback = await _request('algorithms', algorithmsTtl);
      for (final algorithm in fallback) {
        registry.putIfAbsent(
          algorithmKey(_text(algorithm['name'])),
          () => algorithm,
        );
      }
    }
    return registry.values.toList();
  }

  static String gpuVendor(String name, [Object? manufacturer]) {
    final label = '${manufacturer ?? ''} $name'.toLowerCase();
    if (RegExp(
          r'\b(nvidia|nvidea|geforce|quadro|tesla|titan|cmp|rtx|gtx)\b',
        ).hasMatch(label) ||
        RegExp(r'\bp10[246]-').hasMatch(label)) {
      return 'nvidia';
    }
    if (RegExp(r'\b(amd|radeon|firepro|vega)\b').hasMatch(label) ||
        RegExp(r'\brx\s*\d').hasMatch(label)) {
      return 'amd';
    }
    if (RegExp(r'\b(intel|arc)\b').hasMatch(label)) return 'intel';
    return 'other';
  }

  @override
  Future<List<HashAlgorithm>> getHashAlgorithmsFromApi() async {
    final algorithms = await _algorithmRegistry();
    return algorithms
        .map(
          (algorithm) => HashAlgorithm(
            (builder) => builder
              ..name = _text(algorithm['name'])
              ..hashrate = 0
              ..hashrateCoefficient = 1
              ..power = 0,
          ),
        )
        .toList();
  }

  @override
  Future<List<Gpu>> getGPUListFromApi() async {
    final gpus = await _request('gpus', catalogTtl);
    return gpus.map((gpu) {
      final name = _text(gpu['name']);
      final vendor = gpuVendor(name, gpu['manufacturer'] ?? gpu['vendor']);
      final algorithms = _objects(gpu['algorithms'])
          .where(
            (algorithm) =>
                algorithm['hashrate'] != null && algorithm['power'] != null,
          )
          .map((algorithm) {
            final hashrate = _number(algorithm['hashrate']);
            final coefficient = hashCoefficient(hashrate);
            return HashAlgorithm(
              (builder) => builder
                ..name = _text(algorithm['name'])
                ..hashrate = hashrate / coefficient
                ..hashrateCoefficient = coefficient
                ..power = _number(algorithm['power']).round(),
            );
          });
      return Gpu(
        (builder) => builder
          // Do not collide with the numeric IDs in the old local catalog.
          ..id = 'wtm:gpu:${_text(gpu['id'])}'
          ..name = name
          ..marketingName = name
          ..vendor = vendor
          ..price = 0
          ..secondHand = false
          ..hashAlgorithms = ListBuilder(algorithms),
      );
    }).toList();
  }

  @override
  Future<List<Earnings>> calculateEarningsFromApi({
    required List<HashAlgorithm> algorithms,
    required double electricityCost,
    bool forceRefresh = false,
  }) async {
    final active = algorithms
        .where((algorithm) => (algorithm.hashrate ?? 0) > 0)
        .toList();
    if (active.isEmpty) return [];
    if (!electricityCost.isFinite || electricityCost < 0) {
      throw const WhatToMineException('error_wtm_invalid_settings');
    }
    final registry = await _algorithmRegistry();
    final params = {
      for (final algorithm in registry)
        algorithmKey(_text(algorithm['name'])): _text(algorithm['param_name']),
    };
    final settings = <String, Map<String, dynamic>>{};
    for (final algorithm in active) {
      final param = params[algorithmKey(algorithm.name)];
      // Saved GPUs may contain algorithms that the service no longer supports.
      if (param == null) continue;
      final hashrate = algorithm.hashrate! * algorithm.hashrateCoefficient;
      final power = algorithm.power;
      if (!hashrate.isFinite || power == null || power < 0) {
        throw const WhatToMineException('error_wtm_invalid_settings');
      }
      final setting = settings.putIfAbsent(
        param,
        () => {'algorithm': param, 'hashrate': 0.0, 'power': 0},
      );
      setting['hashrate'] = (setting['hashrate'] as double) + hashrate;
      setting['power'] = (setting['power'] as int) + power;
    }
    if (settings.isEmpty) {
      throw const WhatToMineException('error_wtm_unsupported_algorithms');
    }
    final sorted = settings.values.toList()
      ..sort(
        (a, b) =>
            (a['algorithm'] as String).compareTo(b['algorithm'] as String),
      );
    final coins = await getCryptoCurrenciesListFromApi();
    final byId = {for (final coin in coins) coin.id: coin};
    final results = await _request(
      'calculate',
      calculationTtl,
      forceRefresh: forceRefresh,
      body: {'cost': electricityCost, 'settings': sorted},
    );
    final earnings = <Earnings>[];
    for (final result in results) {
      final currency = byId[_text(result['id'])];
      if (currency == null) continue;
      earnings.add(
        Earnings.fromCalculation(
          currency: currency,
          dayEarningInCrypto: _requiredNumber(result, 'estimated_rewards'),
          dayEarningInCurrency: _requiredNumber(result, 'revenue'),
          netDayEarningInCurrency: _requiredNumber(result, 'profit'),
        ),
      );
    }
    return earnings;
  }

  Future<List<Map<String, dynamic>>> _request(
    String endpoint,
    Duration ttl, {
    bool forceRefresh = false,
    Map<String, dynamic>? body,
  }) async {
    if (_apiKeys.isEmpty) {
      throw const WhatToMineException('error_wtm_api_key');
    }
    // Background isolates may have written fresher responses or quota state.
    await _preferences.reload();
    final payload = body == null ? '' : jsonEncode(body);
    final requestKey = '$endpoint.${sha256.convert(utf8.encode(payload))}';
    final maxAge = forceRefresh ? minimumRefreshInterval : ttl;
    final cached = await _cachedResponse(requestKey, maxAge);
    if (cached != null) return cached;
    final existing = _inFlight[requestKey];
    if (existing != null) return existing;
    // Serialize actual HTTP requests within this client so concurrent endpoints
    // cannot all consume the same token's last known request before rotating.
    final future = _networkQueue.then(
      (_) => _perform(endpoint, requestKey, body, payload),
    );
    _networkQueue = future.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    _inFlight[requestKey] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(requestKey);
    }
  }

  Future<List<Map<String, dynamic>>?> _cachedResponse(
    String requestKey,
    Duration maxAge,
  ) async {
    List<Map<String, dynamic>>? result;
    int? newest;
    for (final namespace in _namespaces) {
      final key = '$namespace.$requestKey';
      final stored = _preferences.getString(key);
      if (stored == null) continue;
      try {
        final cached = jsonDecode(stored) as Map<String, dynamic>;
        final at = cached['at'] as int;
        final age = _now().difference(DateTime.fromMillisecondsSinceEpoch(at));
        if (!age.isNegative &&
            age < maxAge &&
            (newest == null || at > newest)) {
          result = _objects(cached['data']);
          newest = at;
        }
      } on FormatException {
        await _preferences.remove(key);
      } on TypeError {
        await _preferences.remove(key);
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _perform(
    String endpoint,
    String requestKey,
    Map<String, dynamic>? body,
    String payload,
  ) async {
    await _preferences.reload();
    final start = _preferredIndex;
    // Each token is considered at most once per logical request. Persisted
    // cooldowns are also respected after foreground/headless restarts.
    for (var offset = 0; offset < _apiKeys.length; offset++) {
      await _preferences.reload();
      final index = (start + offset) % _apiKeys.length;
      final namespace = _namespaces[index];
      final blockedUntil = _preferences.getInt('$namespace.blockedUntil');
      if (blockedUntil != null &&
          _now().millisecondsSinceEpoch < blockedUntil) {
        continue;
      }

      final response = await _send(endpoint, _apiKeys[index], body, payload);
      final usage = <String, dynamic>{'at': _now().toUtc().toIso8601String()};
      for (final name in ['limit', 'used', 'remaining']) {
        final value = int.tryParse(response.headers['x-ratelimit-$name'] ?? '');
        if (value != null) usage[name] = value;
      }
      if (usage.length > 1) {
        await _preferences.setString('$namespace.usage', jsonEncode(usage));
      }
      if (response.statusCode == 401) {
        throw const WhatToMineException('error_wtm_api_key', statusCode: 401);
      }
      if (response.statusCode == 403) {
        throw const WhatToMineException('error_wtm_access', statusCode: 403);
      }
      if (response.statusCode == 429) {
        await _blockToken(namespace, response);
        continue;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WhatToMineException(
          'error_wtm_service',
          statusCode: response.statusCode,
        );
      }
      await _preferences.setString(_selectionKey, namespace);
      // A successful last request remains valid. Rotate on the next request,
      // rather than asking another token for the same response again.
      final remaining = usage['remaining'] as int?;
      final limit = usage['limit'] as int?;
      final used = usage['used'] as int?;
      if (remaining != null
          ? remaining <= 0
          : limit != null && limit > 0 && used != null && used >= limit) {
        await _blockToken(namespace, response);
      }
      List<Map<String, dynamic>> data;
      try {
        data = _objects(jsonDecode(response.body));
      } on FormatException {
        throw const WhatToMineException('error_wtm_response');
      }
      await _preferences.setString(
        '$namespace.$requestKey',
        jsonEncode({'at': _now().millisecondsSinceEpoch, 'data': data}),
      );
      if (endpoint == 'calculate') {
        final keys = _preferences
            .getKeys()
            .where((entry) => entry.startsWith('$namespace.calculate.'))
            .toList();
        keys.sort((a, b) => _cacheTimestamp(b).compareTo(_cacheTimestamp(a)));
        for (final old in keys.skip(20)) {
          await _preferences.remove(old);
        }
      }
      return data;
    }
    throw const WhatToMineException('error_wtm_quota', statusCode: 429);
  }

  Future<http.Response> _send(
    String endpoint,
    String token,
    Map<String, dynamic>? body,
    String payload,
  ) async {
    final headers = {
      'Authorization': 'Token $token',
      'Accept': 'application/json',
    };
    final url = Uri.parse('$_baseUrl/$endpoint');
    if (kDebugMode) {
      debugPrint('WhatToMine API: ${body == null ? 'GET' : 'POST'} /$endpoint');
    }
    try {
      return await (body == null
              ? _client.get(url, headers: headers)
              : _client.post(
                  url,
                  headers: {...headers, 'Content-Type': 'application/json'},
                  body: payload,
                ))
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const WhatToMineException('error_wtm_network');
    } on http.ClientException {
      throw const WhatToMineException('error_wtm_network');
    }
  }

  Future<void> _blockToken(String namespace, http.Response response) async {
    // The service documents monthly limits but no reset timestamp. Honor an
    // HTTP Retry-After if supplied; otherwise recheck this token after a day.
    final retry = response.headers['retry-after'];
    final seconds = int.tryParse(retry ?? '');
    DateTime? retryDate;
    if (seconds == null && retry != null) {
      try {
        retryDate = HttpDate.parse(retry);
      } on HttpException {
        /* use fallback */
      }
    }
    final until = seconds != null && seconds > 0
        ? _now().add(Duration(seconds: seconds))
        : retryDate != null && retryDate.isAfter(_now())
        ? retryDate
        : _now().add(const Duration(days: 1));
    await _preferences.setInt(
      '$namespace.blockedUntil',
      until.millisecondsSinceEpoch,
    );
  }

  int _cacheTimestamp(String key) {
    try {
      return (jsonDecode(_preferences.getString(key)!)
              as Map<String, dynamic>)['at']
          as int;
    } catch (_) {
      return 0;
    }
  }

  static List<Map<String, dynamic>> _objects(Object? value) {
    if (value is! List || value.any((item) => item is! Map<String, dynamic>)) {
      throw const FormatException('Expected an array of objects');
    }
    return value.cast<Map<String, dynamic>>();
  }

  static String _text(Object? value) {
    if (value == null || value.toString().isEmpty) {
      throw const WhatToMineException('error_wtm_response');
    }
    return value.toString();
  }

  static double _number(Object? value) {
    if (value == null) return 0;
    final result = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());
    if (result == null || !result.isFinite) {
      throw const WhatToMineException('error_wtm_response');
    }
    return result;
  }

  static double _requiredNumber(Map<String, dynamic> row, String field) {
    if (row[field] == null) {
      throw const WhatToMineException('error_wtm_response');
    }
    return _number(row[field]);
  }
}
