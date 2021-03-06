import 'package:what_to_mine/src/domain/settings.dart';

import 'gateway/settings_gateway.dart';

class SettingsService {
  final ISettingsGateway _gateway;

  SettingsService({required ISettingsGateway gateway}) : _gateway = gateway;

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
    return setSettings(settings);
  }

  // Получить настройку включены ли уведомления
  Future<bool> isNotificationsEnable() async {
    return (await getSettings()).notificationIsEnabled;
  }

  // Сохранить индекс темы
  Future<void> setThemeIndex(int index) async {
    Settings settings = await _gateway.getSettings();
    settings.themeIndex = index;
    return setSettings(settings);
  }

  // Получить индекс темы
  Future<int> getThemeIndex() async {
    return (await getSettings()).themeIndex;
  }

  // Сохранить настройку "Это первый запуск приложения?"
  Future<void> setIsFirstRun(bool isFirstRun) async {
    Settings settings = await _gateway.getSettings();
    settings.isFirstRun = isFirstRun;
    return setSettings(settings);
  }

  // Получить настройку "Это первый запуск приложения?"
  Future<bool> isTheFirstRun() async {
    return (await getSettings()).isFirstRun;
  }

  // Сохранить стоимость электроэнергии
  Future<void> setElectricityCost(double cost) async {
    _gateway.onElectricityCostChanged();
    Settings settings = await getSettings();
    settings.electricityCost = cost;
    return setSettings(settings);
  }

  // Получить стоимость электроэнергии
  Future<double> getElectricityCost() async {
    return (await getSettings()).electricityCost;
  }

  //Подписка на изменение стоимости электроэнергии
  Stream<bool> onElectricityCostChanged() {
    return _gateway.electricityCostChangedStream();
  }
}
