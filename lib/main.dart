import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/splash/SplashScreen.dart';
import 'package:what_to_mine/src/ui/theme/AppThemeData.dart';
import 'package:what_to_mine/src/ui/theme/ThemeConfig.dart';

import 'src/ui/Home.dart';
import 'src/ui/screens/ScreenRoutes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        saveLocale: true,
        fallbackLocale: Locale('en'),
        useOnlyLangCode: true,
        child: App()),
  );
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        themeMode: currentTheme.currentTheme(),
        theme: AppThemeData.lightTheme,
        darkTheme: AppThemeData.darkTheme,
        initialRoute: ScreenRoutes.splashScreen,
        routes: {
          ScreenRoutes.splashScreen: (BuildContext context) => SplashScreen(),
          ScreenRoutes.homeScreen: (BuildContext context) => Home(),
          //ScreenRoutes.settingsScreen: (BuildContext context) => SettingScreen()
        });
  }
}
