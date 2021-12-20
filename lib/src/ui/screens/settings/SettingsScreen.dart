import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:what_to_mine/src/domain/Settings.dart';
import 'package:what_to_mine/src/ui/screens/settings/SettingsViewModel.dart';
import 'package:what_to_mine/src/ui/widgets/LanguageSelectorWidget.dart';
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
        title: Text('settings_appbar_title').tr(),
      ),
      body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: ListTile.divideTiles(context: context, tiles: [
            StreamBuilder<bool>(
              stream: _viewModel.notificationsIsEnable,
              initialData: _settings.notificationIsEnabled,
              builder: (context, snapshot) {
                String subTitle;
                (snapshot.data!)
                    ? subTitle = "settings_notification_enable_subtitle".tr()
                    : subTitle = "settings_notification_disable_subtitle".tr();

                return SwitchListTile.adaptive(
                  title: Text("settings_notification".tr()),
                  subtitle: Text(subTitle),
                  value: snapshot.data!,
                  onChanged: (isEnable) => _viewModel.onChangeNotificationStatus(isEnable),
                  secondary: Icon(Icons.notifications),
                );
              },
            ),
            StreamBuilder<ThemeMode>(
              stream: _viewModel.themeMode,
              initialData: ThemeMode.values[_settings.themeIndex],
              builder: (context, snapshot) {
                String subTitle;
                switch (snapshot.data!) {
                  case ThemeMode.system:
                    subTitle = "settings_theme_system".tr();
                    break;
                  case ThemeMode.light:
                    subTitle = "settings_theme_light".tr();
                    break;
                  case ThemeMode.dark:
                    subTitle = "settings_theme_dark".tr();
                    break;
                }
                return ListTile(
                  leading: Icon(Icons.invert_colors),
                  title: Text("settings_theme".tr()),
                  subtitle: Text(subTitle),
                  onTap: () => showBarModalBottomSheet(
                      expand: false,
                      backgroundColor: Colors.transparent,
                      context: context,
                      duration: Duration(milliseconds: 300),
                      builder: (context) => ThemeSelectorWidget(_viewModel)),
                );
              },
            ),
            StreamBuilder<String>(
              stream: _viewModel.locale,
              initialData: EasyLocalization.of(context)?.locale.languageCode,
              builder: (context, snapshot) {
                String subTitle = "";
                switch (snapshot.data!) {
                  case 'en':
                    subTitle = "settings_language_en".tr();
                    break;
                  case 'ru':
                    subTitle = "settings_language_ru".tr();
                    break;
                }
                return ListTile(
                  leading: Icon(Icons.language),
                  title: Text("settings_language".tr()),
                  subtitle: Text(subTitle),
                  onTap: () => showBarModalBottomSheet(
                      expand: false,
                      backgroundColor: Colors.transparent,
                      context: context,
                      duration: Duration(milliseconds: 300),
                      builder: (context) => LanguageSelectorWidget(_viewModel)),
                );
              },
            ),
          ]).toList()),
    );
  }
}
