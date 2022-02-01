import '../../domain/currency/CryptoCurrency.dart';

abstract class IMinerStatClient {
  // Получить список криптовалют из api
  Future<List<CryptoCurrency>> getCryptoCurrenciesListFromApi();
}
