import 'dart:async';

import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/logic/Services.dart';

class HashrateViewModel {
  final StreamController<List<HashAlgorithm>> _hashrate = StreamController<List<HashAlgorithm>>();
  final StreamController<bool> _isLoading = StreamController<bool>();
  final StreamController<String> _errorMessage = StreamController<String>();
  final StreamController<bool> _usedGpuUpdate = StreamController<bool>();

  Stream<List<HashAlgorithm>> get hashrate => _hashrate.stream;
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<bool> get usedGpuUpdate => _usedGpuUpdate.stream;

  HashrateViewModel();

  void onViewInitState() async {
    _isLoading.add(true);
    Services.gpuService.onUsedGpuChanged().listen((_) {
      _usedGpuUpdate.add(true);
    });
    Services.gpuService.getHashratesUsedInCalc().then((hashrates) {
      _hashrate.add(hashrates);
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

  String getHashUnit(HashAlgorithm algorithm){
    return algorithm.getHashUnit();
  }
}
