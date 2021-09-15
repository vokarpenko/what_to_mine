import 'dart:async';

import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/logic/Services.dart';

class EarningViewModel {
  final StreamController<List<Earnings>> _earnings = StreamController<List<Earnings>>();
  final StreamController<bool> _isLoading = StreamController<bool>();
  final StreamController<String> _errorMessage = StreamController<String>();
  final StreamController<bool> _usedGpuUpdate = StreamController<bool>();

  Stream<List<Earnings>> get earnings => _earnings.stream;
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<bool> get usedGpuUpdate => _usedGpuUpdate.stream;

  EarningViewModel();

  void onViewInitState() async {
    Services.gpuService.onUsedGpuChanged().listen((_) {
      _usedGpuUpdate.add(true);
    });
    _isLoading.add(true);
    Services.currenciesService.getEarningsList().then((earnings) {
      _earnings.add(earnings);
    }).catchError((Object errorObject) {
      _isLoading.add(false);
      print(errorObject.toString());
      _errorMessage.add(errorObject.toString());
    }).whenComplete(() => _isLoading.add(false));
  }

  void onViewDispose() async {
    _earnings.close();
    _isLoading.close();
    _errorMessage.close();
  }
}
