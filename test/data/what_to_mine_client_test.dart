import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/client/what_to_mine_client.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';

import '../fixtures/what_to_mine_fixtures.dart';

HashAlgorithm rig({
  double hashrate = 30,
  int coefficient = 1000000,
  int power = 100,
  String name = 'KAWPOW',
}) => HashAlgorithm(
  (builder) => builder
    ..name = name
    ..hashrate = hashrate
    ..hashrateCoefficient = coefficient
    ..power = power,
);

void main() {
  late SharedPreferences preferences;
  late DateTime now;
  late List<http.Request> requests;
  late http.Client transport;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    now = DateTime.utc(2026, 10, 28);
    requests = [];
    transport = MockClient((request) async {
      requests.add(request);
      final data = switch (request.url.pathSegments.last) {
        'coins' => wtmCoins,
        'algorithms' => wtmAlgorithms,
        'gpus' => wtmGpus,
        'calculate' => wtmCalculation,
        _ => throw StateError('Unexpected endpoint'),
      };
      return http.Response(
        jsonEncode(data),
        200,
        headers: {
          'x-ratelimit-limit': '1000',
          'x-ratelimit-used': '${requests.length}',
          'x-ratelimit-remaining': '${1000 - requests.length}',
        },
      );
    });
  });

  WhatToMineClient client({
    String key = 'test-token',
    http.Client? httpClient,
  }) => WhatToMineClient(
    preferences: preferences,
    apiKey: key,
    client: httpClient ?? transport,
    now: () => now,
  );

  test(
    'uses Token authorization without putting credentials in URLs or cached data',
    () async {
      final api = client();
      final coins = await api.getCryptoCurrenciesListFromApi();
      expect(requests.single.method, 'GET');
      expect(
        requests.single.url.toString(),
        'https://whattomine.com/api/v1/coins',
      );
      expect(requests.single.headers['Authorization'], 'Token test-token');
      expect(coins.first.id, '234');
      expect(coins.first.price, 0.00000010);
      expect(coins.first.quoteCurrency, 'BTC');
      expect(coins.first.volume, 12);
      expect(coins.first.networkHashrate, 1000000000000);
      expect(api.rateLimit?['remaining'], 999);
      for (final key in preferences.getKeys()) {
        expect(key, isNot(contains('test-token')));
        expect(preferences.get(key).toString(), isNot(contains('test-token')));
      }
    },
  );

  test(
    'loads GPU hashrates in H/s and converts them to display units',
    () async {
      final gpus = await client().getGPUListFromApi();
      expect(gpus.first.id, 'wtm:gpu:1');
      expect(gpus.first.vendor, 'nvidia');
      expect(gpus.last.vendor, 'amd');
      expect(gpus.first.hashAlgorithms.first.hashrate, 62);
      expect(gpus.first.hashAlgorithms.first.hashrateCoefficient, 1000000);
      expect(gpus.first.hashAlgorithms.first.power, 370);
    },
  );

  test(
    'posts all algorithms once and uses API profits without subtracting electricity twice',
    () async {
      final earnings = await client().calculateEarningsFromApi(
        algorithms: [
          rig(),
          rig(
            name: 'Etchash',
            hashrate: 0.1,
            coefficient: 1000000000,
            power: 200,
          ),
        ],
        electricityCost: 0.1,
      );
      final calculation = requests
          .where((request) => request.method == 'POST')
          .single;
      final body = jsonDecode(calculation.body) as Map<String, dynamic>;
      expect(body['cost'], 0.1);
      expect(body['settings'], [
        {'algorithm': 'eth4g', 'hashrate': 100000000.0, 'power': 200},
        {'algorithm': 'kp', 'hashrate': 30000000.0, 'power': 100},
      ]);
      expect(
        body.containsKey('fee'),
        isFalse,
      ); // service applies each coin's default fee
      expect(earnings.single.dayEarningInCrypto, 1.5);
      expect(earnings.single.dayEarningInCurrency, 0.15);
      expect(earnings.single.netDayEarningInCurrency, -0.09);
      expect(earnings.single.dayElectricityCost, closeTo(0.24, 1e-9));
      expect(earnings.single.netMonthEarningInCurrency, closeTo(-2.7, 1e-9));
    },
  );

  test('combines duplicate algorithm settings in base H/s', () async {
    await client().calculateEarningsFromApi(
      algorithms: [rig(), rig(hashrate: 0.1, coefficient: 1000000000)],
      electricityCost: 0,
    );
    final body = jsonDecode(requests.last.body) as Map<String, dynamic>;
    expect((body['settings'] as List).single, {
      'algorithm': 'kp',
      'hashrate': 130000000.0,
      'power': 200,
    });
  });

  test('does not consume requests when no hashrates are selected', () async {
    expect(
      await client(
        key: '',
      ).calculateEarningsFromApi(algorithms: [], electricityCost: 0.1),
      isEmpty,
    );
    expect(requests, isEmpty);
  });

  test('reports a missing token before sending requests', () async {
    await expectLater(
      client(key: '').getCryptoCurrenciesListFromApi(),
      throwsA(isA<WhatToMineException>()),
    );
    expect(requests, isEmpty);
  });

  test(
    'does not guess parameter names for unsupported legacy algorithms',
    () async {
      await expectLater(
        client().calculateEarningsFromApi(
          algorithms: [rig(name: 'UnknownLegacyAlgorithm')],
          electricityCost: 0.1,
        ),
        throwsA(
          isA<WhatToMineException>().having(
            (error) => error.messageKey,
            'message',
            'error_wtm_unsupported_algorithms',
          ),
        ),
      );
      expect(requests.any((request) => request.method == 'POST'), isFalse);
    },
  );

  test('persistent cache survives client restarts and expires', () async {
    await client().getCryptoCurrenciesListFromApi();
    await client().getCryptoCurrenciesListFromApi();
    expect(requests.length, 1);
    now = now.add(const Duration(hours: 24));
    await client().getCryptoCurrenciesListFromApi();
    expect(requests.length, 2);
  });

  test(
    'manual refresh bypasses TTL but repeated refreshes within a minute reuse cache',
    () async {
      await client().getCryptoCurrenciesListFromApi();
      await client().getCryptoCurrenciesListFromApi(forceRefresh: true);
      expect(requests.length, 1);
      now = now.add(const Duration(minutes: 1));
      await client().getCryptoCurrenciesListFromApi(forceRefresh: true);
      expect(requests.length, 2);
    },
  );

  test(
    'calculation cache includes tariff, rig configuration, and token',
    () async {
      Future<void> calculate(
        WhatToMineClient api,
        double cost,
        double hash,
      ) async {
        await api.calculateEarningsFromApi(
          algorithms: [rig(hashrate: hash)],
          electricityCost: cost,
        );
      }

      await calculate(client(), 0.1, 30);
      expect(requests.length, 2);
      await calculate(client(), 0.1, 30);
      expect(requests.length, 2);
      await calculate(client(), 0.2, 30);
      expect(requests.length, 3);
      await calculate(client(), 0.2, 40);
      expect(requests.length, 4);
      now = now.add(const Duration(hours: 2));
      await calculate(client(), 0.2, 40);
      expect(requests.length, 5);
      await calculate(client(key: 'another-token'), 0.2, 40);
      expect(requests.length, 7);
    },
  );

  test('simultaneous identical calculations share network requests', () async {
    final baseTransport = transport;
    transport = MockClient((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final forwarded = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes;
      return http.Response.fromStream(await baseTransport.send(forwarded));
    });
    final api = client();
    await Future.wait(
      List.generate(
        5,
        (_) => api.calculateEarningsFromApi(
          algorithms: [rig()],
          electricityCost: 0.1,
        ),
      ),
    );
    expect(requests.length, 2);
  });

  for (final status in [401, 403, 500]) {
    test(
      'reports HTTP $status without treating it as a successful empty list',
      () async {
        final api = client(
          httpClient: MockClient(
            (_) async => http.Response('private server details', status),
          ),
        );
        await expectLater(
          api.getCryptoCurrenciesListFromApi(),
          throwsA(
            isA<WhatToMineException>().having(
              (error) => error.statusCode,
              'HTTP status',
              status,
            ),
          ),
        );
        expect(
          preferences.getKeys().where((key) => key.contains('.coins.')),
          isEmpty,
        );
      },
    );
  }

  test('HTTP 429 backs off across restarts and honors Retry-After', () async {
    var calls = 0;
    final limited = MockClient((_) async {
      calls++;
      return http.Response('{}', 429, headers: {'retry-after': '3600'});
    });
    for (var attempt = 0; attempt < 2; attempt++) {
      await expectLater(
        client(httpClient: limited).getCryptoCurrenciesListFromApi(),
        throwsA(isA<WhatToMineException>()),
      );
    }
    expect(calls, 1);
    now = now.add(const Duration(hours: 1));
    expect(await client().getCryptoCurrenciesListFromApi(), isNotEmpty);
  });

  test('malformed JSON is reported and not cached', () async {
    await expectLater(
      client(
        httpClient: MockClient((_) async => http.Response('{broken', 200)),
      ).getCryptoCurrenciesListFromApi(),
      throwsA(isA<WhatToMineException>()),
    );
    expect(
      preferences.getKeys().where((key) => key.contains('.coins.')),
      isEmpty,
    );
  });

  test('does not reuse old successful responses for a changed token', () async {
    await client().getCryptoCurrenciesListFromApi();
    await expectLater(
      client(
        key: 'bad-token',
        httpClient: MockClient((_) async => http.Response('{}', 401)),
      ).getCryptoCurrenciesListFromApi(),
      throwsA(isA<WhatToMineException>()),
    );
  });
  test(
    'invalid Retry-After still applies a persistent quota backoff',
    () async {
      var calls = 0;
      final limited = MockClient((_) async {
        calls++;
        return http.Response(
          '{}',
          429,
          headers: {'retry-after': 'invalid date'},
        );
      });
      for (var attempt = 0; attempt < 2; attempt++) {
        await expectLater(
          client(httpClient: limited).getCryptoCurrenciesListFromApi(),
          throwsA(
            isA<WhatToMineException>().having(
              (error) => error.statusCode,
              'HTTP status',
              429,
            ),
          ),
        );
      }
      expect(calls, 1);
    },
  );

  test(
    'rejects unknown power consumption instead of assuming free electricity',
    () async {
      final algorithm = rig().rebuild((builder) => builder..power = null);
      await expectLater(
        client().calculateEarningsFromApi(
          algorithms: [algorithm],
          electricityCost: 0.1,
        ),
        throwsA(
          isA<WhatToMineException>().having(
            (error) => error.messageKey,
            'message',
            'error_wtm_invalid_settings',
          ),
        ),
      );
      expect(requests.any((request) => request.method == 'POST'), isFalse);
    },
  );
  test(
    'derives algorithm parameters from coins without consuming an algorithms request',
    () async {
      final api = client();
      await api.getCryptoCurrenciesListFromApi();
      expect(
        (await api.getHashAlgorithmsFromApi()).map(
          (algorithm) => algorithm.name,
        ),
        ['KawPow', 'Etchash'],
      );
      await api.calculateEarningsFromApi(
        algorithms: [rig()],
        electricityCost: 0.1,
      );
      expect(requests.map((request) => request.url.pathSegments.last), [
        'coins',
        'calculate',
      ]);
    },
  );

  test(
    'falls back to algorithms when a coin is missing its parameter name',
    () async {
      final api = client(
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.url.pathSegments.last == 'coins') {
            final rows = wtmCoins
                .map((row) => {...row}..remove('algo_param_name'))
                .toList();
            return http.Response(jsonEncode(rows), 200);
          }
          return http.Response(jsonEncode(wtmAlgorithms), 200);
        }),
      );
      expect((await api.getHashAlgorithmsFromApi()).length, 2);
      expect(requests.map((request) => request.url.pathSegments.last), [
        'coins',
        'algorithms',
      ]);
    },
  );

  test('recognizes family names returned by the live GPU catalog', () {
    expect(WhatToMineClient.gpuVendor('GeForce RTX 4070 Ti Super'), 'nvidia');
    expect(WhatToMineClient.gpuVendor('GeForce GTX 1080 Ti'), 'nvidia');
    expect(WhatToMineClient.gpuVendor('RTX A5000'), 'nvidia');
    expect(WhatToMineClient.gpuVendor('Radeon RX 6600 XT'), 'amd');
    expect(WhatToMineClient.gpuVendor('Radeon R9 390'), 'amd');
    expect(WhatToMineClient.gpuVendor('Radeon VII'), 'amd');
    expect(WhatToMineClient.gpuVendor('Custom GPU', 'AMD'), 'amd');
  });
}
