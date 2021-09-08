import 'dart:collection';

import 'package:what_to_mine/src/domain/currency/CryptoCurrency.dart';

// Хранилище в памяти
class MemoryStorage {
  final String _cryptoCurrencyListKey = "CryptoCurrencyList";
  LinkedHashMap<String, List<CryptoCurrency>> _cryptoCurrencyCache = new LinkedHashMap<String, List<CryptoCurrency>>();

  // Добавить данные криптовалют в кэш
  void putCryptoCurrency(List<CryptoCurrency> cryptoCurrency) {
    if (_cryptoCurrencyCache.containsKey(_cryptoCurrencyListKey))
      _cryptoCurrencyCache.update(_cryptoCurrencyListKey, (value) => value = cryptoCurrency);
    else
      _cryptoCurrencyCache.putIfAbsent(_cryptoCurrencyListKey, () => cryptoCurrency);
  }

  // Получить данные криптовалют из кэша
  List<CryptoCurrency>? getCryptoCurrency() {
    return _cryptoCurrencyCache[_cryptoCurrencyListKey];
  }

  // Очистить кэш данных криптовалют
  void clearCryptoCurrencyCache() {
    _cryptoCurrencyCache.clear();
  }
}
