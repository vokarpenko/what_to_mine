import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';

abstract class ApiClient {
  // Получить список криптовалют из api
  Future<List<CryptoCurrency>> getCryptoCurrenciesListFromApi();
}
