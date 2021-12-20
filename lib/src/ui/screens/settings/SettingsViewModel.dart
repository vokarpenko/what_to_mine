import 'dart:async';

import 'package:flutter/material.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/ui/theme/ThemeConfig.dart';

class SettingsViewModel {
  final _notificationsIsEnable = StreamController<bool>();
  final _themeMode = StreamController<ThemeMode>();
  final _locale = StreamController<String>();

  Stream<bool> get notificationsIsEnable => _notificationsIsEnable.stream;
  Stream<ThemeMode> get themeMode => _themeMode.stream;
  Stream<String> get locale => _locale.stream;

  void onViewInitState() async {}

  void onDispose() async {
    this
      .._notificationsIsEnable.close()
      .._themeMode.close()
      .._locale.close();
  }

  void onChangeNotificationStatus(bool isEnable) async {
    _notificationsIsEnable.add(isEnable);
    isEnable
        ? await Services.backgroundTaskSchedulerService.enableScheduler(60)
        : await Services.backgroundTaskSchedulerService.disableScheduler();
  }

  void onSwitchTheme(ThemeMode theme) async {
    _themeMode.add(theme);
    currentTheme.switchTheme(theme);
    await Services.settingsService.saveThemeIndex(theme.index);
  }

  void onChangeLocale(String locale) async {
    _locale.add(locale);
  }
}
