import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/Gateway.dart';
import 'package:what_to_mine/src/ui/Home.dart';
import 'package:what_to_mine/src/ui/screens/introduction/intro_screen.dart';
import 'package:what_to_mine/src/ui/screens/screen_routes.dart';
import 'package:what_to_mine/src/ui/screens/splash/splash_screen.dart';
import 'package:what_to_mine/src/ui/theme/app_theme_data.dart';
import 'package:what_to_mine/src/ui/theme/theme_config.dart';
import 'package:what_to_mine/src/utils/scheduler/background_scheduler.dart';
import 'package:what_to_mine/src/utils/scheduler/background_task_scheduler.dart';

import 'data/cache/memory_storage.dart';
import 'data/client/api_client.dart';
import 'data/client/miner_stat_client.dart';
import 'data/db/app_database.dart';
import 'data/json_reader/data_reader.dart';
import 'data/json_reader/json_reader.dart';
import 'logic/currencies_service.dart';
import 'logic/gpu_service.dart';
import 'logic/hash_algorithm_service.dart';
import 'logic/scheduler_service.dart';
import 'logic/services.dart';
import 'logic/settings_service.dart';

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
  ApiClient minerStatClient = MinerStatClient();
  DataReader jsonReader = JsonReader();
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
