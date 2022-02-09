import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/client/miner_stat_client.dart';
import 'package:what_to_mine/src/data/gateway.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';

import '../mocks.mocks.dart';
import '../test_objects_factory.dart';

Future<void> main() async {
  MockMemoryStorage mockCache = MockMemoryStorage();
  MockBackgroundTaskScheduler mockBackgroundTaskScheduler = MockBackgroundTaskScheduler();
  MockAppDatabase mockAppDatabase = MockAppDatabase();
  MockJsonReader mockJsonReader = MockJsonReader();
  MinerStatClient mockMinerStatClient = MockMinerStatClient();
  MockUsedGpuDao mockUsedGpuDao = MockUsedGpuDao();
  MockUserHashAlgorithmDao mockUserHashAlgorithmDao = MockUserHashAlgorithmDao();
  SharedPreferences.setMockInitialValues({});
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  late Gateway gateway;

  setUp(() async {
    gateway = Gateway(
        preferences: sharedPreferences,
        cache: mockCache,
        backgroundScheduler: mockBackgroundTaskScheduler,
        database: mockAppDatabase,
        jsonReader: mockJsonReader,
        client: mockMinerStatClient);
  });

  tearDown(() async {});

  test('getCryptoCurrenciesList with refresh', () async {
    List<CryptoCurrency> listCryptoCurrencies = TestObjectsFactory.createCryptoCurrenciesListWithFilters();
    List<CryptoCurrency> result;

    when(mockMinerStatClient.getCryptoCurrenciesListFromApi())
        .thenAnswer((_) async => TestObjectsFactory.createCryptoCurrenciesList());
    when(mockCache.putCryptoCurrencies(TestObjectsFactory.createCryptoCurrenciesListWithFilters()))
        .thenAnswer((_) => _);

    result = await gateway.getCryptoCurrenciesList(isNeedFresh: true);

    expect(listCryptoCurrencies, equals(result));
  });

  test('getCryptoCurrenciesList without refresh with cache', () async {
    List<CryptoCurrency> listCryptoCurrencies = TestObjectsFactory.createCryptoCurrenciesListWithFilters();
    List<CryptoCurrency> result;

    when(mockCache.getCryptoCurrencies()).thenAnswer((_) => TestObjectsFactory.createCryptoCurrenciesListWithFilters());

    result = await gateway.getCryptoCurrenciesList(isNeedFresh: false);

    expect(listCryptoCurrencies, equals(result));
  });

  test('getCryptoCurrenciesList without refresh without cache', () async {
    List<CryptoCurrency> listCryptoCurrencies = TestObjectsFactory.createCryptoCurrenciesListWithFilters();
    List<CryptoCurrency> result;

    when(mockCache.getCryptoCurrencies()).thenAnswer((_) => []);
    when(mockMinerStatClient.getCryptoCurrenciesListFromApi())
        .thenAnswer((_) async => TestObjectsFactory.createCryptoCurrenciesList());
    when(mockCache.putCryptoCurrencies(TestObjectsFactory.createCryptoCurrenciesListWithFilters()))
        .thenAnswer((_) => _);

    result = await gateway.getCryptoCurrenciesList(isNeedFresh: true);

    expect(listCryptoCurrencies, equals(result));
  });

  test('getGpusUsedInCalc', () async {
    List<UsedGpu> listUsedGpus = TestObjectsFactory.createUsedGpus();
    List<UsedGpu> result;

    when(mockAppDatabase.usedGpuDao).thenReturn(mockUsedGpuDao);
    when(mockUsedGpuDao.selectAll()).thenAnswer((_) async => TestObjectsFactory.createUsedGpusEntities());

    result = await gateway.getUsedGPUList();

    expect(listUsedGpus, equals(result));
  });

  test('addUsedGpu to existing', () async {
    UsedGpu usedGpu = TestObjectsFactory.createUsedGpuRx570(1);

    when(mockAppDatabase.usedGpuDao).thenReturn(mockUsedGpuDao);
    when(mockUsedGpuDao.selectById(usedGpu.gpuData.id))
        .thenAnswer((_) async => TestObjectsFactory.createUsedGpuEntityRx570(1));
    when(mockUsedGpuDao.insert(TestObjectsFactory.createUsedGpuEntityRx570(2)))
        .thenAnswer((_) async => TestObjectsFactory.createUsedGpuEntityRx570(1));

    await gateway.addUsedGpu(usedGpu);

    expect(sharedPreferences.getBool('h'), false);
  });

  test('deleteUsedGpu', () async {
    UsedGpu usedGpu = TestObjectsFactory.createUsedGpuRx570(1);

    when(mockAppDatabase.usedGpuDao).thenReturn(mockUsedGpuDao);
    when(mockUsedGpuDao.deleteById(usedGpu.gpuData.id)).thenAnswer((_) async => _);

    await gateway.deleteUsedGpu(usedGpu.gpuData.id);

    expect(sharedPreferences.getBool('h'), false);
  });

  test('getHashratesUsedInCalc with custom hashrates', () async {
    Map<String, bool> initialValues = {
      "h": true,
    };
    SharedPreferences.setMockInitialValues(initialValues);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Gateway gateway = Gateway(
        client: mockMinerStatClient,
        jsonReader: mockJsonReader,
        cache: mockCache,
        database: mockAppDatabase,
        preferences: sharedPreferences,
        backgroundScheduler: mockBackgroundTaskScheduler);

    List<HashAlgorithm> algorithms = TestObjectsFactory.createHashAlgorithms();
    List<HashAlgorithm> result;
    when(mockAppDatabase.userHashAlgorithmDao).thenReturn(mockUserHashAlgorithmDao);
    when(mockUserHashAlgorithmDao.selectAll())
        .thenAnswer((_) async => TestObjectsFactory.createEntitiesHashAlgorithms());

    result = await gateway.getHashratesUsedInCalc();

    expect(result, equals(algorithms));
  });

  test('getHashratesUsedInCalc without custom hashrates', () async {
    Map<String, bool> initialValues = {
      "h": false,
    };
    SharedPreferences.setMockInitialValues(initialValues);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Gateway gateway = Gateway(
        client: mockMinerStatClient,
        jsonReader: mockJsonReader,
        cache: mockCache,
        database: mockAppDatabase,
        preferences: sharedPreferences,
        backgroundScheduler: mockBackgroundTaskScheduler);

    List<HashAlgorithm> algorithms = TestObjectsFactory.createHashAlgorithms();
    List<HashAlgorithm> result;

    when(mockAppDatabase.usedGpuDao).thenReturn(mockUsedGpuDao);
    when(mockUsedGpuDao.selectAll()).thenAnswer((_) async => TestObjectsFactory.createUsedGpusEntities());

    when(mockJsonReader.getHashAlgorithmsWithZeroValues())
        .thenAnswer((_) async => TestObjectsFactory.createHashAlgorithmsWithZeroValues());
    result = await gateway.getHashratesUsedInCalc();

    expect(result, equals(algorithms));
  });
}
