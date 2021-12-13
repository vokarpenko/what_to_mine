
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/settings/SettingsViewModel.dart';

class SettingScreen extends StatefulWidget {
  final bool isNotificationEnableInitValue;
  final SettingsViewModel _viewModel = SettingsViewModel();

  SettingScreen(this.isNotificationEnableInitValue);

  @override
  State<StatefulWidget> createState() => StateSettingScreen(_viewModel, isNotificationEnableInitValue);
}

class StateSettingScreen extends State<SettingScreen> {
  final bool isNotificationEnableInitValue;
  SettingsViewModel _viewModel;

  StateSettingScreen(this._viewModel, this.isNotificationEnableInitValue);

  @override
  void initState() {
    super.initState();
    _viewModel.onViewInitState();
  }

  @override
  void dispose() {
    super.dispose();
    this.._viewModel.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Настройки"),
      ),
      body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: ListTile.divideTiles(context: context, tiles: [
            StreamBuilder<bool>(
              stream: _viewModel.notificationsIsEnable,
              initialData: isNotificationEnableInitValue,
              builder: (context, snapshot) {
                return SwitchListTile.adaptive(
                  title: Text("Пуш-уведомления"),
                  subtitle: Text("Получение уведомлений"),
                  value: snapshot.data!,
                  onChanged: (isEnable) => _viewModel.changeNotificationStatus(isEnable),
                  secondary: Icon(Icons.notifications),
                );
              },
            ),
          ]).toList()),
    );
  }
}
