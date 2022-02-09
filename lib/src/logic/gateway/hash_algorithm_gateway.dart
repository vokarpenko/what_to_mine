import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';

abstract class IHashAlgorithmGateway {
  // Получить список суммарных хэшрейтов используемых в расчетах видеокарт
  Future<List<HashAlgorithm>> getHashratesUsedInCalc();

  // Получить список изменненых хэшрейтов из кэша
  Future<List<HashAlgorithm>> getEditedHashratesFromCache();

  // Обновить хэшрейт в кэше
  Future<void> updateEditedHashrateInCache(String name, double hashrateValue);

  // Обновить мощность в кэше
  Future<void> updateEditedPowerInCache(String name, int powerValue);

  // Обновить хэшрейты в бд
  Future<void> updateHashratesInDB(List<HashAlgorithm> hashrates);

  //Подписка на изменения используемых видеокарт
  Stream<bool> userHashrateChangedStream();
}
