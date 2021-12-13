import 'package:what_to_mine/src/domain/Settings.dart';

import 'gateway/IGateway.dart';

class SettingsService {
  IGateway _gateway;

  SettingsService({required IGateway gateway}) : _gateway = gateway;

  // Получить настройку включены ли уведомления
  Future<bool> isNotificationsEnable() async {
    return _gateway.isSchedulerEnabled();
  }

  // Получить настройки приложения
  Future<Settings> getSettings() async {
    return _gateway.getSettings();
  }

  // Сохранить настройки приложения
  Future<void> setSettings(Settings settings) async {
    return _gateway.setSettings(settings);
  }

  // Сохранить индекс темы
  Future<void> saveThemeIndex(int index) async {
    Settings settings = await _gateway.getSettings();
    settings.themeIndex = index;
    return this.setSettings(settings);
  }

  // Получить индекс темы
  Future<int> getThemeIndex() async {
    return (await this.getSettings()).themeIndex;
  }
}
