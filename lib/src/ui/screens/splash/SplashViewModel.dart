import 'dart:async';

import 'package:flutter/material.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/ui/theme/ThemeConfig.dart';
import 'package:what_to_mine/src/utils/SysUtils.dart';

import '../../../app.dart';

class SplashViewModel {
  final _loading = StreamController<bool>();
  final _errorMessage = StreamController<String?>();
  final _openHomeScreen = StreamController();

  Stream<bool> get loading => _loading.stream;
  Stream<String?> get errorMessage => _errorMessage.stream;
  Stream get openHomeScreen => _openHomeScreen.stream;

  SplashViewModel();
  void onViewInitState() async {
    await initializeApp();
    // Устанавливаем тему
    currentTheme.switchTheme(ThemeMode.values[await Services.settingsService.getThemeIndex()]);

    Services.currenciesService.getCryptoCurrenciesList(true).whenComplete(() async {
      await SysUtils.delay(1);
      _openHomeScreen.add(true);
    });
  }

  void onViewDispose() async {
    _loading.close();
    _errorMessage.close();
    _openHomeScreen.close();
  }
}
