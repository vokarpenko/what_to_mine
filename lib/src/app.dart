import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/Gateway.dart';
import 'package:what_to_mine/src/data/cache/MemoryStorage.dart';
import 'package:what_to_mine/src/data/client/IMinerStatClient.dart';
import 'package:what_to_mine/src/data/client/MinerStatClient.dart';
import 'package:what_to_mine/src/data/db/AppDatabase.dart';
import 'package:what_to_mine/src/data/jsonReader/IJsonReader.dart';
import 'package:what_to_mine/src/logic/CurrenciesService.dart';
import 'package:what_to_mine/src/logic/GpuService.dart';
import 'package:what_to_mine/src/logic/HashAlgorithmService.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/logic/SettingsService.dart';
import 'package:what_to_mine/src/ui/Home.dart';
import 'package:what_to_mine/src/ui/screens/ScreenRoutes.dart';
import 'package:what_to_mine/src/ui/screens/introduction/IntroScreen.dart';
import 'package:what_to_mine/src/ui/screens/splash/SplashScreen.dart';
import 'package:what_to_mine/src/ui/theme/AppThemeData.dart';
import 'package:what_to_mine/src/ui/theme/ThemeConfig.dart';
import 'package:what_to_mine/src/utils/scheduler/BackgroundTaskScheduler.dart';
import 'package:what_to_mine/src/utils/scheduler/IBackgroundTaskScheduler.dart';

import 'data/jsonReader/JsonReader.dart';
import 'logic/SchedulerService.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

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
  void dispose() {
    super.dispose();
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
          ScreenRoutes.splashScreen: (BuildContext context) => const SplashScreen(),
          ScreenRoutes.homeScreen: (BuildContext context) => const Home(),
          ScreenRoutes.introScreen: (BuildContext context) => const IntroScreen()
        });
  }
}

Future<void> initializeApp() async {
  if (Services.isInitialized()) {
    print('Application initialized already');
    return;
  }

  SharedPreferences preferences = await SharedPreferences.getInstance();
  IMinerStatClient minerStatClient = MinerStatClient();
  IJsonReader jsonReader = JsonReader();
  MemoryStorage cache = MemoryStorage();
  AppDatabase database = await AppDatabase.create();
  IBackgroundTaskScheduler backgroundScheduler = BackgroundTaskScheduler();
  Gateway gateway = Gateway(
      client: minerStatClient,
      jsonReader: jsonReader,
      cache: cache,
      database: database,
      preferences: preferences,
      backgroundScheduler: backgroundScheduler);

  // Сервисы
  CurrenciesService currenciesService = CurrenciesService(gateway: gateway);
  GpuService gpuService = GpuService(gateway: gateway);
  HashAlgorithmService algorithmService = HashAlgorithmService(gateway: gateway);
  SettingsService settingsService = SettingsService(gateway: gateway);
  SchedulerService schedulerService = SchedulerService(schedulerGateway: gateway, settingsGateway: gateway);

  Services.initialize(
      currenciesService: currenciesService,
      gpuService: gpuService,
      hashAlgorithmService: algorithmService,
      settingsService: settingsService,
      backgroundTaskSchedulerService: schedulerService);

  print('Application successful initialized');
}
