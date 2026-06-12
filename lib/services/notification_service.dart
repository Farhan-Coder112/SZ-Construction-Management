import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    
    // Platform-specific initialization settings
    InitializationSettings initSettings;
    
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Windows initialization (we can use Linux as fallback or just minimal settings)
      const windowsSettings = LinuxInitializationSettings(defaultActionName: 'Open');
      initSettings = const InitializationSettings(linux: windowsSettings);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      initSettings = const InitializationSettings(android: androidSettings);
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      const iosSettings = DarwinInitializationSettings();
      initSettings = const InitializationSettings(iOS: iosSettings, macOS: iosSettings);
    } else {
      // Default/other platforms
      initSettings = const InitializationSettings();
    }

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _setupFirebaseMessaging();
    _initialized = true;
  }

  Future<void> _setupFirebaseMessaging() async {
    NotificationSettings settings = await _messaging.requestPermission();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      showNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _handleBackgroundMessageTap(RemoteMessage message) {
    // Handle navigation when notification is tapped
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Platform-specific notification details
    NotificationDetails details;
    
    if (defaultTargetPlatform == TargetPlatform.windows) {
      const windowsDetails = LinuxNotificationDetails();
      details = const NotificationDetails(linux: windowsDetails);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      const androidDetails = AndroidNotificationDetails(
        'sz_construction_channel',
        'SZ Construction Notifications',
        channelDescription: 'Notifications for SZ Construction Management',
        importance: Importance.high,
        priority: Priority.high,
      );
      details = const NotificationDetails(android: androidDetails);
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      const iosDetails = DarwinNotificationDetails();
      details = const NotificationDetails(iOS: iosDetails);
    } else {
      details = const NotificationDetails();
    }
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Platform-specific notification details
    NotificationDetails details;
    
    if (defaultTargetPlatform == TargetPlatform.windows) {
      const windowsDetails = LinuxNotificationDetails();
      details = const NotificationDetails(linux: windowsDetails);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      const androidDetails = AndroidNotificationDetails(
        'sz_construction_channel',
        'SZ Construction Notifications',
        channelDescription: 'Notifications for SZ Construction Management',
        importance: Importance.high,
        priority: Priority.high,
      );
      details = const NotificationDetails(android: androidDetails);
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      const iosDetails = DarwinNotificationDetails();
      details = const NotificationDetails(iOS: iosDetails);
    } else {
      details = const NotificationDetails();
    }
    
    await _notifications.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
