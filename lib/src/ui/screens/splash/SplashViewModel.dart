import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/ui/screens/ScreenRoutes.dart';
import 'package:what_to_mine/src/ui/theme/ThemeConfig.dart';
import 'package:what_to_mine/src/utils/InternetUtils.dart';
import 'package:what_to_mine/src/utils/SysUtils.dart';

import '../../../app.dart';

class SplashViewModel {
  final _loading = StreamController<bool>();
  final _errorMessage = StreamController<String>();
  final _openNextScreen = StreamController<String>();

  Stream<bool> get loading => _loading.stream;

  Stream<String> get errorMessage => _errorMessage.stream;

  Stream<String> get openNextScreen => _openNextScreen.stream;

  SplashViewModel();

  void onViewInitState() async {
    await initializeApp();
    // Устанавливаем тему
    currentTheme.switchTheme(ThemeMode.values[await Services.settingsService.getThemeIndex()]);
    getData();
  }

  void getData() async {
    if (!await InternetUtils.isInternetAvailable()) {
      String errorMessage = 'error'.tr() + ': ' + 'error_internet_is_unavailable'.tr();
      print(errorMessage);
      _errorMessage.add(errorMessage);
      return;
    }

    // Получаем настройки и открываем следующий экран
    Services.currenciesService.getCryptoCurrenciesList(true).then((list) async {
      // Пауза для показа заставки
      await SysUtils.delay(1);
      if (list.isNotEmpty)
        (await Services.settingsService.isTheFirstRun())
            ? _openNextScreen.add(ScreenRoutes.introScreen)
            : _openNextScreen.add(ScreenRoutes.homeScreen);
    }).catchError((error) {
      String errorMessage = 'error_get_crypto_currencies_list'.tr() + '.\n${error.toString()}';
      print(errorMessage);
      _errorMessage.add(errorMessage);
    });
  }

  void onViewDispose() async {
    this
      .._loading.close()
      .._errorMessage.close()
      .._openNextScreen.close();
  }
}
