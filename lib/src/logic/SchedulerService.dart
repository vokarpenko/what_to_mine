import 'package:what_to_mine/src/domain/Settings.dart';
import 'package:what_to_mine/src/logic/gateway/ISchedulerGateway.dart';
import 'package:what_to_mine/src/logic/gateway/ISettingsGateway.dart';

class SchedulerService {
  final ISchedulerGateway _schedulerGateway;
  final ISettingsGateway _settingsGateway;

  SchedulerService({required ISchedulerGateway schedulerGateway, required ISettingsGateway settingsGateway})
      : _schedulerGateway = schedulerGateway,
        _settingsGateway = settingsGateway {
    _initializeScheduler();
  }

  // Включить шедулер
  Future<void> enableScheduler(int interval) async {
    return _schedulerGateway.enableScheduler(interval);
  }

  // Выключить шедулер
  Future<void> disableScheduler() async {
    return _schedulerGateway.disableScheduler();
  }

  void _initializeScheduler() async {
    Settings settings = await _settingsGateway.getSettings();
    if (settings.notificationIsEnabled) {
      enableScheduler(15);
    }
  }
}
