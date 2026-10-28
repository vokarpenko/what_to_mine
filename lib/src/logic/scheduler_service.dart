import 'package:what_to_mine/src/domain/settings.dart';

import 'gateway/scheduler_gateway.dart';
import 'gateway/settings_gateway.dart';

class SchedulerService {
  static const refreshIntervalMinutes = 24 * 60;
  final ISchedulerGateway _schedulerGateway;
  final ISettingsGateway _settingsGateway;

  SchedulerService({
    required this._schedulerGateway,
    required this._settingsGateway,
  }) {
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
      await enableScheduler(refreshIntervalMinutes);
    }
  }
}
