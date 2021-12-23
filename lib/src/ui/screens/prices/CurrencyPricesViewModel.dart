import 'dart:async';

import 'package:what_to_mine/src/logic/Services.dart';

import '../../../domain/currency/CryptoCurrency.dart';

class CurrencyPricesViewModel {
  final StreamController<List<CryptoCurrency>> _currencyList = StreamController<List<CryptoCurrency>>();
  final StreamController<bool> _isLoading = StreamController<bool>();
  final StreamController<String> _errorMessage = StreamController<String>();

  Stream<List<CryptoCurrency>> get currencyList => _currencyList.stream;
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String> get errorMessage => _errorMessage.stream;

  CurrencyPricesViewModel();

  void onViewInitState() async {
    await getData(false);
  }

  Future<void> getData(bool isNeedFresh) async {
    _isLoading.add(true);
    Services.currenciesService.getCryptoCurrenciesList(isNeedFresh).then((list) {
      _currencyList.add(list);
    }).catchError((Object errorObject) {
      _isLoading.add(false);
      print(errorObject.toString());
      _errorMessage.add(errorObject.toString());
    }).whenComplete(() => _isLoading.add(false));
  }

  void onViewDispose() async {
    this
      .._currencyList.close()
      .._isLoading.close()
      .._errorMessage.close();
  }
}
