import 'package:flutter/material.dart';

class AppTheme with ChangeNotifier {
  static ThemeMode _theme = ThemeMode.system;

  ThemeMode currentTheme() {
    return _theme;
  }

  void switchTheme(ThemeMode theme) {
    _theme = theme;
    notifyListeners();
  }
}
