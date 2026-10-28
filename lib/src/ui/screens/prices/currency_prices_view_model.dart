import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/logic/services.dart';

class CurrencyPricesViewModel {
  final StreamController<List<CryptoCurrency>> _currencyList =
      StreamController<List<CryptoCurrency>>();
  final StreamController<String> _errorMessage = StreamController<String>();

  Stream<List<CryptoCurrency>> get currencyList => _currencyList.stream;

  Stream<String> get errorMessage => _errorMessage.stream;

  CurrencyPricesViewModel();

  void onViewInitState() async {
    await getData(false);
  }

  Future<void> getData(bool isNeedFresh) async {
    try {
      final coins = await Services.currenciesService.getCryptoCurrenciesList(
        isNeedFresh,
      );
      if (_currencyList.isClosed) return;
      // Names and missing-price markers are available while the USD rate loads.
      _currencyList.add(coins);
      final prices = await Services.currenciesService.pricesInUsd(
        coins,
        forceRefresh: isNeedFresh,
      );
      if (!_currencyList.isClosed) _currencyList.add(prices);
    } catch (error) {
      if (!_errorMessage.isClosed) {
        _errorMessage.add(
          '${'error_get_crypto_currencies_list'.tr()}.\n$error',
        );
      }
    }
  }

  void onViewDispose() async {
    this
      .._currencyList.close()
      .._errorMessage.close();
  }
}
