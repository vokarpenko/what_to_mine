import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../platform/native_theme_sync.dart';
import 'theme_config.dart';

/// Read only local appearance settings, before runApp and its first frame.
/// This does not initialize the database or fetch any API data.
Future<void> restoreAppTheme({SharedPreferences? preferences}) async {
  final stored = preferences ?? await SharedPreferences.getInstance();
  var mode = ThemeMode.system;
  final settings = stored.getString('s');
  if (settings != null) {
    try {
      final decoded = jsonDecode(settings);
      final index = decoded is Map<String, dynamic>
          ? decoded['themeIndex']
          : null;
      if (index is int && index >= 0 && index < ThemeMode.values.length) {
        mode = ThemeMode.values[index];
      }
    } on FormatException {
      // Invalid appearance data falls back to the phone's theme.
    }
  }
  currentTheme.switchTheme(mode);
  await NativeThemeSync.apply(mode.index);
}
