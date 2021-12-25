import 'dart:async';

import 'package:what_to_mine/src/logic/Services.dart';

class IntroViewModel {
  final _openHomeScreen = StreamController();

  Stream get openHomeScreen => _openHomeScreen.stream;

  void onViewInitState() async {}

  void onViewDispose() async {
    _openHomeScreen.close();
  }

  void onDone() async {
    _openHomeScreen.add("");
    await Services.settingsService.setIsFirstRun(false);
  }
}
