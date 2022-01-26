import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/data/Scheduler/IBackgroundTaskScheduler.dart';
import 'package:what_to_mine/src/data/cache/MemoryStorage.dart';
import 'package:what_to_mine/src/data/client/IMinerStatClient.dart';
import 'package:what_to_mine/src/data/db/entities/UsedGpuEntity.dart';
import 'package:what_to_mine/src/data/db/entities/UserHashAlgorithmEntity.dart';
import 'package:what_to_mine/src/data/jsonReader/ILocalJsonReader.dart';
import 'package:what_to_mine/src/domain/Settings.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';
import 'package:what_to_mine/src/logic/gateway/IGateway.dart';
import 'package:what_to_mine/src/utils/Extensions.dart';

import '../domain/currency/CryptoCurrency.dart';
import 'Scheduler/BackgroundTaskScheduler.dart';
import 'db/AppDatabase.dart';

class Gateway implements IGateway {
  final IMinerStatClient _client;
  final ILocalJsonReader _jsonReader;
  final MemoryStorage _cache;
  final AppDatabase _appDatabase;
  final SharedPreferences _preferences;
  final IBackgroundTaskScheduler _backgroundScheduler;
  static const String _useCustomHashratesKey = 'USE_CUSTOM_HASHRATES_KEY';
  static const String _settingsKey = 'SETTINGS';

  Gateway(
      {required IMinerStatClient client,
      required ILocalJsonReader jsonReader,
      required MemoryStorage cache,
      required database,
      required SharedPreferences preferences,
      required BackgroundTaskScheduler backgroundScheduler})
      : _client = client,
        _jsonReader = jsonReader,
        _cache = cache,
        _appDatabase = database,
        _preferences = preferences,
        _backgroundScheduler = backgroundScheduler;

  final StreamController<bool> _onUsedGpuChanged = StreamController<bool>.broadcast();
  final StreamController<bool> _onUserHashrateChanged = StreamController<bool>.broadcast();
  final StreamController<bool> _onElectricityCostChanged = StreamController<bool>();

  @override
  Stream<bool> onUsedGpuChanged() => _onUsedGpuChanged.stream;

  @override
  Stream<bool> onUserHashrateChanged() => _onUserHashrateChanged.stream;

  @override
  Stream<bool> onElectricityCostChanged() => _onElectricityCostChanged.stream;

  Future<void> dispose() async {
    _onUsedGpuChanged.close();
    _onUserHashrateChanged.close();
    _onElectricityCostChanged.close();
  }

  // Получить список криптовалют
  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesList({required bool isNeedFresh}) async {
    List<CryptoCurrency> list;
    List<CryptoCurrency>? listInCache;
    if (!isNeedFresh) listInCache = _cache.getCryptoCurrencies();

    if (listInCache != null && listInCache.isNotEmpty && !isNeedFresh) {
      list = listInCache;
    } else {
      list = await _client.getCryptoCurrenciesList();
      list = _filterCryptoCurrencies(list);
      list.forEach((element) {
        element.iconLink = Links.iconsLink + element.coin.toLowerCase() + ".png";
      });
      _cache.putCryptoCurrencies(list);
    }
    return list;
  }

  // Фильтруем только подходящие криптовалюты
  List<CryptoCurrency> _filterCryptoCurrencies(List<CryptoCurrency> list) {
    list = list
        .where(
            (element) => element.isCoin() && element.hasPrice() && element.hasReward() && element.volumeMoreThan(100))
        .toList();
    return list.unique((x) => x.name);
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
          if (element.hashrate != null && element.power != null) {
            int currentAlgorithmIndex = result.indexWhere((r) => r.name == element.name);
            if (currentAlgorithmIndex != -1) {
              double currentAlgorithmHashrate = result[currentAlgorithmIndex].hashrate!;
              int currentAlgorithmPower = result[currentAlgorithmIndex].power!;
              result[currentAlgorithmIndex] = element.rebuild((b) => b
                ..hashrate = (currentAlgorithmHashrate + element.hashrate! * gpu.quantity)
                ..power = (currentAlgorithmPower + element.power! * gpu.quantity));
            }
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
    double electricityCost = (await getSettings()).electricityCost;
    List<CryptoCurrency> currencies = await getCryptoCurrenciesList(isNeedFresh: isNeedFresh);
    currencies = _filterCryptoCurrencies(currencies);
    List<HashAlgorithm?> hashratesUsedInCalc = await getHashratesUsedInCalc();
    List<Earnings> result = [];

    //Находим монеты, по алгоритмам которых есть хэшрейты в gpu.json
    currencies.forEach((currency) {
      HashAlgorithm? algorithm;
      try {
        algorithm = hashratesUsedInCalc
            .singleWhere((element) => element!.name.toLowerCase() == currency.algorithm.toLowerCase());
      } on StateError catch (_) {}
      if (algorithm != null) {
        Earnings earning = Earnings.create(currency, algorithm, electricityCost);
        result.add(earning);
      }
    });
    // Фильтруем список, отбрасывая монеты, которые дают доход 0
    result = result.where((element) => element.monthEarningsMoreThan(0.0001) == true).toList();
    return result;
  }

  // Получить хэшрейты из кэша
  @override
  Future<List<HashAlgorithm>> getEditedHashratesFromCache() async {
    return _cache.getEditedHashrate();
  }

  //Обновить хэшрейты в кэшэ
  @override
  Future<void> updateEditedHashrateInCache(String name, double hashrateValue) async {
    return _cache.putEditedHashrate(name, hashrateValue);
  }

  //Обновить хэшрейты в кэшэ
  @override
  Future<void> updateEditedPowerInCache(String name, int powerValue) async {
    return _cache.putEditedPower(name, powerValue);
  }

  // Обновить хэшрейты в БД
  @override
  Future<void> updateHashratesInDB(List<HashAlgorithm> hashrates) async {
    hashrates.forEach((element) {
      _appDatabase.userHashAlgorithmDao.insert(UserHashAlgorithmEntity(element));
    });
    _preferences.setBool(_useCustomHashratesKey, true);
    _onUserHashrateChanged.add(true);
  }

  // Включить шедулер
  @override
  Future<void> enableScheduler(int interval) async {
    return await _backgroundScheduler.enable(interval);
  }

  // Отключить шедулер
  @override
  Future<void> disableScheduler() async {
    return await _backgroundScheduler.disable();
  }

  // Включен ли шедулер?
  @override
  Future<bool> isSchedulerEnabled() async {
    return (await getSettings()).notificationIsEnabled;
  }

  // Получить настройки
  @override
  Future<Settings> getSettings() async {
    String? settingsString = _preferences.getString(_settingsKey);
    return settingsString != null ? Settings.fromJsonString(settingsString) : Settings();
  }

  // Установить настройки
  @override
  Future<void> setSettings(Settings settings) {
    return _preferences.setString(_settingsKey, settings.toJsonString());
  }

  @override
  Future<void> setElectricityCost(double cost) async {
    Settings settings = await getSettings();
    settings.electricityCost = cost;
    _onElectricityCostChanged.add(true);
    return setSettings(settings);
  }
}
