import 'package:what_to_mine/src/domain/currency/CryptoCurrency.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';

abstract class ICurrenciesGateway {
  // Получить список криптовалют
  Future<List<CryptoCurrency>> getCryptoCurrenciesList({required bool isNeedFresh});

  // Получить доход по всем криптовалютам с сортировкой по убыванию дохода
  Future<List<Earnings>> getEarningsList({required bool isNeedFresh});
}
