import 'package:flutter/material.dart';

class AppThemeData {
  static const MaterialColor mainColor = Colors.red;

  AppThemeData._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    primarySwatch: mainColor,
    brightness: Brightness.light,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    switchTheme: SwitchThemeData(
      overlayColor: WidgetStateProperty.all(mainColor.withAlpha(30)),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return mainColor.shade700;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return mainColor.shade400;
        }
        return Colors.white70;
      }),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: mainColor,
      secondary: mainColor,
      brightness: Brightness.dark,
      surface: Colors.grey[800],
      onSurface: Colors.white,
    ),
  );
}
