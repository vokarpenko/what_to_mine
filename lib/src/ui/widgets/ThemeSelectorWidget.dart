import 'package:flutter/material.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/ui/theme/ThemeConfig.dart';

class ThemeSelectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('Системная'),
            leading: Icon(Icons.invert_colors),
            onTap: () {
              _onSwitchTheme(ThemeMode.system);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Светлая'),
            leading: Icon(Icons.invert_colors),
            onTap: () {
              _onSwitchTheme(ThemeMode.light);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Темная'),
            leading: Icon(Icons.invert_colors),
            onTap: () {
              _onSwitchTheme(ThemeMode.dark);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    ));
  }

  Future<void> _onSwitchTheme(ThemeMode value) async {
    print(value);
    currentTheme.switchTheme(value);
    await Services.settingsService.saveThemeIndex(value.index);
  }
}
