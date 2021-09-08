import '../../domain/currency/CryptoCurrency.dart';

abstract class IMinerStatClient {
  // Получить список криптовалют
  Future<List<CryptoCurrency>> getCryptoCurrenciesList();
}
