import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/logic/Services.dart';

class HashrateViewModel {
  final StreamController<List<HashAlgorithm>> _hashrate = StreamController<List<HashAlgorithm>>();
  final StreamController<String> _errorMessage = StreamController<String>();
  final StreamController<bool> _showApplyButton = StreamController<bool>();
  final StreamController<String> _infoMessage = StreamController<String>();

  Stream<List<HashAlgorithm>> get hashrate => _hashrate.stream;
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
    Services.hashAlgorithmService.getHashratesUsedInCalc().then((hashrates) {
      _hashrate.add(hashrates);
    }).catchError((error) {
      String errorMessage = 'error_get_hashrates_used_in_calc'.tr() + '.\n${error.toString()}';
      print(errorMessage);
      _errorMessage.add(errorMessage);
    });
  }

  void onViewDispose() async {
    this
      .._hashrate.close()
      .._errorMessage.close();
  }

  String getHashUnit(HashAlgorithm algorithm) {
    return algorithm.getHashUnit();
  }

  void onChangeHashrate(String name, String? value) async {
    double hashrateValue;
    if (value == null || value == '') value = '0';
    hashrateValue = double.parse(value);
    Services.hashAlgorithmService
        .updateEditedHashrateInCache(name, hashrateValue)
        .then((_) => _showApplyButton.add(true))
        .catchError((error) {
      String errorMessage = 'error_update_edited_hashrate_in_cache'.tr() + '.\n${error.toString()}';
      print(errorMessage);
      _errorMessage.add(errorMessage);
    });
  }

  void onChangePower(String name, String? value) async {
    int powerValue;
    if (value == null || value == '') value = '0';
    powerValue = int.parse(value);
    Services.hashAlgorithmService
        .updateEditedPowerInCache(name, powerValue)
        .then((_) => _showApplyButton.add(true))
        .catchError((error) {
      String errorMessage = 'error_update_edited_power_in_cache'.tr() + '.\n${error.toString()}';
      print(errorMessage);
      _errorMessage.add(errorMessage);
    });
  }

  void onApplyHashrate() async {
    List<HashAlgorithm> hashrates = await Services.hashAlgorithmService.getEditedHashratesFromCache();
    Services.hashAlgorithmService.updateHashratesInDB(hashrates).then((_) {
      _showApplyButton.add(false);
      _infoMessage.add('hashrates_update_message'.tr());
    }).catchError((error) {
      String errorMessage = 'error_update_hashrate_in_db'.tr() + '.\n${error.toString()}';
      print(errorMessage);
      _errorMessage.add(errorMessage);
    });
  }
}
