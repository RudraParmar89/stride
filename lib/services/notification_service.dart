import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    // 1. Setup Timezone
    String timeZoneName;
    try {
      final dynamic result = await FlutterTimezone.getLocalTimezone();
      timeZoneName = result.toString();
    } catch (e) {
      timeZoneName = 'UTC';
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Setup Icons
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  // =========================================================
  // 1. MASCOT MESSAGE (DUOLINGO STYLE)
  // =========================================================
  static Future<void> showMascotNotification({
    required String title,
    required String body,
  }) async {
    final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _notificationsPlugin.show(
      id,
      title, // e.g. "Astra here..."
      body,  // e.g. "The shadows are gathering..."
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mascot_channel',
          'Astra Messages',
          channelDescription: 'Motivational messages from your companion',
          importance: Importance.max,
          priority: Priority.high,

          // --- THE MAGIC SAUCE ---
          // This renders the image on the right/left side like a chat head
          largeIcon: DrawableResourceAndroidBitmap('astra_head'),

          // Tint color for the small icon/app name (Use your Purple)
          color: Color(0xFF6C63FF),

          // Allows for longer text to be fully readable
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  // =========================================================
  // 2. PROJECT DEADLINES (One-time)
  // =========================================================
  static Future<void> scheduleDeadlineNotification({
    required int id,
    required String title,
    required DateTime deadline,
  }) async {
    final scheduledDate = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      9, // 9:00 AM
      0,
    );

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      '⚠️ DEADLINE ALERT: $title',
      'This operation requires your attention today, Hunter.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'project_channel',
          'Project Deadlines',
          channelDescription: 'Notifications for long-term project deadlines',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFFF5252),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // =========================================================
  // 3. DAILY ALARMS (Recurring)
  // =========================================================
  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      '⏰ SYSTEM ALERT: $title',
      'It is time to act, Hunter.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Daily system alerts',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF6C63FF),
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
    );
  }

  // =========================================================
  // 4. CANCEL NOTIFICATION
  // =========================================================
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}