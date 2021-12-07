import 'package:what_to_mine/src/logic/BackgroundTaskSchedulerService.dart';
import 'package:what_to_mine/src/logic/NotificationService.dart';

import 'CurrenciesService.dart';
import 'GpuService.dart';
import 'HashAlgorithmService.dart';

class Services {
  static CurrenciesService? _currenciesService;
  static GpuService? _gpuService;
  static HashAlgorithmService? _hashAlgorithmService;
  static NotificationService? _notificationService;
  static BackgroundTaskSchedulerService? _backgroundTaskSchedulerService;
  Services._();

  static bool isInitialized() {
    return null != _currenciesService &&
        null != _gpuService &&
        null != _hashAlgorithmService &&
        null != _notificationService &&
        null != _backgroundTaskSchedulerService;
  }

  static void initialize(
      {required CurrenciesService currenciesService,
      required GpuService gpuService,
      required HashAlgorithmService hashAlgorithmService,
      required NotificationService notificationService,
      required BackgroundTaskSchedulerService backgroundTaskSchedulerService}) {
    _currenciesService = currenciesService;
    _gpuService = gpuService;
    _hashAlgorithmService = hashAlgorithmService;
    _notificationService = notificationService;
    _backgroundTaskSchedulerService = backgroundTaskSchedulerService;
  }

  static CurrenciesService get currenciesService => _currenciesService!;

  static GpuService get gpuService => _gpuService!;

  static HashAlgorithmService get hashAlgorithmService => _hashAlgorithmService!;

  static NotificationService get notificationService => _notificationService!;

  static BackgroundTaskSchedulerService get backgroundTaskSchedulerService => _backgroundTaskSchedulerService!;
}
