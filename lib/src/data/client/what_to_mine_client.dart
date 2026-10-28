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
  final String apiKey;
  final Map<String, Future<List<Map<String, dynamic>>>> _inFlight = {};

  WhatToMineClient({
    required this._preferences,
    http.Client? client,
    DateTime Function()? now,
    this.apiKey = const String.fromEnvironment('WHAT_TO_MINE_API_KEY'),
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  // Cache namespaces use a hash, never the token itself. A new token has its
  // own cache and quota state; tokens are only sent in the Authorization header.
  String get _namespace => 'wtm.v1.${sha256.convert(utf8.encode(apiKey))}';

  Map<String, dynamic>? get rateLimit {
    final stored = _preferences.getString('$_namespace.usage');
    return stored == null ? null : jsonDecode(stored) as Map<String, dynamic>;
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
    if (apiKey.trim().isEmpty) {
      throw const WhatToMineException('error_wtm_api_key');
    }
    // Background isolates may have written a fresher response since this
    // instance last read the legacy SharedPreferences cache.
    await _preferences.reload();
    final payload = body == null ? '' : jsonEncode(body);
    final key = '$_namespace.$endpoint.${sha256.convert(utf8.encode(payload))}';
    final stored = _preferences.getString(key);
    if (stored != null) {
      try {
        final cached = jsonDecode(stored) as Map<String, dynamic>;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          cached['at'] as int,
        );
        final age = _now().difference(timestamp);
        if (!age.isNegative &&
            age < (forceRefresh ? minimumRefreshInterval : ttl)) {
          return _objects(cached['data']);
        }
      } on FormatException {
        await _preferences.remove(key);
      } on TypeError {
        await _preferences.remove(key);
      }
    }
    final existing = _inFlight[key];
    if (existing != null) return existing;
    final future = _perform(endpoint, key, body, payload);
    _inFlight[key] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<List<Map<String, dynamic>>> _perform(
    String endpoint,
    String key,
    Map<String, dynamic>? body,
    String payload,
  ) async {
    final blockedUntil = _preferences.getInt('$_namespace.blockedUntil');
    if (blockedUntil != null && _now().millisecondsSinceEpoch < blockedUntil) {
      throw const WhatToMineException('error_wtm_quota', statusCode: 429);
    }
    final headers = {
      'Authorization': 'Token ${apiKey.trim()}',
      'Accept': 'application/json',
    };
    final url = Uri.parse('$_baseUrl/$endpoint');
    http.Response response;
    if (kDebugMode) {
      debugPrint('WhatToMine API: ${body == null ? 'GET' : 'POST'} /$endpoint');
    }
    try {
      response =
          await (body == null
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
    final usage = <String, dynamic>{'at': _now().toUtc().toIso8601String()};
    for (final name in ['limit', 'used', 'remaining']) {
      final value = int.tryParse(response.headers['x-ratelimit-$name'] ?? '');
      if (value != null) usage[name] = value;
    }
    if (usage.length > 1) {
      await _preferences.setString('$_namespace.usage', jsonEncode(usage));
    }
    if (response.statusCode == 401) {
      throw WhatToMineException(
        'error_wtm_api_key',
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode == 403) {
      throw const WhatToMineException('error_wtm_access', statusCode: 403);
    }
    if (response.statusCode == 429) {
      // The monthly reset date is not documented. Honor Retry-After if given;
      // otherwise back off for a day, including after app/headless restarts.
      final retry = response.headers['retry-after'];
      final seconds = int.tryParse(retry ?? '');
      DateTime? retryDate;
      if (seconds == null && retry != null) {
        // HTTP dates are handled by the SDK without interpreting a billing cycle.
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
        '$_namespace.blockedUntil',
        until.millisecondsSinceEpoch,
      );
      throw const WhatToMineException('error_wtm_quota', statusCode: 429);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WhatToMineException(
        'error_wtm_service',
        statusCode: response.statusCode,
      );
    }
    List<Map<String, dynamic>> data;
    try {
      data = _objects(jsonDecode(response.body));
    } on FormatException {
      throw const WhatToMineException('error_wtm_response');
    }
    await _preferences.setString(
      key,
      jsonEncode({'at': _now().millisecondsSinceEpoch, 'data': data}),
    );
    // Bound the number of cached configurations; changes to a rig need a new
    // calculation, but old combinations should not accumulate indefinitely.
    if (endpoint == 'calculate') {
      final keys = _preferences
          .getKeys()
          .where((entry) => entry.startsWith('$_namespace.calculate.'))
          .toList();
      keys.sort((a, b) => _cacheTimestamp(b).compareTo(_cacheTimestamp(a)));
      for (final old in keys.skip(20)) {
        await _preferences.remove(old);
      }
    }
    return data;
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
