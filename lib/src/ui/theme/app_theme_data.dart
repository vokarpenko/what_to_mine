import 'package:flutter/material.dart';

class AppThemeData {
  static const MaterialColor mainColor = Colors.red;

  AppThemeData._();

  static final ThemeData lightTheme = ThemeData(primarySwatch: mainColor, brightness: Brightness.light);

  static final ThemeData darkTheme = ThemeData(
      switchTheme: SwitchThemeData(
        overlayColor: MaterialStateProperty.all(mainColor.withAlpha(30)),
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return mainColor.shade700;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return mainColor.shade400;
          }
          return Colors.white70;
        }),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: mainColor,
          primaryVariant: mainColor,
          secondary: mainColor,
          secondaryVariant: mainColor,
          brightness: Brightness.dark,
          surface: Colors.grey[800],
          onSurface: Colors.white));
}
