import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/app.dart';
import 'package:what_to_mine/src/utils/ui_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        saveLocale: true,
        fallbackLocale: UIUtils.getFallbackLocale(),
        useOnlyLangCode: true,
        child: const App()),
  );
}
