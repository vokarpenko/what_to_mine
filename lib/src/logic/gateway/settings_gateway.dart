import 'package:what_to_mine/src/domain/settings.dart';

abstract class ISettingsGateway {
  // Получить настройки приложения
  Future<Settings> getSettings();

  // Сохранить настройки приложения
  Future<void> setSettings(Settings settings);

  //Подписка на изменение стоимости электроэнергии
  Stream<bool> electricityCostChangedStream();

  //Изменилась стоисость электроэнергии
  Future<void> onElectricityCostChanged();
}
