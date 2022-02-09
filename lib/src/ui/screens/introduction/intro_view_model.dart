import 'dart:async';

import 'package:what_to_mine/src/logic/services.dart';

class IntroViewModel {
  final _openHomeScreen = StreamController();

  Stream get openHomeScreen => _openHomeScreen.stream;

  void onViewInitState() async {}

  void onViewDispose() async {
    _openHomeScreen.close();
  }

  void onDone(double cost) async {
    // устанавливаем стоимость электроэнергии
    _openHomeScreen.add('');
    await Services.settingsService.setElectricityCost(cost);
    await Services.settingsService.setIsFirstRun(false);
  }

  void onSkip() async {
    _openHomeScreen.add('');
    // устанавливаем стандартую стоимость электроэнергии
    await Services.settingsService.setElectricityCost(0.1);
    await Services.settingsService.setIsFirstRun(false);
  }
}
