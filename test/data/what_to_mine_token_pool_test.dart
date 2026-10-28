import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/client/what_to_mine_client.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import '../fixtures/what_to_mine_fixtures.dart';

void main() {
  late SharedPreferences preferences;
  late DateTime now;
  late List<http.Request> requests;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    now = DateTime.utc(2026, 10, 28);
    requests = [];
  });

  String token(http.Request request) =>
      request.headers['Authorization']!.substring(6);
  String endpoint(http.Request request) => request.url.pathSegments.last;
  String namespace(String key) => 'wtm.v1.${sha256.convert(utf8.encode(key))}';
  http.Response success(
    http.Request request, {
    Map<String, String> headers = const {},
  }) {
    final data = switch (endpoint(request)) {
      'coins' => wtmCoins,
      'gpus' => wtmGpus,
      'algorithms' => wtmAlgorithms,
      'calculate' => wtmCalculation,
      _ => throw StateError('Unexpected endpoint'),
    };
    return http.Response(jsonEncode(data), 200, headers: headers);
  }

  WhatToMineClient pool(List<String> keys, {MockClientHandler? handler}) =>
      WhatToMineClient(
        preferences: preferences,
        apiKeys: keys,
        now: () => now,
        client: MockClient((request) async {
          requests.add(request);
          return handler == null ? success(request) : await handler(request);
        }),
      );
  final quotaError = isA<WhatToMineException>().having(
    (error) => error.statusCode,
    'HTTP status',
    429,
  );
  final rig = HashAlgorithm(
    (builder) => builder
      ..name = 'KawPow'
      ..hashrate = 30
      ..hashrateCoefficient = 1000000
      ..power = 100,
  );

  test(
    '429 retries with the next token and remembers it after restart and reordering',
    () async {
      final api = pool(
        ['first', 'second'],
        handler: (request) async => token(request) == 'first'
            ? http.Response('{}', 429, headers: {'retry-after': '1'})
            : success(
                request,
                headers: {
                  'x-ratelimit-limit': '1000',
                  'x-ratelimit-remaining': '999',
                },
              ),
      );
      expect(await api.getCryptoCurrenciesListFromApi(), isNotEmpty);
      expect(requests.map(token), ['first', 'second']);
      expect(api.rateLimit?['remaining'], 999);
      now = now.add(
        const Duration(seconds: 2),
      ); // first token can be checked again, but keep using second
      await pool(['second', 'first']).getGPUListFromApi();
      expect(requests.map(token), ['first', 'second', 'second']);
      expect(requests.last.url.queryParameters, isEmpty);
    },
  );

  test(
    'last successful response with zero remaining is used once; next endpoint rotates',
    () async {
      final api = pool(
        ['first', 'second'],
        handler: (request) async => success(
          request,
          headers: token(request) == 'first'
              ? {
                  'x-ratelimit-limit': '1000',
                  'x-ratelimit-used': '1000',
                  'x-ratelimit-remaining': '0',
                }
              : {
                  'x-ratelimit-limit': '2000',
                  'x-ratelimit-used': '1',
                  'x-ratelimit-remaining': '1999',
                },
        ),
      );
      final earnings = await api.calculateEarningsFromApi(
        algorithms: [rig],
        electricityCost: .1,
      );
      expect(earnings.single.netDayEarningInCurrency, -.09);
      expect(requests.map((r) => '${token(r)}:${endpoint(r)}'), [
        'first:coins',
        'second:calculate',
      ]);
      expect(api.rateLimit?['remaining'], 1999);
      final firstUsage =
          jsonDecode(preferences.getString('${namespace('first')}.usage')!)
              as Map;
      expect(firstUsage['remaining'], 0);
      expect(await api.getCryptoCurrenciesListFromApi(), isNotEmpty);
      expect(requests.length, 2); // cache from first token is still usable
    },
  );

  test(
    'limit and used can indicate exhaustion when remaining is absent',
    () async {
      final api = pool(
        ['first', 'second'],
        handler: (request) async => success(
          request,
          headers: {'x-ratelimit-limit': '5', 'x-ratelimit-used': '5'},
        ),
      );
      await api.getCryptoCurrenciesListFromApi();
      await api.getGPUListFromApi();
      expect(requests.map(token), ['first', 'second']);
    },
  );

  test(
    'all exhausted tokens are tried once, then skipped across client restarts',
    () async {
      final keys = ['first', 'second', 'third'];
      final api = pool(keys, handler: (_) async => http.Response('{}', 429));
      await expectLater(
        api.getCryptoCurrenciesListFromApi(),
        throwsA(quotaError),
      );
      await expectLater(api.getGPUListFromApi(), throwsA(quotaError));
      await expectLater(pool(keys).getGPUListFromApi(), throwsA(quotaError));
      expect(requests.map(token), keys);
      now = now.add(const Duration(days: 1));
      expect(await pool(keys).getCryptoCurrenciesListFromApi(), isNotEmpty);
      expect(requests.map(token), [...keys, 'first']);
    },
  );

  test(
    'fresh cache remains available even when every token is exhausted',
    () async {
      final api = pool(
        ['first', 'second'],
        handler: (request) async =>
            success(request, headers: {'x-ratelimit-remaining': '0'}),
      );
      await api.getCryptoCurrenciesListFromApi();
      await api.getGPUListFromApi();
      final restarted = pool(['first', 'second']);
      expect(await restarted.getCryptoCurrenciesListFromApi(), isNotEmpty);
      expect(await restarted.getGPUListFromApi(), isNotEmpty);
      await expectLater(
        restarted.calculateEarningsFromApi(
          algorithms: [rig],
          electricityCost: .1,
        ),
        throwsA(quotaError),
      );
      expect(requests.map(token), ['first', 'second']);
    },
  );

  for (final httpDate in [false, true]) {
    test(
      'per-token Retry-After ${httpDate ? 'HTTP date' : 'seconds'} expires independently',
      () async {
        final firstRetry = now.add(const Duration(hours: 1));
        final api = pool(
          ['first', 'second'],
          handler: (request) async => http.Response(
            '{}',
            429,
            headers: {
              'retry-after': token(request) == 'first'
                  ? (httpDate ? HttpDate.format(firstRetry) : '3600')
                  : '7200',
            },
          ),
        );
        await expectLater(
          api.getCryptoCurrenciesListFromApi(),
          throwsA(quotaError),
        );
        now = now.add(const Duration(minutes: 59));
        await expectLater(
          pool(['first', 'second']).getGPUListFromApi(),
          throwsA(quotaError),
        );
        expect(requests.length, 2);
        now = now.add(const Duration(minutes: 1));
        await pool(['first', 'second']).getGPUListFromApi();
        expect(requests.map(token), ['first', 'second', 'first']);
      },
    );
  }

  test(
    'parallel identical calculations share one sequence of bounded failovers',
    () async {
      final api = pool(
        ['first', 'second', 'third'],
        handler: (request) async {
          await Future<void>.delayed(const Duration(milliseconds: 2));
          if (token(request) == 'first' ||
              (token(request) == 'second' &&
                  endpoint(request) == 'calculate')) {
            return http.Response('{}', 429);
          }
          return success(request);
        },
      );
      final results = await Future.wait(
        List.generate(
          5,
          (_) => api.calculateEarningsFromApi(
            algorithms: [rig],
            electricityCost: .1,
          ),
        ),
      );
      expect(results.every((list) => list.length == 1), isTrue);
      expect(requests.map((r) => '${token(r)}:${endpoint(r)}'), [
        'first:coins',
        'second:coins',
        'second:calculate',
        'third:calculate',
      ]);
      expect(requests[2].method, 'POST');
      expect(requests[3].method, 'POST');
      expect(requests[2].body, requests[3].body);
      expect(requests[3].headers['Content-Type'], contains('application/json'));
    },
  );

  test(
    'concurrent different endpoints do not both spend the last request on one token',
    () async {
      var active = 0;
      var maximum = 0;
      final api = pool(
        ['first', 'second'],
        handler: (request) async {
          active++;
          if (active > maximum) maximum = active;
          await Future<void>.delayed(const Duration(milliseconds: 5));
          active--;
          return success(request, headers: {'x-ratelimit-remaining': '0'});
        },
      );
      await Future.wait<Object>([
        api.getCryptoCurrenciesListFromApi(),
        api.getGPUListFromApi(),
      ]);
      expect(requests.map(token), ['first', 'second']);
      expect(maximum, 1);
    },
  );

  for (final status in [401, 403, 500]) {
    test(
      'HTTP $status does not rotate tokens or poison the request queue',
      () async {
        final api = pool(
          ['first', 'second'],
          handler: (request) async => requests.length == 1
              ? http.Response('private details', status)
              : success(request),
        );
        await expectLater(
          api.getCryptoCurrenciesListFromApi(),
          throwsA(
            isA<WhatToMineException>().having(
              (error) => error.statusCode,
              'status',
              status,
            ),
          ),
        );
        expect(await api.getGPUListFromApi(), isNotEmpty);
        expect(requests.map(token), ['first', 'first']);
      },
    );
  }

  test(
    'network errors and malformed responses do not consume backup tokens',
    () async {
      for (final network in [false, true]) {
        final api = pool(
          ['first', 'second'],
          handler: (_) async {
            if (network) throw http.ClientException('private details');
            return http.Response('{broken', 200);
          },
        );
        await expectLater(
          api.getCryptoCurrenciesListFromApi(),
          throwsA(isA<WhatToMineException>()),
        );
      }
      expect(requests.map(token), ['first', 'first']);
    },
  );

  test(
    'duplicates and blank tokens are normalized, but an empty pool sends no request',
    () async {
      final api = pool(
        [' first ', '', 'first', ' ', 'second'],
        handler: (request) async => token(request) == 'first'
            ? http.Response('{}', 429)
            : success(request),
      );
      await api.getGPUListFromApi();
      expect(requests.map(token), ['first', 'second']);
      await expectLater(
        pool([]).getGPUListFromApi(),
        throwsA(
          isA<WhatToMineException>().having(
            (error) => error.messageKey,
            'missing keys',
            'error_wtm_api_key',
          ),
        ),
      );
      expect(requests.length, 2);
    },
  );

  test(
    'adding keys reuses legacy single-key cache and exhausted-token state',
    () async {
      final legacy = WhatToMineClient(
        preferences: preferences,
        apiKey: 'first',
        now: () => now,
        client: MockClient((request) async {
          requests.add(request);
          return success(request, headers: {'x-ratelimit-remaining': '0'});
        }),
      );
      await legacy.getCryptoCurrenciesListFromApi();
      final expanded = pool(['first', 'second']);
      await expanded.getCryptoCurrenciesListFromApi();
      expect(requests.length, 1);
      await expanded.getGPUListFromApi();
      expect(requests.map(token), ['first', 'second']);
    },
  );

  test(
    'explicit lists take precedence and malformed tokens fail before HTTP',
    () async {
      final api = WhatToMineClient(
        preferences: preferences,
        apiKey: 'legacy',
        apiKeys: ['first'],
        client: MockClient((request) async {
          requests.add(request);
          return success(request);
        }),
      );
      await api.getGPUListFromApi();
      expect(requests.map(token), ['first']);
      await expectLater(
        pool(['secret\nheader']).getGPUListFromApi(),
        throwsA(
          isA<WhatToMineException>().having(
            (error) => error.messageKey,
            'configuration error',
            'error_wtm_api_keys_config',
          ),
        ),
      );
      expect(requests.length, 1);
    },
  );

  test(
    'pool reads newest response across its keys, respecting forced refresh interval',
    () async {
      await pool(['first']).getCryptoCurrenciesListFromApi();
      now = now.add(const Duration(minutes: 1));
      await pool(
        ['second'],
        handler: (_) async => http.Response(
          jsonEncode([
            {...wtmCoins.first, 'name': 'New catalog'},
          ]),
          200,
        ),
      ).getCryptoCurrenciesListFromApi();
      final api = pool(['first', 'second']);
      expect(
        (await api.getCryptoCurrenciesListFromApi()).first.name,
        'New catalog',
      );
      await api.getCryptoCurrenciesListFromApi(forceRefresh: true);
      expect(requests.length, 2);
      now = now.add(const Duration(minutes: 1));
      await api.getCryptoCurrenciesListFromApi(forceRefresh: true);
      expect(requests.length, 3);
    },
  );

  test(
    'an unrelated pool cannot reuse old cached data; stored state contains no raw tokens',
    () async {
      await pool(
        ['private-first', 'private-second'],
        handler: (request) async => token(request) == 'private-first'
            ? http.Response('{}', 429)
            : success(request),
      ).getCryptoCurrenciesListFromApi();
      for (final key in preferences.getKeys()) {
        for (final secret in ['private-first', 'private-second']) {
          expect(key, isNot(contains(secret)));
          expect(preferences.get(key).toString(), isNot(contains(secret)));
        }
      }
      await expectLater(
        pool(
          ['unrelated'],
          handler: (_) async => http.Response('{}', 401),
        ).getCryptoCurrenciesListFromApi(),
        throwsA(isA<WhatToMineException>()),
      );
      expect(requests.length, 3);
    },
  );
}
