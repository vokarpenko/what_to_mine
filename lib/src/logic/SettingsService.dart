import 'package:what_to_mine/src/domain/Settings.dart';

import 'gateway/IGateway.dart';

class SettingsService {
  IGateway _gateway;

  SettingsService({required IGateway gateway}) : _gateway = gateway;

  // Получить настройки приложения
  Future<Settings> getSettings() async {
    return _gateway.getSettings();
  }

  // Сохранить настройки приложения
  Future<void> setSettings(Settings settings) async {
    return _gateway.setSettings(settings);
  }

  // Сохранить настройку включены ли уведомления
  Future<void> setNotificationsIsEnable(bool isEnabled) async {
    Settings settings = await _gateway.getSettings();
    settings.notificationIsEnabled = isEnabled;
    return this.setSettings(settings);
  }

  // Получить настройку включены ли уведомления
  Future<bool> isNotificationsEnable() async {
    return (await this.getSettings()).notificationIsEnabled;
  }

  // Сохранить индекс темы
  Future<void> setThemeIndex(int index) async {
    Settings settings = await _gateway.getSettings();
    settings.themeIndex = index;
    return this.setSettings(settings);
  }

  // Получить индекс темы
  Future<int> getThemeIndex() async {
    return (await this.getSettings()).themeIndex;
  }

  // Сохранить настройку "Это первый запуск приложения?"
  Future<void> setIsFirstRun(bool isFirstRun) async {
    Settings settings = await _gateway.getSettings();
    settings.isFirstRun = isFirstRun;
    return this.setSettings(settings);
  }

  // Получить настройку "Это первый запуск приложения?"
  Future<bool> isTheFirstRun() async {
    return (await this.getSettings()).isFirstRun;
  }

  // Сохранить стоимость электроэнергии
  Future<void> setElectricityCost(double cost) async {
    return _gateway.setElectricityCost(cost);
  }

  // Получить стоимость электроэнергии
  Future<double> getElectricityCost() async {
    return (await this.getSettings()).electricityCost;
  }

  //Подписка на изменение стоимости электроэнергии
  Stream<bool> onUserHashrateChanged() {
    return _gateway.onElectricityCostChanged();
  }
}
