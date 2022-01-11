import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/Gateway.dart';
import 'package:what_to_mine/src/data/client/MinerStatClient.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/currency/CryptoCurrency.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';

import '../TestObjectsFactory.dart';
import '../mocks.mocks.dart';

Future<void> main() async {
  MockMemoryStorage mockCache = MockMemoryStorage();
  MockBackgroundTaskScheduler mockBackgroundTaskScheduler = MockBackgroundTaskScheduler();
  MockAppDatabase mockAppDatabase = MockAppDatabase();
  MockLocalJsonReader mockLocalJsonReader = MockLocalJsonReader();
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
        jsonReader: mockLocalJsonReader,
        client: mockMinerStatClient);
  });

  tearDown(() async {});

  test('getCryptoCurrenciesList with refresh', () async {
    List<CryptoCurrency> listCryptoCurrencies = TestObjectsFactory.createCryptoCurrenciesListWithFilters();
    List<CryptoCurrency> result;

    when(mockMinerStatClient.getCryptoCurrenciesList())
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
    when(mockMinerStatClient.getCryptoCurrenciesList())
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

    result = await gateway.getGpusUsedInCalc();

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

    expect(sharedPreferences.getBool('USE_CUSTOM_HASHRATES_KEY'), false);
  });

  test('deleteUsedGpu', () async {
    UsedGpu usedGpu = TestObjectsFactory.createUsedGpuRx570(1);

    when(mockAppDatabase.usedGpuDao).thenReturn(mockUsedGpuDao);
    when(mockUsedGpuDao.deleteById(usedGpu.gpuData.id)).thenAnswer((_) async => _);

    await gateway.deleteUsedGpu(usedGpu.gpuData.id);

    expect(sharedPreferences.getBool('USE_CUSTOM_HASHRATES_KEY'), false);
  });

  test('getHashratesUsedInCalc with custom hashrates', () async {
    Map<String, bool> initialValues = {
      "USE_CUSTOM_HASHRATES_KEY": true,
    };
    SharedPreferences.setMockInitialValues(initialValues);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Gateway gateway = Gateway(
        client: mockMinerStatClient,
        jsonReader: mockLocalJsonReader,
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
      "USE_CUSTOM_HASHRATES_KEY": false,
    };
    SharedPreferences.setMockInitialValues(initialValues);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Gateway gateway = Gateway(
        client: mockMinerStatClient,
        jsonReader: mockLocalJsonReader,
        cache: mockCache,
        database: mockAppDatabase,
        preferences: sharedPreferences,
        backgroundScheduler: mockBackgroundTaskScheduler);

    List<HashAlgorithm> algorithms = TestObjectsFactory.createHashAlgorithms();
    List<HashAlgorithm> result;

    when(mockAppDatabase.usedGpuDao).thenReturn(mockUsedGpuDao);
    when(mockUsedGpuDao.selectAll()).thenAnswer((_) async => TestObjectsFactory.createUsedGpusEntities());

    when(mockLocalJsonReader.getHashAlgorithmsWithZeroValues())
        .thenAnswer((_) async => TestObjectsFactory.createHashAlgorithmsWithZeroValues());
    result = await gateway.getHashratesUsedInCalc();

    expect(result, equals(algorithms));
  });
}
