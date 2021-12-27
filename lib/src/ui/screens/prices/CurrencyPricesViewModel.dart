import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/utils/InternetUtils.dart';

import '../../../domain/currency/CryptoCurrency.dart';

class CurrencyPricesViewModel {
  final StreamController<List<CryptoCurrency>> _currencyList = StreamController<List<CryptoCurrency>>();
  final StreamController<String> _errorMessage = StreamController<String>();

  Stream<List<CryptoCurrency>> get currencyList => _currencyList.stream;
  Stream<String> get errorMessage => _errorMessage.stream;

  CurrencyPricesViewModel();

  void onViewInitState() async {
    await getData(false);
  }

  Future<void> getData(bool isNeedFresh) async {
    if (!await InternetUtils.isInternetAvailable()) {
      String errorMessage = 'error'.tr() + ': ' + 'error_internet_is_unavailable'.tr();
      print(errorMessage);
      _errorMessage.add(errorMessage);
      return;
    }

    Services.currenciesService.getCryptoCurrenciesList(isNeedFresh).then((list) {
      _currencyList.add(list);
    }).catchError((error) {
      String errorMessage = 'error_get_crypto_currencies_list'.tr() + '.\n${error.toString()}';
      print(errorMessage);
      _errorMessage.add(errorMessage);
    });
  }

  void onViewDispose() async {
    this
      .._currencyList.close()
      .._errorMessage.close();
  }
}
