import 'package:what_to_mine/src/logic/BackgroundTaskSchedulerService.dart';
import 'package:what_to_mine/src/logic/SettingsService.dart';

import 'CurrenciesService.dart';
import 'GpuService.dart';
import 'HashAlgorithmService.dart';

class Services {
  static CurrenciesService? _currenciesService;
  static GpuService? _gpuService;
  static HashAlgorithmService? _hashAlgorithmService;
  static SettingsService? _settingsService;
  static BackgroundTaskSchedulerService? _backgroundTaskSchedulerService;
  Services._();

  static bool isInitialized() {
    return null != _currenciesService &&
        null != _gpuService &&
        null != _hashAlgorithmService &&
        null != _settingsService &&
        null != _backgroundTaskSchedulerService;
  }

  static void initialize(
      {required CurrenciesService currenciesService,
      required GpuService gpuService,
      required HashAlgorithmService hashAlgorithmService,
      required SettingsService settingsService,
      required BackgroundTaskSchedulerService backgroundTaskSchedulerService}) {
    _currenciesService = currenciesService;
    _gpuService = gpuService;
    _hashAlgorithmService = hashAlgorithmService;
    _settingsService = settingsService;
    _backgroundTaskSchedulerService = backgroundTaskSchedulerService;
  }

  static CurrenciesService get currenciesService => _currenciesService!;

  static GpuService get gpuService => _gpuService!;

  static HashAlgorithmService get hashAlgorithmService => _hashAlgorithmService!;

  static SettingsService get settingsService => _settingsService!;

  static BackgroundTaskSchedulerService get backgroundTaskSchedulerService => _backgroundTaskSchedulerService!;
}
