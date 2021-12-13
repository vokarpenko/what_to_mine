import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:what_to_mine/src/domain/Settings.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/ui/screens/settings/SettingsViewModel.dart';
import 'package:what_to_mine/src/ui/theme/ThemeConfig.dart';
import 'package:what_to_mine/src/ui/widgets/ThemeSelectorWidget.dart';

class SettingScreen extends StatefulWidget {
  final Settings _settings;
  final SettingsViewModel _viewModel = SettingsViewModel();

  SettingScreen(this._settings);

  @override
  State<StatefulWidget> createState() => StateSettingScreen(_viewModel, _settings);
}

class StateSettingScreen extends State<SettingScreen> {
  final Settings _settings;
  SettingsViewModel _viewModel;

  StateSettingScreen(this._viewModel, this._settings);

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
              initialData: _settings.notificationIsEnabled,
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
            ListTile(
                leading: Icon(Icons.invert_colors),
                title: Text("Тема"),
                subtitle: Text("Тема приложения"),
                onTap: _onSwitchTheme),
            ListTile(
              leading: Icon(Icons.invert_colors),
              title: Text("Тема"),
              subtitle: Text("Тема приложения"),
              onTap: () => showBarModalBottomSheet(
                  expand: false,
                  backgroundColor: Colors.transparent,
                  context: context,
                  duration: Duration(milliseconds: 300),
                  builder: (context) => ThemeSelectorWidget()),
            )
            /*Column(
              children: <Widget>[
                RadioListTile<ThemeMode>(
                  title: const Text('Системная'),
                  value: ThemeMode.system,
                  groupValue: currentTheme.currentTheme(),
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      setState(() {
                        _onThemeSelected(value);
                      });
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Светлая'),
                  value: ThemeMode.light,
                  groupValue: currentTheme.currentTheme(),
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      setState(() {
                        _onThemeSelected(value);
                      });
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Темная'),
                  value: ThemeMode.dark,
                  groupValue: currentTheme.currentTheme(),
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      setState(() {
                        _onThemeSelected(value);
                      });
                    }
                  },
                ),
              ],
            )*/
          ]).toList()),
    );
  }

  Future<void> _onSwitchTheme() async {
    if (currentTheme.currentTheme().name == Brightness.dark.name) {
      currentTheme.switchTheme(ThemeMode.light);
      await Services.settingsService.saveThemeIndex(ThemeMode.light.index);
    } else {
      currentTheme.switchTheme(ThemeMode.dark);
      await Services.settingsService.saveThemeIndex(ThemeMode.dark.index);
    }
  }
}
