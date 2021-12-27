import 'dart:io';

import 'package:flutter/material.dart';

class UIUtils {
  static void hideKeyboard() {
    if (FocusManager.instance.primaryFocus != null) FocusManager.instance.primaryFocus!.unfocus();
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  static Locale getFallbackLocale() {
    String deviceLocale = Platform.localeName;
    if (deviceLocale == 'ru_RU')
      return Locale('ru');
    else
      return Locale('en');
  }
}
