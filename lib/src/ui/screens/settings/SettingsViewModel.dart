import 'dart:async';

import 'package:what_to_mine/src/logic/Services.dart';

class SettingsViewModel {
  final _notificationsIsEnable = StreamController<bool>();

  Stream<bool> get notificationsIsEnable => _notificationsIsEnable.stream;

  void onViewInitState() async {
    /*Services.settingsService
        .isNotificationsEnable()
        .then((isEnabled) => changeNotificationStatus(isEnabled))
        .catchError((Object errorObject) {
      print(errorObject.toString());
    });*/
  }

  void onDispose() async {
    this.._notificationsIsEnable.close();
  }

  void changeNotificationStatus(bool isEnable) async {
    _notificationsIsEnable.add(isEnable);
    isEnable
        ? await Services.backgroundTaskSchedulerService.enableScheduler(60)
        : await Services.backgroundTaskSchedulerService.disableScheduler();
  }
}
