import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/gateway.dart';
import 'package:what_to_mine/src/ui/home.dart';
import 'package:what_to_mine/src/ui/screens/introduction/intro_screen.dart';
import 'package:what_to_mine/src/ui/screens/screen_routes.dart';
import 'package:what_to_mine/src/ui/screens/splash/splash_screen.dart';
import 'package:what_to_mine/src/ui/theme/app_theme_data.dart';
import 'package:what_to_mine/src/ui/theme/theme_config.dart';
import 'package:what_to_mine/src/utils/scheduler/background_scheduler.dart';
import 'package:what_to_mine/src/utils/scheduler/background_task_scheduler.dart';

import 'data/cache/memory_storage.dart';
import 'data/client/api_client.dart';
import 'data/client/btc_usd_rate_client.dart';
import 'data/client/what_to_mine_client.dart';
import 'data/db/app_database.dart';
import 'logic/currencies_service.dart';
import 'logic/favorites_store.dart';
import 'logic/gpu_service.dart';
import 'logic/hash_algorithm_service.dart';
import 'logic/scheduler_service.dart';
import 'logic/services.dart';
import 'logic/settings_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    currentTheme.removeListener(_onThemeChanged);
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
      builder: (context, child) => Actions(
        actions: {
          EditableTextTapOutsideIntent:
              CallbackAction<EditableTextTapOutsideIntent>(
                onInvoke: (intent) {
                  intent.focusNode.unfocus();
                  return null;
                },
              ),
        },
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: ScreenRoutes.splashScreen,
      routes: {
        ScreenRoutes.splashScreen: (BuildContext context) =>
            const SplashScreen(),
        ScreenRoutes.homeScreen: (BuildContext context) => const Home(),
        ScreenRoutes.introScreen: (BuildContext context) => const IntroScreen(),
      },
    );
  }
}

Future<void> initializeApp({
  ApiClient? client,
  AppDatabase? appDatabase,
  BtcUsdRateClient? exchangeRates,
}) async {
  if (Services.isInitialized()) {
    print('Application initialized already');
    return;
  }

  SharedPreferences preferences = await SharedPreferences.getInstance();
  ApiClient apiClient = client ?? WhatToMineClient(preferences: preferences);
  MemoryStorage cache = MemoryStorage();
  AppDatabase database = appDatabase ?? await AppDatabase.create();
  IBackgroundTaskScheduler backgroundScheduler = BackgroundTaskScheduler();
  Gateway gateway = Gateway(
    client: apiClient,
    cache: cache,
    database: database,
    preferences: preferences,
    backgroundScheduler: backgroundScheduler,
  );

  // Сервисы
  CurrenciesService currenciesService = CurrenciesService(
    gateway: gateway,
    exchangeRates: exchangeRates ?? BtcUsdRateClient(preferences: preferences),
  );
  GpuService gpuService = GpuService(gateway: gateway);
  HashAlgorithmService algorithmService = HashAlgorithmService(
    gateway: gateway,
  );
  SettingsService settingsService = SettingsService(gateway: gateway);
  SchedulerService schedulerService = SchedulerService(
    schedulerGateway: gateway,
    settingsGateway: gateway,
  );

  Services.initialize(
    currenciesService: currenciesService,
    favorites: FavoritesStore(preferences: preferences),
    gpuService: gpuService,
    hashAlgorithmService: algorithmService,
    settingsService: settingsService,
    backgroundTaskSchedulerService: schedulerService,
  );

  print('Application successful initialized');
}
