import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import 'package:what_to_mine/src/logic/services.dart';

class EarningViewModel {
  final _earnings = StreamController<List<Earnings>>();
  final _errorMessage = StreamController<String>();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  int _request = 0;

  Stream<List<Earnings>> get earnings => _earnings.stream;
  Stream<String> get errorMessage => _errorMessage.stream;

  void onViewInitState() {
    _subscriptions.addAll([
      Services.gpuService.onUsedGpuChanged().listen((_) => getData(false)),
      Services.hashAlgorithmService.onUserHashrateChanged().listen(
        (_) => getData(false),
      ),
      Services.settingsService.onElectricityCostChanged().listen(
        (_) => getData(false),
      ),
    ]);
    getData(false);
  }

  Future<void> getData(bool isNeedFresh) async {
    final request = ++_request;
    try {
      final result = await Services.currenciesService.getEarningsList(
        isNeedFresh,
      );
      if (!_earnings.isClosed && request == _request) _earnings.add(result);
    } catch (error) {
      if (!_errorMessage.isClosed && request == _request) {
        _errorMessage.add('${'error_get_earnings_list'.tr()}.\n$error');
      }
    }
  }

  void onViewDispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _earnings.close();
    _errorMessage.close();
  }
}
