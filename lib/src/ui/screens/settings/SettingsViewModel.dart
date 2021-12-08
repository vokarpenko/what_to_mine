import 'dart:async';

import 'package:what_to_mine/src/logic/Services.dart';

class SettingsViewModel {
  final _notificationsIsEnable = StreamController<bool>();
  final StreamController<bool> _openNotificationSettings = StreamController<bool>();

  Stream<bool> get notificationsIsEnable => _notificationsIsEnable.stream;
  Stream<bool> get openNotificationSettings => _openNotificationSettings.stream;

  void onViewInitState() async {
    Services.settingsService
        .isNotificationsEnable()
        .then((isEnabled) => _notificationsIsEnable.add(isEnabled))
        .catchError((Object errorObject) {
      print(errorObject.toString());
    });
  }

  void onDispose() async {
    this.._openNotificationSettings.close().._notificationsIsEnable.close();
  }

  void onOpenNotificationSettings() async {
    _openNotificationSettings.add(true);
  }

  void changeNotificationStatus(bool isEnable) async {
    _notificationsIsEnable.add(isEnable);
    isEnable
        ? await Services.backgroundTaskSchedulerService.enableScheduler(15)
        : await Services.backgroundTaskSchedulerService.disableScheduler();
  }

  void enableNotification() async {
    await Services.backgroundTaskSchedulerService.enableScheduler(15);
  }

  void disableNotification() async {
    await Services.backgroundTaskSchedulerService.disableScheduler();
  }
}
