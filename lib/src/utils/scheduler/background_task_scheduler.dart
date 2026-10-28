import 'package:background_fetch/background_fetch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_profitability_check.dart';
import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/logic/services.dart';
import 'package:what_to_mine/src/utils/notificator.dart';
import 'package:what_to_mine/src/utils/scheduler/background_scheduler.dart';

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
    await BackgroundFetch.stop();
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
        requiredNetworkType: NetworkType.NONE,
      ),
      (String taskId) async {
        // Выполняется, когда приложение работает в фоне.
        try {
          await _runDailyCheck(
            'now_profitable_to_mine_message'.tr(),
            'earnings_appbar_title'.tr(),
            'per_day'.tr(),
          );
        } catch (error) {
          print('Background profitability check failed: $error');
        } finally {
          BackgroundFetch.finish(taskId);
        }
      },
      (String taskId) async {
        // Обработчик таймаута задачи
        print('Task timeout handler');
        BackgroundFetch.finish(taskId);
      },
    );
  }

  @pragma('vm:entry-point')
  static void backgroundFetchHeadlessTask(HeadlessEvent task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      // This task has exceeded its allowed running-time.
      // You must stop what you're doing and immediately .finish(taskId)
      BackgroundFetch.finish(taskId);
      return;
    }
    try {
      await initializeApp();
      // A headless task has no localized widget context.
      await _runDailyCheck(
        'It is now profitable to mine',
        'Earning',
        'per day',
      );
    } catch (error) {
      print('Headless profitability check failed: $error');
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }

  static Future<void> _runDailyCheck(
    String message,
    String title,
    String perDay,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await DailyProfitabilityCheck(
      preferences: preferences,
    ).run(() => _showNotificationsInTheBackground(message, title, perDay));
  }

  static Future<void> _showNotificationsInTheBackground(
    String nowProfitableToMineMessage,
    String earningsTitle,
    String perDayText,
  ) async {
    final earnings = await Services.currenciesService
        .getMostProfitableCurrency();
    if (earnings != null) {
      final title =
          '$nowProfitableToMineMessage ${earnings.cryptoCurrency.name}';
      final body =
          '$earningsTitle ${earnings.netDayEarningInCurrency.toStringAsFixed(2)} USD $perDayText!';
      await Notificator().showNotification(sendNotification, title, body);
    }
  }
}
