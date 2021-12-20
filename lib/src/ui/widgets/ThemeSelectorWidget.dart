import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/settings/SettingsViewModel.dart';

class ThemeSelectorWidget extends StatelessWidget {
  final SettingsViewModel _viewModel;
  ThemeSelectorWidget(this._viewModel);
  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('settings_theme_system'.tr()),
            leading: Icon(Icons.build),
            onTap: () {
              _onSwitchTheme(ThemeMode.system);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('settings_theme_light'.tr()),
            leading: ImageIcon(
              AssetImage('assets/icons/light_theme_icon.png'),
              size: 27,
            ),
            onTap: () {
              _onSwitchTheme(ThemeMode.light);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('settings_theme_dark'.tr()),
            leading: ImageIcon(AssetImage('assets/icons/dark_theme_icon.png')),
            onTap: () {
              _onSwitchTheme(ThemeMode.dark);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    ));
  }

  void _onSwitchTheme(ThemeMode theme) async {
    _viewModel.onSwitchTheme(theme);
  }
}
