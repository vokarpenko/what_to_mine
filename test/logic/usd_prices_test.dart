import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/client/btc_usd_rate_client.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/logic/currencies_service.dart';

import '../mocks.mocks.dart';

CryptoCurrency coin({
  double price = 0.000001,
  double? usdPrice,
  String quote = 'BTC',
}) => CryptoCurrency(
  id: '234',
  coin: 'RVN',
  name: 'Ravencoin',
  type: 'coin',
  algorithm: 'KawPow',
  price: price,
  usdPrice: usdPrice,
  quoteCurrency: quote,
  reward: -1,
  networkHashrate: 1,
  rewardUnit: 'RVN',
  volume: 12,
);

void main() {
  test(
    'converts only the price while retaining BTC source values and volumes',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final rates = BtcUsdRateClient(
        preferences: preferences,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'data': {
                'currency': 'BTC',
                'rates': {'USD': '80000'},
              },
            }),
            200,
          ),
        ),
      );
      final result = await CurrenciesService(
        gateway: MockGateway(),
        exchangeRates: rates,
      ).pricesInUsd([coin(), coin(price: -1)]);
      expect(result.first.usdPrice, closeTo(0.08, 1e-12));
      expect(result.first.formattedUsdPrice, r'$0.0800');
      expect(result.first.price, 0.000001);
      expect(result.first.quoteCurrency, 'BTC');
      expect(result.first.formattedVolume, '12.00000000 BTC');
      expect(result.last.formattedUsdPrice, '—');
    },
  );

  test('does not fetch a BTC rate when no prices can be converted', () async {
    final result = await CurrenciesService(
      gateway: MockGateway(),
    ).pricesInUsd([coin(price: -1)]);
    expect(result.single.formattedUsdPrice, '—');
  });

  test(
    'formats small USD amounts without scientific notation or false zeros',
    () {
      expect(coin(usdPrice: 12.3456).formattedUsdPrice, r'$12.35');
      expect(coin(usdPrice: 0.005312).formattedUsdPrice, r'$0.00531');
      expect(coin(usdPrice: 0.00000002).formattedUsdPrice, r'$0.0000000200');
      expect(
        coin(usdPrice: 0.00000000000001).formattedUsdPrice,
        r'<$0.000000000001',
      );
      expect(coin().formattedUsdPrice, '—');
    },
  );
}
