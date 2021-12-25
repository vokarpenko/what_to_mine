import 'dart:async';

import 'package:flutter/material.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/ui/screens/ScreenRoutes.dart';
import 'package:what_to_mine/src/ui/theme/ThemeConfig.dart';
import 'package:what_to_mine/src/utils/SysUtils.dart';

import '../../../app.dart';

class SplashViewModel {
  final _loading = StreamController<bool>();
  final _errorMessage = StreamController<String?>();
  final _openNextScreen = StreamController<String>();

  Stream<bool> get loading => _loading.stream;

  Stream<String?> get errorMessage => _errorMessage.stream;

  Stream<String> get openNextScreen => _openNextScreen.stream;

  SplashViewModel();

  void onViewInitState() async {
    await initializeApp();
    // Устанавливаем тему
    currentTheme.switchTheme(ThemeMode.values[await Services.settingsService.getThemeIndex()]);

    // Получаем настройки и открываем следующий экран
    Services.currenciesService.getCryptoCurrenciesList(true).whenComplete(() async {
      await SysUtils.delay(1);
      (await Services.settingsService.isTheFirstRun())
          ? _openNextScreen.add(ScreenRoutes.introScreen)
          : _openNextScreen.add(ScreenRoutes.homeScreen);
    });
  }

  void onViewDispose() async {
    _loading.close();
    _errorMessage.close();
    _openNextScreen.close();
  }
}
