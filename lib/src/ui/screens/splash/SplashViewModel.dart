import 'dart:async';

import 'package:what_to_mine/src/data/Gateway.dart';
import 'package:what_to_mine/src/data/cache/MemoryStorage.dart';
import 'package:what_to_mine/src/data/client/IMinerStatClient.dart';
import 'package:what_to_mine/src/data/client/MinerStatClient.dart';
import 'package:what_to_mine/src/data/db/AppDatabase.dart';
import 'package:what_to_mine/src/data/local/ILocalJsonReader.dart';
import 'package:what_to_mine/src/data/local/LocalJsonReader.dart';
import 'package:what_to_mine/src/logic/CurrenciesService.dart';
import 'package:what_to_mine/src/logic/GpuService.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/logic/gateway/IGateway.dart';
import 'package:what_to_mine/src/utils/SysUtils.dart';

class SplashViewModel {
  final _loading = StreamController<bool>();
  final _errorMessage = StreamController<String?>();
  final _openHomeScreen = StreamController();

  Stream<bool> get loading => _loading.stream;
  Stream<String?> get errorMessage => _errorMessage.stream;
  Stream get openHomeScreen => _openHomeScreen.stream;

  SplashViewModel();
  void onViewInitState() async {
    await _initializeApp();

    Services.currenciesService.getCryptoCurrenciesList().whenComplete(() async {
      await SysUtils.delay(2);
      _openHomeScreen.add(true);
    });
  }

  void onViewDispose() async {
    _loading.close();
    _errorMessage.close();
    _openHomeScreen.close();
  }

  Future<void> _initializeApp() async {
    if (Services.isInitialized()) {
      print('Application initialized already');
      return;
    }

    IMinerStatClient minerStatClient = MinerStatClient();
    ILocalJsonReader jsonReader = LocalJsonReader();
    MemoryStorage cache = MemoryStorage();
    AppDatabase database = await AppDatabase.create();
    IGateway gateway = Gateway(client: minerStatClient, jsonReader: jsonReader, cache: cache, database: database);
    CurrenciesService currenciesService = CurrenciesService(gateway: gateway);
    GpuService gpuService = GpuService(gateway: gateway);
    Services.initialize(currenciesService: currenciesService, gpuService: gpuService);
    print("Application successful initialized");
  }
}
