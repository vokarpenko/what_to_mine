import 'package:what_to_mine/src/domain/Settings.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';

import '../../domain/currency/CryptoCurrency.dart';

abstract class IGateway {
  // Получить список криптовалют
  Future<List<CryptoCurrency>> getCryptoCurrenciesList({required bool isNeedFresh});

  // Получить список видеокарт
  Future<List<Gpu>?> getGPUList();

  // Получить список используемых в расчетах видеокарт
  Future<List<UsedGpu>?> getGpusUsedInCalc();

  // Добавить используемую в расчетах видеокарту
  Future<void> addUsedGpu(UsedGpu usedGpu);

  // Удалить используемую в расчетах видеокарту
  Future<void> deleteUsedGpu(String id);

  // Получить список суммарных хэшрейтов используемых в расчетах видеокарт
  Future<List<HashAlgorithm>> getHashratesUsedInCalc();

  // Получить доход по всем криптовалютам
  Future<List<Earnings>> getEarningsList({required bool isNeedFresh});

  // Подписка на изменение пользовательских хэшрейтов
  Stream<bool> onUserHashrateChanged();

  // Подписка на изменение стоимости электроэнергии
  Stream<bool> onElectricityCostChanged();

  // Получить список измененных хэшрейтов из кэша
  Future<List<HashAlgorithm>> getEditedHashratesFromCache();

  // Обновить изменный хэшрейт в кэше
  Future<void> updateEditedHashrateInCache(String name, double hashrateValue);

  // Обновить изменную мощность в кэше
  Future<void> updateEditedPowerInCache(String name, int powerValue);

  // Обновить хэшрейты в базе данных
  Future<void> updateHashratesInDB(List<HashAlgorithm> hashrates);

  // Включить планировщик задач
  Future<void> enableScheduler(int interval);

  // Отключить планировщик задач
  Future<void> disableScheduler();

  // Получить настройку "Включен ли планировщик задач"
  Future<bool> isSchedulerEnabled();

  // Получить настройки
  Future<Settings> getSettings();

  // Сохранить настройки
  Future<void> setSettings(Settings settings);

  Future<void> setElectricityCost(double cost);
}
