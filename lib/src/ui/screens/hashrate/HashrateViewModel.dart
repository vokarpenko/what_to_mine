import 'dart:async';

import 'package:what_to_mine/src/domain/algorithms/Algos.dart';
import 'package:what_to_mine/src/logic/Services.dart';

class HashrateViewModel {
  final StreamController<Algos> _hashrate = StreamController<Algos>();
  final StreamController<bool> _isLoading = StreamController<bool>();
  final StreamController<String> _errorMessage = StreamController<String>();

  Stream<Algos> get hashrate => _hashrate.stream;
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String> get errorMessage => _errorMessage.stream;

  HashrateViewModel();

  void onViewInitState() async {
    _isLoading.add(true);
    Services.gpuService.getUsedHashrates().then((algos) {
      if (algos != null) _hashrate.add(algos);
    }).catchError((Object errorObject) {
      _isLoading.add(false);
      print(errorObject.toString());
      _errorMessage.add(errorObject.toString());
    }).whenComplete(() => _isLoading.add(false));
  }

  void onViewDispose() async {
    _hashrate.close();
    _isLoading.close();
    _errorMessage.close();
  }
}
