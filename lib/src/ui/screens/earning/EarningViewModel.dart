import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:what_to_mine/src/domain/Settings.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/utils/InternetUtils.dart';

class EarningViewModel {
  final StreamController<List<Earnings>> _earnings = StreamController<List<Earnings>>();
  final StreamController<String> _errorMessage = StreamController<String>();
  final StreamController<Settings> _openSettingsScreen = StreamController<Settings>();

  Stream<List<Earnings>> get earnings => _earnings.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<Settings> get openSettingsScreen => _openSettingsScreen.stream;

  EarningViewModel();

  void onViewInitState() async {
    Services.gpuService.onUsedGpuChanged().listen((_) => getData(false));
    Services.hashAlgorithmService.onUserHashrateChanged().listen((_) => getData(false));
    Services.settingsService.onUserHashrateChanged().listen((_) => getData(false));
    getData(false);
  }

  Future<void> getData(bool isNeedFresh) async {
    if (!await InternetUtils.isInternetAvailable()) {
      String errorMessage = 'error'.tr() + ': ' + 'error_internet_is_unavailable'.tr();
      print(errorMessage);
      _errorMessage.add(errorMessage);
      return;
    }
    Services.currenciesService.getEarningsList(isNeedFresh).then((earnings) {
      _earnings.add(earnings);
    }).catchError((error) {
      String errorMessage = 'error_get_earnings_list'.tr() + '.\n${error.toString()}';
      print(errorMessage);
      _errorMessage.add(errorMessage);
    });
  }

  void onViewDispose() async {
    this
      .._earnings.close()
      .._errorMessage.close();
  }

  void openSettingScreen() async {
    Settings settings = await Services.settingsService.getSettings();
    _openSettingsScreen.add(settings);
  }
}
