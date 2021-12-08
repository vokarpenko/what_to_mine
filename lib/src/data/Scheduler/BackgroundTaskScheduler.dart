import 'package:background_fetch/background_fetch.dart';
import 'package:what_to_mine/src/data/Scheduler/IBackgroundTaskScheduler.dart';
import 'package:what_to_mine/src/logic/Services.dart';
import 'package:what_to_mine/src/ui/screens/splash/SplashViewModel.dart';
import 'package:what_to_mine/src/utils/Notificator.dart';

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
      print("*************************" + taskId);
      await _showNotificationsInTheBackground();
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // Обработчик таймаута задачи
      print("Task timeout handler");
      BackgroundFetch.finish(taskId);
    });
  }

  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    print("*************************" + taskId);
    if (isTimeout) {
      // This task has exceeded its allowed running-time.
      // You must stop what you're doing and immediately .finish(taskId)
      BackgroundFetch.finish(taskId);
      return;
    }
    // Выполняется, когда приложение закрыто.
    await SplashViewModel().initializeApp();
    await _showNotificationsInTheBackground();
    print('backgroundFetchHeadlessTask');
    BackgroundFetch.finish(taskId);
  }

  static Future<void> _showNotificationsInTheBackground() async {
    Services.currenciesService.getTopCurrency().then((currency) {
      String title = "Сейчас выгодно добывать ${currency.cryptoCurrency.name}";
      String body = "Доходность ${currency.dayEarningInCurrency.toStringAsFixed(2)} USD в день!";
      Notificator().showNotification(0, title, body);
    }).catchError((Object error) {
      String errorMessage = "Ошибка получения самой прибыльной монеты: \n ${error.toString()}";
      print(errorMessage);
      throw Exception(errorMessage);
    });
  }
}
