import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';

import 'gateway/currencies_gateway.dart';

class CurrenciesService {
  final ICurrenciesGateway _gateway;

  CurrenciesService({required ICurrenciesGateway gateway}) : _gateway = gateway;

  // Получить список криптовалют
  Future<List<CryptoCurrency>> getCryptoCurrenciesList(bool isNeedFresh) async {
    return _gateway.getCryptoCurrenciesList(isNeedFresh: isNeedFresh);
  }

  // Получить доход по всем криптовалютам с сортировкой по убыванию дохода
  Future<List<Earnings>> getEarningsList(bool isNeedFresh) async {
    List<Earnings> result = await _gateway.getEarningsList(isNeedFresh: isNeedFresh);
    result.sort((a, b) => b.netDayEarningInCurrency.compareTo(a.netDayEarningInCurrency));
    return result;
  }

  // Получить самую доходную криптовалюту
  Future<Earnings?> getMostProfitableCurrency() async {
    List<Earnings> result = await getEarningsList(true);
    if (result.isNotEmpty) return result.first;
  }
}
