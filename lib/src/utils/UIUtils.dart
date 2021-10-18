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
}
