import 'dart:async';

import 'package:flutter/material.dart';
import 'package:what_to_mine/src/logic/services.dart';
import 'package:what_to_mine/src/logic/scheduler_service.dart';
import 'package:what_to_mine/src/utils/notificator.dart';
import 'package:what_to_mine/src/ui/theme/theme_config.dart';

class SettingsViewModel {
  final _notificationsIsEnable = StreamController<bool>();
  final _themeMode = StreamController<ThemeMode>();
  final _locale = StreamController<String>();
  final _electricityCost = StreamController<double>();

  Stream<bool> get notificationsIsEnable => _notificationsIsEnable.stream;

  Stream<ThemeMode> get themeMode => _themeMode.stream;

  Stream<String> get locale => _locale.stream;
  Stream<double> get electricityCost => _electricityCost.stream;

  void onChangeNotificationStatus(bool isEnable) async {
    if (isEnable) {
      isEnable = await Notificator().requestPermission();
    }
    _notificationsIsEnable.add(isEnable);
    if (isEnable) {
      await Services.schedulerService.enableScheduler(SchedulerService.refreshIntervalMinutes);
    } else {
      await Services.schedulerService.disableScheduler();
    }
    await Services.settingsService.setNotificationsIsEnable(isEnable);
  }

  void onSwitchTheme(ThemeMode theme) async {
    _themeMode.add(theme);
    currentTheme.switchTheme(theme);
    await Services.settingsService.setThemeIndex(theme.index);
  }

  void onChangeLocale(String locale) async {
    _locale.add(locale);
  }

  void onChangeElectricityCost(double cost) async {
    _electricityCost.add(cost);
    Services.settingsService.setElectricityCost(cost);
  }
}
