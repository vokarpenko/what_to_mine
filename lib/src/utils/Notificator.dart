import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:what_to_mine/src/ui/contstants.dart';

class Notificator {
  static final Notificator _instance = Notificator._();
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  NotificationDetails _platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails('Channel id', 'What to mine notification channel',
          channelShowBadge: true, color: AppColors.orange, importance: Importance.max, priority: Priority.max),
      iOS: IOSNotificationDetails());

  factory Notificator() {
    return _instance;
  }

  Notificator._();

  Future<void> _initialize() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  Future<void> showNotification(int id, String title, String body) async {
    if (_flutterLocalNotificationsPlugin == null) await _initialize();
    await _flutterLocalNotificationsPlugin!.show(id, title, body, _platformChannelSpecifics, payload: '');
  }

  Future<void> hideNotification(int id) async {
    if (_flutterLocalNotificationsPlugin == null) await _initialize();
    await _flutterLocalNotificationsPlugin!.cancel(id);
  }

  Future<void> hideAll() async {
    if (_flutterLocalNotificationsPlugin == null) await _initialize();
    await _flutterLocalNotificationsPlugin!.cancelAll();
  }
}
