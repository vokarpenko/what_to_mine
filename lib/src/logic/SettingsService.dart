
import 'gateway/IGateway.dart';

class SettingsService {
  IGateway _gateway;

  SettingsService({required IGateway gateway}) : _gateway = gateway;

  // Получить настройку включены ли уведомления
  Future<bool> isNotificationsEnable() async {
    return _gateway.isSchedulerEnabled();
  }
}
