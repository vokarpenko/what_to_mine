import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/data/client/btc_usd_rate_client.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';

import 'gateway/currencies_gateway.dart';

class CurrenciesService {
  final ICurrenciesGateway _gateway;

  final BtcUsdRateClient? _exchangeRates;

  CurrenciesService({required this._gateway, this._exchangeRates});

  Future<List<CryptoCurrency>> pricesInUsd(
    List<CryptoCurrency> coins, {
    bool forceRefresh = false,
  }) async {
    final needsRate = coins.any(
      (coin) => coin.quoteCurrency == 'BTC' && coin.price >= 0,
    );
    final double? rate;
    if (needsRate) {
      if (_exchangeRates == null) throw const BtcUsdRateException();
      rate = await _exchangeRates.getRate(forceRefresh: forceRefresh);
    } else {
      rate = null;
    }
    return coins
        .map(
          (coin) => coin.withUsdPrice(
            coin.price < 0
                ? null
                : coin.quoteCurrency == 'USD'
                ? coin.price
                : coin.quoteCurrency == 'BTC' && rate != null
                ? coin.price * rate
                : null,
          ),
        )
        .toList();
  }

  // Получить список криптовалют
  Future<List<CryptoCurrency>> getCryptoCurrenciesList(bool isNeedFresh) async {
    return _gateway.getCryptoCurrenciesList(isNeedFresh: isNeedFresh);
  }

  // Получить доход по всем криптовалютам с сортировкой по убыванию дохода
  Future<List<Earnings>> getEarningsList(bool isNeedFresh) async {
    List<Earnings> result = await _gateway.getEarningsList(
      isNeedFresh: isNeedFresh,
    );
    result.sort(
      (a, b) => b.netDayEarningInCurrency.compareTo(a.netDayEarningInCurrency),
    );
    return result;
  }

  // Получить самую доходную криптовалюту
  Future<Earnings?> getMostProfitableCurrency() async {
    List<Earnings> result = await getEarningsList(false);
    return result.isNotEmpty && result.first.netDayEarningInCurrency > 0
        ? result.first
        : null;
  }
}
