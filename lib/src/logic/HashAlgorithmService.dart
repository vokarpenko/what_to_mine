import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';

import 'gateway/IGateway.dart';

class HashAlgorithmService {
  final IGateway _gateway;

  HashAlgorithmService({required IGateway gateway}) : _gateway = gateway;

  // Получить список суммарных хэшрейтов используемых в расчетах видеокарт
  Future<List<HashAlgorithm>> getHashratesUsedInCalc() async {
    return _gateway.getHashratesUsedInCalc();
  }

  // Получить список изменненых хэшрейтов из кэша
  Future<List<HashAlgorithm>> getEditedHashratesFromCache() async {
    return _gateway.getEditedHashratesFromCache();
  }

  // Обновить хэшрейт в кэше
  Future<void> updateEditedHashrateInCache(String name, double hashrateValue) async {
    return _gateway.updateEditedHashrateInCache(name, hashrateValue);
  }

  // Обновить мощность в кэше
  Future<void> updateEditedPowerInCache(String name, int powerValue) async {
    return _gateway.updateEditedPowerInCache(name, powerValue);
  }

  // Обновить хэшрейты в бд
  Future<void> updateHashratesInDB(List<HashAlgorithm> hashrates) async {
    return _gateway.updateHashratesInDB(hashrates);
  }

  //Подписка на изменения используемых видеокарт
  Stream<bool> onUserHashrateChanged() {
    return _gateway.onUserHashrateChanged();
  }
}
