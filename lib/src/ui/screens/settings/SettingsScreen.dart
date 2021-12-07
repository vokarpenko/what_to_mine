import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/settings/SettingsViewModel.dart';

class SettingScreen extends StatefulWidget {
  final SettingsViewModel _viewModel = SettingsViewModel();
  @override
  State<StatefulWidget> createState() {
    return StateSettingScreen(_viewModel);
  }
}

class StateSettingScreen extends State<SettingScreen> {
  SettingsViewModel _viewModel;
  StreamSubscription? _subscriptionOpenNotificationSettings;

  StateSettingScreen(this._viewModel);

  @override
  void initState() {
    super.initState();
    _viewModel.onViewInitState();
    _subscriptionOpenNotificationSettings = _viewModel.openNotificationSettings.listen((_) async {
      _viewModel.enableNotification();
    });
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._viewModel.onDispose()
      .._subscriptionOpenNotificationSettings?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Настройки"),
      ),
      body: ListView(
          children: ListTile.divideTiles(context: context, tiles: [
        ListTile(
          onTap: () => _viewModel.onOpenNotificationSettings(),
          leading: Icon(Icons.notifications),
          title: Text("Активация пуш-уведомлений"),
          subtitle: Text("Получение уведомления"),
        ),
        ListTile(
          leading: Icon(Icons.notifications),
          title: Text("Отмена пуш-уведомлений"),
          onTap: () => _viewModel.disableNotification(),
        ),
        ListTile(
          title: Text("3"),
        )
      ]).toList()),
    );
  }
}
