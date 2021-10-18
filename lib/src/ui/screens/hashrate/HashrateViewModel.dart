import 'dart:async';

import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/logic/Services.dart';

class HashrateViewModel {
  final StreamController<List<HashAlgorithm>> _hashrate = StreamController<List<HashAlgorithm>>();
  final StreamController<bool> _isLoading = StreamController<bool>();
  final StreamController<String> _errorMessage = StreamController<String>();
  final StreamController<bool> _showApplyButton = StreamController<bool>();
  final StreamController<String> _infoMessage = StreamController<String>();

  Stream<List<HashAlgorithm>> get hashrate => _hashrate.stream;
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<bool> get showApplyButton => _showApplyButton.stream;
  Stream<String> get infoMessage => _infoMessage.stream;

  HashrateViewModel();

  void onViewInitState() async {
    Services.gpuService.onUsedGpuChanged().listen((_) => _getData());
    Services.hashAlgorithmService.onUserHashrateChanged().listen((_) => _getData());
    _getData();
  }

  void _getData() async {
    _isLoading.add(true);
    Services.hashAlgorithmService.getHashratesUsedInCalc().then((hashrates) {
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

  String getHashUnit(HashAlgorithm algorithm) {
    return algorithm.getHashUnit();
  }

  void onChangeHashrate(String name, String? value) async {
    double hashrateValue;
    if (value == null || value == '') value = '0';
    hashrateValue = double.parse(value);
    await Services.hashAlgorithmService.updateEditedHashrateInCache(name, hashrateValue);
    _showApplyButton.add(true);
  }

  void onApplyHashrate() async {
    _isLoading.add(true);
    List<HashAlgorithm> hashrates = await Services.hashAlgorithmService.getEditedHashratesFromCache();
    Services.hashAlgorithmService.updateHashratesInDB(hashrates).then((_) {
      _isLoading.add(false);
      _showApplyButton.add(false);
      _infoMessage.add("Хэшрейты обновлены");
    }).catchError((Object errorObject) {
      _isLoading.add(false);
      print(errorObject.toString());
      _errorMessage.add(errorObject.toString());
    });
  }
}
