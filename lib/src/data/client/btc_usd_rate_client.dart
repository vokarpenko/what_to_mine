import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BtcUsdRateException implements Exception {
  const BtcUsdRateException();

  @override
  String toString() => 'error_btc_usd_rate'.tr();
}

// Public market data, independent of the authenticated WhatToMine quota.
class BtcUsdRateClient {
  static const cacheTtl = Duration(hours: 24);
  static const minimumRefreshInterval = Duration(minutes: 1);
  static const _cacheKey = 'coinbase.btc_usd.v1';

  final SharedPreferences _preferences;
  final http.Client _client;
  final DateTime Function() _now;
  Future<double>? _inFlight;

  BtcUsdRateClient({
    required this._preferences,
    http.Client? client,
    DateTime Function()? now,
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  Future<double> getRate({bool forceRefresh = false}) async {
    await _preferences.reload();
    final stored = _preferences.getString(_cacheKey);
    if (stored != null) {
      try {
        final cached = jsonDecode(stored) as Map<String, dynamic>;
        final age = _now().millisecondsSinceEpoch - (cached['at'] as int);
        final value = (cached['usd'] as num).toDouble();
        final ttl = forceRefresh ? minimumRefreshInterval : cacheTtl;
        if (age >= 0 &&
            age < ttl.inMilliseconds &&
            value.isFinite &&
            value > 0) {
          return value;
        }
      } on FormatException {
        await _preferences.remove(_cacheKey);
      } on TypeError {
        await _preferences.remove(_cacheKey);
      }
    }
    final running = _inFlight;
    if (running != null) return running;
    final future = _fetch();
    _inFlight = future;
    try {
      return await future;
    } finally {
      _inFlight = null;
    }
  }

  Future<double> _fetch() async {
    try {
      if (kDebugMode) {
        debugPrint('Coinbase FX: GET /v2/exchange-rates?currency=BTC');
      }
      final response = await _client
          .get(
            Uri.parse(
              'https://api.coinbase.com/v2/exchange-rates?currency=BTC',
            ),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw const BtcUsdRateException();
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;
      final rate = double.tryParse(rates['USD'].toString());
      if (data['currency'] != 'BTC' ||
          rate == null ||
          !rate.isFinite ||
          rate <= 0) {
        throw const BtcUsdRateException();
      }
      await _preferences.setString(
        _cacheKey,
        jsonEncode({'at': _now().millisecondsSinceEpoch, 'usd': rate}),
      );
      return rate;
    } catch (_) {
      // Do not guess a rate or show BTC values under a USD heading.
      throw const BtcUsdRateException();
    }
  }
}
