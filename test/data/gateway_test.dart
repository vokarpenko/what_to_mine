import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/gateway.dart';
import 'package:what_to_mine/src/data/db/entities/used_gpu_entity.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';
import 'package:what_to_mine/src/domain/settings.dart';

import '../mocks.mocks.dart';
import '../test_objects_factory.dart';

void main() {
  late SharedPreferences preferences;
  late MockApiClient client;
  late MockMemoryStorage cache;
  late MockAppDatabase database;
  late MockUsedGpuDao usedGpuDao;
  late MockUserHashAlgorithmDao algorithmDao;
  late MockBackgroundTaskScheduler scheduler;
  late Gateway gateway;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    client = MockApiClient();
    cache = MockMemoryStorage();
    database = MockAppDatabase();
    usedGpuDao = MockUsedGpuDao();
    algorithmDao = MockUserHashAlgorithmDao();
    scheduler = MockBackgroundTaskScheduler();
    when(database.usedGpuDao).thenReturn(usedGpuDao);
    when(database.userHashAlgorithmDao).thenReturn(algorithmDao);
    gateway = Gateway(
      client: client,
      cache: cache,
      database: database,
      preferences: preferences,
      backgroundScheduler: scheduler,
    );
  });

  tearDown(() => gateway.dispose());

  test(
    'delegates forced refresh and preserves BTC prices without the old USD volume filter',
    () async {
      final coins = TestObjectsFactory.createCryptoCurrenciesList();
      when(
        client.getCryptoCurrenciesListFromApi(forceRefresh: true),
      ).thenAnswer((_) async => coins);
      expect(await gateway.getCryptoCurrenciesList(isNeedFresh: true), coins);
      verify(cache.putCryptoCurrencies(coins)).called(1);
    },
  );

  test(
    'uses client TTL on regular reads rather than retaining prices in memory forever',
    () async {
      when(client.getCryptoCurrenciesListFromApi()).thenAnswer((_) async => []);
      await gateway.getCryptoCurrenciesList(isNeedFresh: false);
      await gateway.getCryptoCurrenciesList(isNeedFresh: false);
      verify(client.getCryptoCurrenciesListFromApi()).called(2);
    },
  );

  test('loads the current GPU catalog from WhatToMine', () async {
    when(client.getGPUListFromApi()).thenAnswer((_) async => []);
    expect(await gateway.getGPUList(), isEmpty);
    verify(client.getGPUListFromApi()).called(1);
  });

  test('preserves previously saved GPUs', () async {
    when(
      usedGpuDao.selectAll(),
    ).thenAnswer((_) async => TestObjectsFactory.createUsedGpusEntities());
    expect(await gateway.getUsedGPUList(), TestObjectsFactory.createUsedGpus());
  });

  test(
    'adds to an existing GPU quantity and persists mode before notifying listeners',
    () async {
      final gpu = TestObjectsFactory.createUsedGpuRx570(1);
      when(
        usedGpuDao.selectById(gpu.gpuData.id),
      ).thenAnswer((_) async => TestObjectsFactory.createUsedGpuEntityRx570(1));
      when(usedGpuDao.insert(any)).thenAnswer((_) async {});
      final changed = gateway.usedGpuChangedStream().first.then(
        (_) => preferences.getBool('h'),
      );
      await gateway.addUsedGpu(gpu);
      expect(await changed, false);
      final saved =
          verify(usedGpuDao.insert(captureAny)).captured.single
              as UsedGpuEntity;
      expect(saved.usedGpu.quantity, 2);
    },
  );

  test('deletes GPU and turns off custom hashrates', () async {
    when(usedGpuDao.deleteById('old-gpu')).thenAnswer((_) async {});
    await preferences.setBool('h', true);
    await gateway.deleteUsedGpu('old-gpu');
    expect(preferences.getBool('h'), false);
    verify(usedGpuDao.deleteById('old-gpu')).called(1);
  });

  test(
    'reads saved custom hashrates without rebuilding from the GPU catalog',
    () async {
      await preferences.setBool('h', true);
      when(algorithmDao.selectAll()).thenAnswer(
        (_) async => TestObjectsFactory.createEntitiesHashAlgorithms(),
      );
      expect(
        await gateway.getHashratesUsedInCalc(),
        TestObjectsFactory.createHashAlgorithms(),
      );
      verifyNever(client.getHashAlgorithmsFromApi());
    },
  );

  test(
    'sums mixed display units and quantities before choosing output units',
    () async {
      HashAlgorithm algo(
        double value,
        int coefficient,
        int power,
        String name,
      ) => HashAlgorithm(
        (builder) => builder
          ..name = name
          ..hashrate = value
          ..hashrateCoefficient = coefficient
          ..power = power,
      );
      UsedGpu gpu(String id, HashAlgorithm algorithm, int quantity) => UsedGpu(
        (builder) => builder
          ..quantity = quantity
          ..gpuData = (GpuBuilder()
            ..id = id
            ..name = id
            ..marketingName = id
            ..vendor = 'nvidia'
            ..price = 0
            ..secondHand = false
            ..hashAlgorithms = ListBuilder([algorithm])),
      );
      when(
        client.getHashAlgorithmsFromApi(),
      ).thenAnswer((_) async => [algo(0, 1, 0, 'KawPow')]);
      when(usedGpuDao.selectAll()).thenAnswer(
        (_) async => [
          UsedGpuEntity(gpu('old', algo(50, 1000000, 120, 'KAWPOW'), 2)),
          UsedGpuEntity(
            gpu('wtm:gpu:1', algo(0.1, 1000000000, 200, 'KawPow'), 3),
          ),
        ],
      );
      final result = (await gateway.getHashratesUsedInCalc()).single;
      expect(result.name, 'KawPow');
      expect(result.hashrate, 400);
      expect(result.hashrateCoefficient, 1000000);
      expect(result.power, 840);
    },
  );

  test('uses remote calculation including negative profit', () async {
    await preferences.setBool('h', true);
    await gateway.setSettings(Settings(electricityCost: 0.25));
    final algorithms = TestObjectsFactory.createHashAlgorithms();
    when(algorithmDao.selectAll()).thenAnswer(
      (_) async => TestObjectsFactory.createEntitiesHashAlgorithms(),
    );
    final earning = Earnings.fromCalculation(
      currency: TestObjectsFactory.createCryptoCurrenciesList().first,
      dayEarningInCrypto: 1,
      dayEarningInCurrency: 0.1,
      netDayEarningInCurrency: -0.5,
    );
    when(
      client.calculateEarningsFromApi(
        algorithms: algorithms,
        electricityCost: 0.25,
        forceRefresh: true,
      ),
    ).thenAnswer((_) async => [earning]);
    expect(
      (await gateway.getEarningsList(
        isNeedFresh: true,
      )).single.netDayEarningInCurrency,
      -0.5,
    );
    verifyNever(client.getCryptoCurrenciesListFromApi());
  });

  test('awaits custom hashrate writes before publishing the change', () async {
    final writes = Completer<void>();
    when(algorithmDao.insert(any)).thenAnswer((_) => writes.future);
    final algorithms = TestObjectsFactory.createHashAlgorithms()
        .take(1)
        .toList();
    final saving = gateway.updateHashratesInDB(algorithms);
    await Future<void>.delayed(Duration.zero);
    expect(preferences.getBool('h'), isNull);
    writes.complete();
    await saving;
    expect(preferences.getBool('h'), true);
  });
  test(
    'an empty rig does not load algorithms or calculate profitability',
    () async {
      when(usedGpuDao.selectAll()).thenAnswer((_) async => []);
      expect(await gateway.getEarningsList(isNeedFresh: false), isEmpty);
      verifyNever(client.getHashAlgorithmsFromApi());
      verifyNever(
        client.calculateEarningsFromApi(
          algorithms: anyNamed('algorithms'),
          electricityCost: anyNamed('electricityCost'),
        ),
      );
    },
  );
}
