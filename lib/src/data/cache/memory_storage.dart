import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';

// Хранилище в памяти
class MemoryStorage {
  final List<CryptoCurrency> _cryptoCurrencyCache = [];
  final List<HashAlgorithm> _editedHashrateCache = [];

  // Добавить данные криптовалют в кэш
  void putCryptoCurrencies(List<CryptoCurrency> cryptoCurrency) {
    if (_cryptoCurrencyCache.isNotEmpty) _cryptoCurrencyCache.clear();
    _cryptoCurrencyCache.addAll(cryptoCurrency);
  }

  // Получить данные криптовалют из кэша
  List<CryptoCurrency>? getCryptoCurrencies() => _cryptoCurrencyCache;

  // Очистить кэш данных криптовалют
  void clearCryptoCurrenciesCache() => _cryptoCurrencyCache.clear();

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

  // Добавить новые данные мощности в кэш
  void putEditedPower(String name, int power) {
    int index = _editedHashrateCache.indexWhere((element) => element.name == name);
    _editedHashrateCache[index] = _editedHashrateCache[index].rebuild((b) => b..power = power);
  }

  // Получить данные измененых хэшрейтов из кэша
  List<HashAlgorithm> getEditedHashrate() => _editedHashrateCache;

  // Очистить кэш данных  измененых хэшрейтов
  void clearEditedHashrateCache() => _editedHashrateCache.clear();
}
