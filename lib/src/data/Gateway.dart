import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/data/cache/MemoryStorage.dart';
import 'package:what_to_mine/src/data/client/IMinerStatClient.dart';
import 'package:what_to_mine/src/data/db/entities/UsedGpuEntity.dart';
import 'package:what_to_mine/src/data/db/entities/UserHashAlgorithmEntity.dart';
import 'package:what_to_mine/src/data/local/ILocalJsonReader.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';
import 'package:what_to_mine/src/logic/gateway/IGateway.dart';

import '../domain/currency/CryptoCurrency.dart';
import 'db/AppDatabase.dart';

class Gateway implements IGateway {
  final IMinerStatClient _client;
  final ILocalJsonReader _jsonReader;
  final MemoryStorage _cache;
  final AppDatabase _appDatabase;
  final SharedPreferences _preferences;

  static const String _useCustomHashratesKey = "USE_CUSTOM_HASHRATES_KEY";

  Gateway(
      {required IMinerStatClient client,
      required ILocalJsonReader jsonReader,
      required MemoryStorage cache,
      required database,
      required SharedPreferences preferences})
      : _client = client,
        _jsonReader = jsonReader,
        _cache = cache,
        _appDatabase = database,
        _preferences = preferences;

  final StreamController<bool> _onUsedGpuChanged = StreamController<bool>.broadcast();
  final StreamController<bool> _onUserHashrateChanged = StreamController<bool>.broadcast();

  @override
  Stream<bool> onUsedGpuChanged() => _onUsedGpuChanged.stream;

  @override
  Stream<bool> onUserHashrateChanged() => _onUserHashrateChanged.stream;

  // Получить список криптовалют
  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesList({required bool isNeedFresh}) async {
    List<CryptoCurrency> list;

    List<CryptoCurrency>? listInCache = _cache.getCryptoCurrency();

    if (listInCache != null && listInCache.isNotEmpty && !isNeedFresh) {
      list = listInCache;
    } else {
      list = await _client.getCryptoCurrenciesList();
      list = list
          .where((element) =>
              element.type == "coin" && element.price != -1 && element.reward != -1 && element.volume > 1000)
          .toList();
      list.forEach((element) {
        element.iconLink = Links.iconsLink + element.coin.toLowerCase() + ".png";
      });
      _cache.putCryptoCurrency(list);
    }
    return list;
  }

  // Получить список видеокарт
  @override
  Future<List<Gpu>?> getGPUList() async {
    return _jsonReader.getGPUList();
  }

  // Получить список используемых в расчетах видеокарт
  @override
  Future<List<UsedGpu>> getGpusUsedInCalc() async {
    List<UsedGpu> result = [];
    List<UsedGpuEntity> listEntity = (await this._appDatabase.usedGpuDao.selectAll());
    listEntity.forEach((element) {
      result.add(element.usedGpu);
    });
    return result;
  }

  // Добавить используемую в расчетах видеокарту
  @override
  Future<void> addUsedGpu(UsedGpu usedGpu) async {
    // Проверяем, если такая видеокарта уже есть, то суммируем их количество
    UsedGpuEntity? usedGpuEntity = await _appDatabase.usedGpuDao.selectById(usedGpu.gpuData.id);
    if (usedGpuEntity != null) {
      int oldQuantity = usedGpuEntity.usedGpu.quantity;
      UsedGpu newUsedGpu = (UsedGpuBuilder()
            ..quantity = oldQuantity + usedGpu.quantity
            ..gpuData = usedGpu.gpuData.toBuilder())
          .build();
      await _appDatabase.usedGpuDao.insert(UsedGpuEntity(newUsedGpu));
      _onUsedGpuChanged.add(true);
    } else {
      await _appDatabase.usedGpuDao.insert(UsedGpuEntity(usedGpu));
      _onUsedGpuChanged.add(true);
    }
    _preferences.setBool(_useCustomHashratesKey, false);
  }

  // Удалить используемую в расчетах видеокарту
  @override
  Future<void> deleteUsedGpu(String id) async {
    await _appDatabase.usedGpuDao.deleteById(id);
    _onUsedGpuChanged.add(true);
    _preferences.setBool(_useCustomHashratesKey, false);
  }

  // Получить список суммарных хэшрейтов используемых в расчетах видеокарт
  @override
  Future<List<HashAlgorithm>> getHashratesUsedInCalc() async {
    print("***getHashratesUsedInCalc***");

    List<HashAlgorithm> result = [];

    bool? useCustomHashrates = _preferences.getBool(_useCustomHashratesKey);

    // Если используются кастомные хэшрейты, то просто берем их из бд
    if (useCustomHashrates != null && useCustomHashrates) {
      var userHashAlgorithms = await _appDatabase.userHashAlgorithmDao.selectAll();
      userHashAlgorithms.forEach((entity) {
        result.add(entity.algorithm);
      });
    } else {
      result = await _jsonReader.getHashAlgorithmsWithZeroValues();
      List<UsedGpu> usedGpus = await getGpusUsedInCalc();

      usedGpus.forEach((gpu) {
        print(gpu.gpuData.name + " x" + gpu.quantity.toString());
        gpu.gpuData.hashAlgorithms.forEach((element) {
          if (element.hashrate != null) {
            int currentAlgorithmIndex = result.indexWhere((r) => r.name == element.name);
            double currentAlgorithmHashrate = result[currentAlgorithmIndex].hashrate!;
            result[currentAlgorithmIndex] =
                element.rebuild((b) => b..hashrate = (currentAlgorithmHashrate + (element.hashrate! * gpu.quantity)));
          }
        });
      });
    }
    _cache.putEditedHashrates(result);
    return result;
  }

  // Получить доход по всем криптовалютам
  @override
  Future<List<Earnings>> getEarningsList({required bool isNeedFresh}) async {
    List<CryptoCurrency> currencies = await getCryptoCurrenciesList(isNeedFresh: isNeedFresh);
    List<HashAlgorithm> hashratesUsedInCalc = await getHashratesUsedInCalc();
    List<Earnings> result = [];

    currencies.forEach((currency) {
      HashAlgorithm algorithm =
          hashratesUsedInCalc.singleWhere((element) => element.name.toLowerCase() == currency.algorithm.toLowerCase());
      Earnings earning = Earnings.calc(currency, algorithm.hashrate!, algorithm.hashrateCoefficient);
      result.add(earning);
    });
    // Фильтруем список, отбрасывая монеты, которые дают доход 0
    result = result.where((element) => element.monthEarningInCrypto > 0).toList();
    return result;
  }

  @override
  Future<List<HashAlgorithm>> getEditedHashratesFromCache() async {
    return _cache.getEditedHashrate();
  }

  @override
  Future<void> updateEditedHashrateInCache(String name, double hashrateValue) async {
    return _cache.putEditedHashrate(name, hashrateValue);
  }

  @override
  Future<void> updateHashratesInDB(List<HashAlgorithm> hashrates) async {
    hashrates.forEach((element) {
      _appDatabase.userHashAlgorithmDao.insert(UserHashAlgorithmEntity(element));
    });
    _preferences.setBool(_useCustomHashratesKey, true);
    _onUserHashrateChanged.add(true);
  }
}
