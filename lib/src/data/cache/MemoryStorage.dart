import 'dart:collection';

import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/currency/CryptoCurrency.dart';

// Хранилище в памяти
class MemoryStorage {
  final String _cryptoCurrencyKey = 'CryptoCurrencyList';

  //TODO скорее всего отсюда нужно убрать map и оставить просто list
  LinkedHashMap<String, List<CryptoCurrency>> _cryptoCurrencyCache = new LinkedHashMap<String, List<CryptoCurrency>>();
  List<HashAlgorithm> _editedHashrateCache = [];

  // Добавить данные криптовалют в кэш
  void putCryptoCurrency(List<CryptoCurrency> cryptoCurrency) {
    if (_cryptoCurrencyCache.containsKey(_cryptoCurrencyKey))
      _cryptoCurrencyCache.update(_cryptoCurrencyKey, (value) => value = cryptoCurrency);
    else
      _cryptoCurrencyCache.putIfAbsent(_cryptoCurrencyKey, () => cryptoCurrency);
  }

  // Получить данные криптовалют из кэша
  List<CryptoCurrency>? getCryptoCurrency() {
    return _cryptoCurrencyCache[_cryptoCurrencyKey];
  }

  // Очистить кэш данных криптовалют
  void clearCryptoCurrencyCache() {
    _cryptoCurrencyCache.clear();
  }

  // Добавить новые данные хэшрейтов в кэш
  void putEditedHashrates(List<HashAlgorithm> hashrates) {
    if (_editedHashrateCache.isNotEmpty) _editedHashrateCache.clear();
    _editedHashrateCache.addAll(hashrates);
  }

  // Добавить новые данные хэшрейта в кэш
  void putEditedHashrate(String name, double hashrateValue) {
    int index = _editedHashrateCache.indexWhere((element) => element.name == name);
    _editedHashrateCache[index] = _editedHashrateCache[index].rebuild((b) => b..hashrate = hashrateValue);
  }

  // Получить данные измененых хэшрейтов из кэша
  List<HashAlgorithm> getEditedHashrate() => _editedHashrateCache;

  // Очистить кэш данных  измененых хэшрейтов
  void clearEditedHashrateCache() {
    _editedHashrateCache.clear();
  }
}
