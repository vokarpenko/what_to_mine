import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/domain/algorithms/algorithm_names.dart';
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
import 'package:what_to_mine/src/utils/scheduler/background_scheduler.dart';

import 'cache/memory_storage.dart';
import 'client/api_client.dart';
import 'db/app_database.dart';
import 'db/entities/used_gpu_entity.dart';
import 'db/entities/user_hash_algorithm_entity.dart';

class Gateway
    implements
        ICurrenciesGateway,
        IGpuGateway,
        IHashAlgorithmGateway,
        ISchedulerGateway,
        ISettingsGateway {
  final ApiClient _client;
  final MemoryStorage _cache;
  final AppDatabase _appDatabase;
  final SharedPreferences _preferences;
  final IBackgroundTaskScheduler _backgroundScheduler;
  static const String _useCustomHashratesKey = 'h';
  static const String _settingsKey = 's';

  Gateway({
    required this._client,
    required this._cache,
    required database,
    required this._preferences,
    required this._backgroundScheduler,
  }) : _appDatabase = database;

  final StreamController<bool> _usedGpuChanged =
      StreamController<bool>.broadcast();
  final StreamController<bool> _userHashrateChanged =
      StreamController<bool>.broadcast();
  final StreamController<bool> _electricityCostChanged =
      StreamController<bool>();

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

  // Получить список криптовалют
  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesList({
    required bool isNeedFresh,
  }) async {
    final currencies = await _client.getCryptoCurrenciesListFromApi(
      forceRefresh: isNeedFresh,
    );
    _cache.putCryptoCurrencies(currencies);
    return currencies;
  }

  @override
  Future<List<Gpu>?> getGPUList() => _client.getGPUListFromApi();

  // Получить список используемых в расчетах видеокарт
  @override
  Future<List<UsedGpu>> getUsedGPUList() async {
    List<UsedGpu> result = [];
    List<UsedGpuEntity> listEntity = (await _appDatabase.usedGpuDao
        .selectAll());
    for (var element in listEntity) {
      result.add(element.usedGpu);
    }
    return result;
  }

  // Добавить используемую в расчетах видеокарту
  @override
  Future<void> addUsedGpu(UsedGpu usedGpu) async {
    // Проверяем, если такая видеокарта уже есть, то суммируем их количество
    UsedGpuEntity? usedGpuEntity = await _appDatabase.usedGpuDao.selectById(
      usedGpu.gpuData.id,
    );
    if (usedGpuEntity != null) {
      int oldQuantity = usedGpuEntity.usedGpu.quantity;
      if (oldQuantity + usedGpu.quantity > 1000) {
        throw Exception('error_quantity_gpu_add'.tr());
      }
      UsedGpu newUsedGpu =
          (UsedGpuBuilder()
                ..quantity = oldQuantity + usedGpu.quantity
                ..gpuData = usedGpu.gpuData.toBuilder())
              .build();
      await _appDatabase.usedGpuDao.insert(UsedGpuEntity(newUsedGpu));
    } else {
      await _appDatabase.usedGpuDao.insert(UsedGpuEntity(usedGpu));
    }
    await _preferences.setBool(_useCustomHashratesKey, false);
    _usedGpuChanged.add(true);
  }

  // Удалить используемую в расчетах видеокарту
  @override
  Future<void> deleteUsedGpu(String id) async {
    await _appDatabase.usedGpuDao.deleteById(id);
    await _preferences.setBool(_useCustomHashratesKey, false);
    _usedGpuChanged.add(true);
  }

  // Получить список суммарных хэшрейтов используемых в расчетах видеокарт
  @override
  Future<List<HashAlgorithm>> getHashratesUsedInCalc() async {
    List<HashAlgorithm> result;
    if (_preferences.getBool(_useCustomHashratesKey) ?? false) {
      final entities = await _appDatabase.userHashAlgorithmDao.selectAll();
      result = entities.map((entity) => entity.algorithm).toList();
    } else {
      final registered = await _client.getHashAlgorithmsFromApi();
      final names = {
        for (final algorithm in registered)
          algorithmKey(algorithm.name): algorithm.name,
      };
      final hashes = <String, double>{};
      final powers = <String, int>{};
      for (final used in await getUsedGPUList()) {
        for (final algorithm in used.gpuData.hashAlgorithms) {
          if (algorithm.hashrate == null || algorithm.power == null) continue;
          final key = algorithmKey(algorithm.name);
          names.putIfAbsent(key, () => algorithm.name);
          hashes[key] =
              (hashes[key] ?? 0) +
              (algorithm.hashrate ?? 0) *
                  algorithm.hashrateCoefficient *
                  used.quantity;
          powers[key] =
              (powers[key] ?? 0) + (algorithm.power ?? 0) * used.quantity;
        }
      }
      result = names.entries.map((entry) {
        final hashesPerSecond = hashes[entry.key] ?? 0;
        final coefficient = hashCoefficient(hashesPerSecond);
        return HashAlgorithm(
          (builder) => builder
            ..name = entry.value
            ..hashrate = hashesPerSecond / coefficient
            ..hashrateCoefficient = coefficient
            ..power = powers[entry.key] ?? 0,
        );
      }).toList();
    }
    _cache.putEditedHashrates(result);
    return result;
  }

  @override
  Future<List<Earnings>> getEarningsList({required bool isNeedFresh}) async {
    if (!(_preferences.getBool(_useCustomHashratesKey) ?? false) &&
        (await getUsedGPUList()).isEmpty) {
      return [];
    }
    final settings = await getSettings();
    final algorithms = await getHashratesUsedInCalc();
    return _client.calculateEarningsFromApi(
      algorithms: algorithms,
      electricityCost: settings.electricityCost,
      forceRefresh: isNeedFresh,
    );
  }

  // Получить хэшрейты из кэша
  @override
  Future<List<HashAlgorithm>> getEditedHashratesFromCache() async {
    return _cache.getEditedHashrate();
  }

  //Обновить хэшрейты в кэшэ
  @override
  Future<void> updateEditedHashrateInCache(
    String name,
    double hashrateValue,
  ) async {
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
    for (var element in hashrates) {
      await _appDatabase.userHashAlgorithmDao.insert(
        UserHashAlgorithmEntity(element),
      );
    }
    await _preferences.setBool(_useCustomHashratesKey, true);
    _userHashrateChanged.add(true);
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

  // Получить настройки
  @override
  Future<Settings> getSettings() async {
    String? settingsString = _preferences.getString(_settingsKey);
    return settingsString != null
        ? Settings.fromJsonString(settingsString)
        : Settings();
  }

  // Установить настройки
  @override
  Future<void> setSettings(Settings settings) {
    return _preferences.setString(_settingsKey, settings.toJsonString());
  }

  @override
  Future<void> onElectricityCostChanged() async {
    _electricityCostChanged.add(true);
  }
}
