import 'dart:io';

import 'package:flutter/material.dart';
import 'package:what_to_mine/src/utils/SysUtils.dart';

class UIUtils {
  static void hideKeyboard() {
    if (FocusManager.instance.primaryFocus != null) FocusManager.instance.primaryFocus!.unfocus();
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  static Future<void> showAlertDialog(BuildContext context, String titleText, String mainText, String buttonText,
      {bool barrierDismissible = true, Function? afterPopFunction, int afterPopFunctionDelay = 0}) async {
    return Future.delayed(Duration.zero, () {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(titleText),
              content: Text(mainText),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await SysUtils.delay(afterPopFunctionDelay);
                      await afterPopFunction?.call();
                    },
                    child: Text(buttonText))
              ],
            );
          });
    });
  }

  static Locale getFallbackLocale() {
    String deviceLocale = Platform.localeName;
    if (deviceLocale == 'ru_RU') {
      return const Locale('ru');
    } else {
      return const Locale('en');
    }
  }
}
