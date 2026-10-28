import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:what_to_mine/src/data/client/miner_stat_client.dart';

void main() {
  test('loads legacy coin data with an authenticated GET request', () async {
    final client = MinerStatClient(
      apiKey: 'test-key',
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'https://api.minerstat.com/v2/coins');
        expect(request.headers['X-API-Key'], 'test-key');
        return http.Response(
          jsonEncode([
            {
              'id': 'bitcoin',
              'coin': 'BTC',
              'name': 'Bitcoin',
              'type': 'coin',
              'algorithm': 'SHA-256',
              'price': 100000,
              'reward': 0.000001,
              'network_hashrate': 1000000,
              'reward_unit': 'BTC',
              'volume': 1000000000,
            },
          ]),
          200,
        );
      }),
    );

    final coins = await client.getCryptoCurrenciesListFromApi();
    expect(coins.single.coin, 'BTC');
    expect(coins.single.price, 100000.0);
  });

  test('reports a missing key without making a request', () async {
    final client = MinerStatClient(
      apiKey: '',
      client: MockClient((_) async => fail('No API request should be sent')),
    );

    await expectLater(client.getCryptoCurrenciesListFromApi(), throwsException);
  });

  for (final status in [401, 403, 429, 500]) {
    test('reports HTTP $status as an error', () async {
      final client = MinerStatClient(
        apiKey: 'test-key',
        client: MockClient((_) async => http.Response('{}', status)),
      );

      await expectLater(
        client.getCryptoCurrenciesListFromApi(),
        throwsException,
      );
    });
  }
}
