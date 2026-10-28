import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/client/btc_usd_rate_client.dart';

void main() {
  late SharedPreferences preferences;
  late DateTime now;
  late int requests;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    now = DateTime.utc(2026, 10, 28);
    requests = 0;
  });

  BtcUsdRateClient client({
    String currency = 'BTC',
    String rate = '80000',
    int status = 200,
  }) => BtcUsdRateClient(
    preferences: preferences,
    now: () => now,
    client: MockClient((request) async {
      requests++;
      expect(
        request.url.toString(),
        'https://api.coinbase.com/v2/exchange-rates?currency=BTC',
      );
      expect(
        request.headers.keys.map((key) => key.toLowerCase()),
        isNot(contains('authorization')),
      );
      expect(
        request.headers.keys.map((key) => key.toLowerCase()),
        isNot(contains('x-api-key')),
      );
      return http.Response(
        jsonEncode({
          'data': {
            'currency': currency,
            'rates': {'USD': rate},
          },
        }),
        status,
      );
    }),
  );

  test(
    'uses public BTC/USD data and retains it across restarts for 24 hours',
    () async {
      expect(await client().getRate(), 80000);
      expect(await client(rate: '90000').getRate(), 80000);
      expect(requests, 1);
      now = now.add(const Duration(hours: 24));
      expect(await client(rate: '90000').getRate(), 90000);
      expect(requests, 2);
    },
  );

  test(
    'manual refresh updates a rate but does not repeat within a minute',
    () async {
      await client().getRate();
      expect(await client(rate: '90000').getRate(forceRefresh: true), 80000);
      now = now.add(const Duration(minutes: 1));
      expect(await client(rate: '90000').getRate(forceRefresh: true), 90000);
      expect(requests, 2);
    },
  );

  test('concurrent reads share one exchange-rate request', () async {
    final api = client();
    expect(await Future.wait([api.getRate(), api.getRate(), api.getRate()]), [
      80000,
      80000,
      80000,
    ]);
    expect(requests, 1);
  });

  for (final rate in ['0', '-100', 'NaN', 'Infinity', 'not-a-rate']) {
    test('does not cache an invalid USD rate ($rate)', () async {
      await expectLater(
        client(rate: rate).getRate(),
        throwsA(isA<BtcUsdRateException>()),
      );
      expect(await client().getRate(), 80000);
      expect(requests, 2);
    });
  }

  test('rejects a response for the wrong base currency', () async {
    await expectLater(
      client(currency: 'USD').getRate(),
      throwsA(isA<BtcUsdRateException>()),
    );
  });

  test('does not silently use an expired rate after a network error', () async {
    await client().getRate();
    now = now.add(const Duration(hours: 24));
    await expectLater(
      client(status: 500).getRate(),
      throwsA(isA<BtcUsdRateException>()),
    );
  });
}
