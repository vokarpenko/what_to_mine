import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/data/Gateway.dart';
import 'package:what_to_mine/src/data/cache/MemoryStorage.dart';
import 'package:what_to_mine/src/data/client/IMinerStatClient.dart';
import 'package:what_to_mine/src/data/client/MinerStatClient.dart';
import 'package:what_to_mine/src/data/db/AppDatabase.dart';
import 'package:what_to_mine/src/data/jsonReader/ILocalJsonReader.dart';
import 'package:what_to_mine/src/data/jsonReader/LocalJsonReader.dart';
import 'package:what_to_mine/src/logic/BackgroundTaskSchedulerService.dart';
import 'package:what_to_mine/src/logic/CurrenciesService.dart';
import 'package:what_to_mine/src/logic/GpuService.dart';
import 'package:what_to_mine/src/logic/HashAlgorithmService.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/logic/SettingsService.dart';
import 'package:what_to_mine/src/logic/gateway/IGateway.dart';

import 'data/Scheduler/BackgroundTaskScheduler.dart';

Future<void> initializeApp() async {
  if (Services.isInitialized()) {
    print('Application initialized already');
    return;
  }

  SharedPreferences preferences = await SharedPreferences.getInstance();
  IMinerStatClient minerStatClient = MinerStatClient();
  ILocalJsonReader jsonReader = LocalJsonReader();
  MemoryStorage cache = MemoryStorage();
  AppDatabase database = await AppDatabase.create();
  BackgroundTaskScheduler backgroundScheduler = BackgroundTaskScheduler();
  IGateway gateway = Gateway(
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
  BackgroundTaskSchedulerService backgroundTaskSchedulerService = BackgroundTaskSchedulerService(gateway: gateway);

  Services.initialize(
      currenciesService: currenciesService,
      gpuService: gpuService,
      hashAlgorithmService: algorithmService,
      settingsService: settingsService,
      backgroundTaskSchedulerService: backgroundTaskSchedulerService);

  print("Application successful initialized");
}