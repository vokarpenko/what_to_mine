import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:what_to_mine/src/ui/constants.dart';

class Notificator {
  static final Notificator _instance = Notificator._();
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  final NotificationDetails _platformChannelSpecifics =
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'Channel id',
          'What to mine notification channel',
          channelShowBadge: true,
          color: AppColors.orange,
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(),
      );

  factory Notificator() {
    return _instance;
  }

  Notificator._();

  Future<void> _initialize() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _flutterLocalNotificationsPlugin!.initialize(
      settings: initializationSettings,
    );
  }

  Future<bool> requestPermission() async {
    if (_flutterLocalNotificationsPlugin == null) await _initialize();
    final android = _flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<void> showNotification(int id, String title, String body) async {
    if (_flutterLocalNotificationsPlugin == null) await _initialize();
    await _flutterLocalNotificationsPlugin!.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _platformChannelSpecifics,
      payload: '',
    );
  }

  Future<void> hideNotification(int id) async {
    if (_flutterLocalNotificationsPlugin == null) await _initialize();
    await _flutterLocalNotificationsPlugin!.cancel(id: id);
  }

  Future<void> hideAll() async {
    if (_flutterLocalNotificationsPlugin == null) await _initialize();
    await _flutterLocalNotificationsPlugin!.cancelAll();
  }
}
