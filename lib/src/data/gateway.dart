import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';
import 'package:what_to_mine/src/domain/settings.dart';
import 'package:what_to_mine/src/logic/gateway/currencies_gateway.dart';
import 'package:what_to_mine/src/logic/gateway/gpu_gateway.dart';
import 'package:what_to_mine/src/logic/gateway/hash_algorithm_gateway.dart';
import 'package:what_to_mine/src/logic/gateway/scheduler_gateway.dart';
import 'package:what_to_mine/src/logic/gateway/settings_gateway.dart';
import 'package:what_to_mine/src/utils/extensions.dart';
import 'package:what_to_mine/src/utils/scheduler/background_scheduler.dart';

import 'cache/memory_storage.dart';
import 'client/api_client.dart';
import 'db/app_database.dart';
import 'db/entities/used_gpu_entity.dart';
import 'db/entities/user_hash_algorithm_entity.dart';
import 'json_reader/data_reader.dart';

class Gateway implements ICurrenciesGateway, IGpuGateway, IHashAlgorithmGateway, ISchedulerGateway, ISettingsGateway {
  final ApiClient _client;
  final DataReader _jsonReader;
  final MemoryStorage _cache;
  final AppDatabase _appDatabase;
  final SharedPreferences _preferences;
  final IBackgroundTaskScheduler _backgroundScheduler;
  static const String _useCustomHashratesKey = 'h';
  static const String _settingsKey = 's';

  Gateway(
      {required ApiClient client,
      required DataReader jsonReader,
      required MemoryStorage cache,
      required database,
      required SharedPreferences preferences,
      required IBackgroundTaskScheduler backgroundScheduler})
      : _client = client,
        _jsonReader = jsonReader,
        _cache = cache,
        _appDatabase = database,
        _preferences = preferences,
        _backgroundScheduler = backgroundScheduler;

  final StreamController<bool> _usedGpuChanged = StreamController<bool>.broadcast();
  final StreamController<bool> _userHashrateChanged = StreamController<bool>.broadcast();
  final StreamController<bool> _electricityCostChanged = StreamController<bool>();

  @override
  Stream<bool> usedGpuChangedStream() => _usedGpuChanged.stream;

  @override
  Stream<bool> userHashrateChangedStream() => _userHashrateChanged.stream;

  @override
  Stream<bool> electricityCostChangedStream() => _electricityCostChanged.stream;

  Future<void> dispose() async {
    _usedGpuChanged.close();
    _userHashrateChanged.close();
    _electricityCostChanged.close();
  }

  // ???????????????? ???????????? ??????????????????????
  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesList({required bool isNeedFresh}) async {
    List<CryptoCurrency> list;
    List<CryptoCurrency>? listInCache;
    if (!isNeedFresh) listInCache = _cache.getCryptoCurrencies();

    if (listInCache != null && listInCache.isNotEmpty && !isNeedFresh) {
      list = listInCache;
    } else {
      list = await _client.getCryptoCurrenciesListFromApi();
      list = _filterCryptoCurrencies(list);
      for (var element in list) {
        element.iconLink = iconURL + element.coin.toLowerCase() + '.png';
      }
      _cache.putCryptoCurrencies(list);
    }
    return list;
  }

  // ?????????????????? ???????????? ???????????????????? ????????????????????????
  List<CryptoCurrency> _filterCryptoCurrencies(List<CryptoCurrency> list) {
    list = list
        .where(
            (element) => element.isCoin() && element.hasPrice() && element.hasReward() && element.volumeMoreThan(100))
        .toList();
    return list.unique((x) => x.name);
  }

  // ???????????????? ???????????? ??????????????????
  @override
  Future<List<Gpu>?> getGPUList() async {
    return _jsonReader.getGPUList();
  }

  // ???????????????? ???????????? ???????????????????????? ?? ???????????????? ??????????????????
  @override
  Future<List<UsedGpu>> getUsedGPUList() async {
    List<UsedGpu> result = [];
    List<UsedGpuEntity> listEntity = (await _appDatabase.usedGpuDao.selectAll());
    for (var element in listEntity) {
      result.add(element.usedGpu);
    }
    return result;
  }

  // ???????????????? ???????????????????????? ?? ???????????????? ????????????????????
  @override
  Future<void> addUsedGpu(UsedGpu usedGpu) async {
    // ??????????????????, ???????? ?????????? ???????????????????? ?????? ????????, ???? ?????????????????? ???? ????????????????????
    UsedGpuEntity? usedGpuEntity = await _appDatabase.usedGpuDao.selectById(usedGpu.gpuData.id);
    if (usedGpuEntity != null) {
      int oldQuantity = usedGpuEntity.usedGpu.quantity;
      if (oldQuantity + usedGpu.quantity > 1000) throw Exception('error_quantity_gpu_add'.tr());
      UsedGpu newUsedGpu = (UsedGpuBuilder()
            ..quantity = oldQuantity + usedGpu.quantity
            ..gpuData = usedGpu.gpuData.toBuilder())
          .build();
      await _appDatabase.usedGpuDao.insert(UsedGpuEntity(newUsedGpu));
      _usedGpuChanged.add(true);
    } else {
      await _appDatabase.usedGpuDao.insert(UsedGpuEntity(usedGpu));
      _usedGpuChanged.add(true);
    }
    _preferences.setBool(_useCustomHashratesKey, false);
  }

  // ?????????????? ???????????????????????? ?? ???????????????? ????????????????????
  @override
  Future<void> deleteUsedGpu(String id) async {
    await _appDatabase.usedGpuDao.deleteById(id);
    _usedGpuChanged.add(true);
    _preferences.setBool(_useCustomHashratesKey, false);
  }

  // ???????????????? ???????????? ?????????????????? ?????????????????? ???????????????????????? ?? ???????????????? ??????????????????
  @override
  Future<List<HashAlgorithm>> getHashratesUsedInCalc() async {
    List<HashAlgorithm> result = [];

    bool? useCustomHashrates = _preferences.getBool(_useCustomHashratesKey);

    // ???????? ???????????????????????? ?????????????????? ????????????????, ???? ???????????? ?????????? ???? ???? ????
    if (useCustomHashrates != null && useCustomHashrates) {
      var userHashAlgorithms = await _appDatabase.userHashAlgorithmDao.selectAll();
      for (var entity in userHashAlgorithms) {
        result.add(entity.algorithm);
      }
    } else {
      result = await _jsonReader.getHashAlgorithmsWithZeroValues();
      List<UsedGpu> usedGpus = await getUsedGPUList();

      for (var gpu in usedGpus) {
        print(gpu.gpuData.name + " x" + gpu.quantity.toString());
        for (var element in gpu.gpuData.hashAlgorithms) {
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
        }
      }
    }
    _cache.putEditedHashrates(result);
    return result;
  }

  // ???????????????? ?????????? ???? ???????? ??????????????????????????
  @override
  Future<List<Earnings>> getEarningsList({required bool isNeedFresh}) async {
    double electricityCost = (await getSettings()).electricityCost;
    List<CryptoCurrency> currencies = await getCryptoCurrenciesList(isNeedFresh: isNeedFresh);
    currencies = _filterCryptoCurrencies(currencies);
    List<HashAlgorithm?> hashratesUsedInCalc = await getHashratesUsedInCalc();
    List<Earnings> result = [];

    //?????????????? ????????????, ???? ???????????????????? ?????????????? ???????? ???????????????? ?? gpu.json
    for (var currency in currencies) {
      HashAlgorithm? algorithm;
      try {
        algorithm = hashratesUsedInCalc
            .singleWhere((element) => element!.name.toLowerCase() == currency.algorithm.toLowerCase());
      } on StateError catch (_) {}
      if (algorithm != null) {
        Earnings earning = Earnings.create(currency, algorithm, electricityCost);
        result.add(earning);
      }
    }
    // ?????????????????? ????????????, ???????????????????? ????????????, ?????????????? ???????? ?????????? 0
    result = result.where((element) => element.monthEarningsMoreThan(0.0001) == true).toList();
    return result;
  }

  // ???????????????? ???????????????? ???? ????????
  @override
  Future<List<HashAlgorithm>> getEditedHashratesFromCache() async {
    return _cache.getEditedHashrate();
  }

  //???????????????? ???????????????? ?? ????????
  @override
  Future<void> updateEditedHashrateInCache(String name, double hashrateValue) async {
    return _cache.putEditedHashrate(name, hashrateValue);
  }

  //???????????????? ???????????????? ?? ????????
  @override
  Future<void> updateEditedPowerInCache(String name, int powerValue) async {
    return _cache.putEditedPower(name, powerValue);
  }

  // ???????????????? ???????????????? ?? ????
  @override
  Future<void> updateHashratesInDB(List<HashAlgorithm> hashrates) async {
    for (var element in hashrates) {
      _appDatabase.userHashAlgorithmDao.insert(UserHashAlgorithmEntity(element));
    }
    _preferences.setBool(_useCustomHashratesKey, true);
    _userHashrateChanged.add(true);
  }

  // ???????????????? ??????????????
  @override
  Future<void> enableScheduler(int interval) async {
    return await _backgroundScheduler.enable(interval);
  }

  // ?????????????????? ??????????????
  @override
  Future<void> disableScheduler() async {
    return await _backgroundScheduler.disable();
  }

  // ???????????????? ??????????????????
  @override
  Future<Settings> getSettings() async {
    String? settingsString = _preferences.getString(_settingsKey);
    return settingsString != null ? Settings.fromJsonString(settingsString) : Settings();
  }

  // ???????????????????? ??????????????????
  @override
  Future<void> setSettings(Settings settings) {
    return _preferences.setString(_settingsKey, settings.toJsonString());
  }

  @override
  Future<void> onElectricityCostChanged() async {
    _electricityCostChanged.add(true);
  }
}
