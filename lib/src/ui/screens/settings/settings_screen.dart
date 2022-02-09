import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:what_to_mine/src/domain/settings.dart';
import 'package:what_to_mine/src/ui/screens/settings/settings_view_model.dart';
import 'package:what_to_mine/src/ui/widgets/electricity_cost_selector_widget.dart';
import 'package:what_to_mine/src/ui/widgets/language_selector_widget.dart';
import 'package:what_to_mine/src/ui/widgets/theme_selector_widget.dart';

class SettingScreen extends StatelessWidget {
  final Settings _settings;
  final SettingsViewModel _viewModel = SettingsViewModel();

  SettingScreen(this._settings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('settings_appbar_title').tr(),
      ),
      body: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: ListTile.divideTiles(context: context, tiles: [
            StreamBuilder<bool>(
              stream: _viewModel.notificationsIsEnable,
              initialData: _settings.notificationIsEnabled,
              builder: (context, snapshot) {
                String subTitle;
                (snapshot.data!)
                    ? subTitle = 'settings_notification_enable_subtitle'.tr()
                    : subTitle = 'settings_notification_disable_subtitle'.tr();
                return SwitchListTile.adaptive(
                  title: Text('settings_notification'.tr()),
                  subtitle: Text(subTitle),
                  value: snapshot.data!,
                  onChanged: (isEnable) => _viewModel.onChangeNotificationStatus(isEnable),
                  secondary: const Icon(Icons.notifications),
                );
              },
            ),
            StreamBuilder<double>(
              stream: _viewModel.electricityCost,
              initialData: _settings.electricityCost,
              builder: (context, snapshot) {
                return ListTile(
                  leading: const Icon(Icons.electrical_services),
                  title: Text('setting_electricity_cost'.tr()),
                  subtitle: Text('${snapshot.data?.toStringAsFixed(2)} USD'),
                  onTap: () => showBarModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      duration: const Duration(milliseconds: 300),
                      builder: (context) => ElectricityCostSelectorWidget(_viewModel, snapshot.data!)),
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
                    subTitle = 'settings_theme_system'.tr();
                    break;
                  case ThemeMode.light:
                    subTitle = 'settings_theme_light'.tr();
                    break;
                  case ThemeMode.dark:
                    subTitle = 'settings_theme_dark'.tr();
                    break;
                }
                return ListTile(
                  leading: const Icon(Icons.invert_colors),
                  title: Text('settings_theme'.tr()),
                  subtitle: Text(subTitle),
                  onTap: () => showBarModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      duration: const Duration(milliseconds: 300),
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
                    subTitle = 'settings_language_en'.tr();
                    break;
                  case 'ru':
                    subTitle = 'settings_language_ru'.tr();
                    break;
                }
                return ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('settings_language'.tr()),
                  subtitle: Text(subTitle),
                  onTap: () => showBarModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      duration: const Duration(milliseconds: 300),
                      builder: (context) => LanguageSelectorWidget(_viewModel)),
                );
              },
            ),
          ]).toList()),
    );
  }
}
