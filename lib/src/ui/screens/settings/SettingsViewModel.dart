import 'dart:async';

import 'package:what_to_mine/src/logic/Services.dart';

class SettingsViewModel {
  final StreamController<bool> _openNotificationSettings = StreamController<bool>();

  Stream<bool> get openNotificationSettings => _openNotificationSettings.stream;

  void onViewInitState() async {}

  void onDispose() async {
    this.._openNotificationSettings.close();
  }

  void onOpenNotificationSettings() async {
    _openNotificationSettings.add(true);
  }

  void enableNotification() async {
    await Services.backgroundTaskSchedulerService.enableScheduler(15);
  }

  void disableNotification() async {
    await Services.backgroundTaskSchedulerService.disableScheduler();
  }
}
