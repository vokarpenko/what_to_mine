import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/logic/services.dart';
import 'package:what_to_mine/src/ui/theme/theme_config.dart';

import '../../../app.dart';
import '../screen_routes.dart';

class SplashViewModel {
  final _loading = StreamController<bool>();
  final _errorMessage = StreamController<String>();
  final _openNextScreen = StreamController<String>();

  Stream<bool> get loading => _loading.stream;

  Stream<String> get errorMessage => _errorMessage.stream;

  Stream<String> get openNextScreen => _openNextScreen.stream;

  SplashViewModel();

  bool _disposed = false;
  int _attempt = 0;

  void onViewInitState() async {
    try {
      await initializeApp();
      if (_disposed) return;
      final themeIndex = await Services.settingsService.getThemeIndex();
      if (_disposed) return;
      currentTheme.switchTheme(ThemeMode.values[themeIndex]);
      getData();
    } catch (error) {
      _reportError(error);
    }
  }

  void getData() async {
    if (_disposed) return;
    final attempt = ++_attempt;
    try {
      await Services.currenciesService.getCryptoCurrenciesList(false);
      if (_disposed || attempt != _attempt) return;
      final firstRun = await Services.settingsService.isTheFirstRun();
      if (_disposed || attempt != _attempt) return;
      _openNextScreen.add(
        firstRun ? ScreenRoutes.introScreen : ScreenRoutes.homeScreen,
      );
    } catch (error) {
      if (attempt == _attempt) _reportError(error);
    }
  }

  void _reportError(Object error) {
    if (_disposed) return;
    _errorMessage.add('${'error_get_crypto_currencies_list'.tr()}.\n$error');
  }

  void onViewDispose() {
    _disposed = true;
    _attempt++;
    _loading.close();
    _errorMessage.close();
    _openNextScreen.close();
  }
}
