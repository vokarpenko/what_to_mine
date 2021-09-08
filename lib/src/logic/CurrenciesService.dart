import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/logic/gateway/IGateway.dart';

import '../domain/currency/CryptoCurrency.dart';

class CurrenciesService {
  final IGateway _gateway;

  CurrenciesService({required IGateway gateway}) : _gateway = gateway;

  // Получить список криптовалют
  Future<List<CryptoCurrency>> getCryptoCurrenciesList() async {
    return _gateway.getCryptoCurrenciesList();
  }

  // Получить доход по всем криптовалютам с сортировкой по убываниб дохода
  Future<List<Earnings>> getEarningsList() async {
    List<Earnings> result = await _gateway.getEarningsList();
    result.sort((a, b) => b.dayEarningInCurrency.compareTo(a.dayEarningInCurrency));
    return result;
  }
}
