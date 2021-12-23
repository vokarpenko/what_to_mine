import 'package:background_fetch/background_fetch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:what_to_mine/src/data/Scheduler/IBackgroundTaskScheduler.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/utils/Notificator.dart';

import '../../app.dart';

class BackgroundTaskScheduler implements IBackgroundTaskScheduler {
  BackgroundTaskScheduler();

  @override
  Future<void> enable(int minimumFetchInterval) async {
    await _configure(minimumFetchInterval);
    await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }

  @override
  Future<void> disable() async {
    BackgroundFetch.stop().then((_) {
      print('BackgroundFetch stop success');
    });
  }

  Future<void> _configure(int minimumFetchInterval) async {
    // Настройка BackgroundFetch.
    await BackgroundFetch.configure(
        BackgroundFetchConfig(
            startOnBoot: false,
            minimumFetchInterval: minimumFetchInterval,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // Выполняется, когда приложение работает в фоне.
      await _showNotificationsInTheBackground();
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // Обработчик таймаута задачи
      print('Task timeout handler');
      BackgroundFetch.finish(taskId);
    });
  }

  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      // This task has exceeded its allowed running-time.
      // You must stop what you're doing and immediately .finish(taskId)
      BackgroundFetch.finish(taskId);
      return;
    }
    // Выполняется, когда приложение закрыто.
    await initializeApp();
    await _showNotificationsInTheBackground();
    print('backgroundFetchHeadlessTask');
    BackgroundFetch.finish(taskId);
  }

  static Future<void> _showNotificationsInTheBackground() async {
    Services.currenciesService.getMostProfitableCurrency().then((currency) {
      String title = 'now_profitable_to_mine_message'.tr() + ' ${currency.cryptoCurrency.name}';
      String body = 'earnings_appbar_title'.tr() +
          ' ${currency.dayEarningInCurrency.toStringAsFixed(2)} USD ' +
          'per_day'.tr() +
          '!';
      Notificator().showNotification(0, title, body);
    }).catchError((Object error) {
      String errorMessage = 'error_get_top_currency'.tr() + ': \n ${error.toString()}';
      print(errorMessage);
      throw Exception(errorMessage);
    });
  }
}
