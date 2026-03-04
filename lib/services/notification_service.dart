import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // --- INITIALIZATION ---
  static Future<void> init() async {
    tz.initializeTimeZones();

    await AwesomeNotifications().initialize(
      // Ensure you have an app icon, or use null for default flutter icon
      null,
      [
        // 1. High Priority Channel (Timer, Alarm) - For Clock Screen
        NotificationChannel(
          channelGroupKey: 'tools_channel_group',
          channelKey: 'tools_channel',
          channelName: 'Tools & Utilities',
          channelDescription: 'Timers, Alarms, and Stopwatch',
          defaultColor: const Color(0xFF00D2D3),
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
          criticalAlerts: true, // Bypasses silent mode if permissions granted
        ),
        // 2. Schedule Channel (Calendar) - For Calendar Screen
        NotificationChannel(
          channelGroupKey: 'schedule_channel_group',
          channelKey: 'calendar_channel',
          channelName: 'Calendar Events',
          channelDescription: 'Scheduled agenda items',
          defaultColor: const Color(0xFF6C63FF),
          importance: NotificationImportance.High,
          playSound: true,
        ),
        // 3. Engagement Channel (Streaks, Daily, Training) - For Profile Screen
        NotificationChannel(
          channelGroupKey: 'engagement_channel_group',
          channelKey: 'engagement_channel',
          channelName: 'Astra Uplink',
          channelDescription: 'Daily briefings and streak alerts',
          defaultColor: const Color(0xFFFFD700), // Gold
          importance: NotificationImportance.High,
          playSound: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(channelGroupKey: 'tools_channel_group', channelGroupName: 'Tools'),
        NotificationChannelGroup(channelGroupKey: 'schedule_channel_group', channelGroupName: 'Schedule'),
        NotificationChannelGroup(channelGroupKey: 'engagement_channel_group', channelGroupName: 'Engagement'),
      ],
      debug: true,
    );

    // Check permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  // =========================================================
  // FIX: METHODS REQUIRED BY CLOCK SCREEN
  // =========================================================

  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required DateTime time,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'tools_channel',
        title: '⏰ $title',
        body: 'Alarm is ringing!',
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        // Make sure this asset exists, or comment out if not
        bigPicture: 'asset://assets/notifications/astra_focused.png',
        notificationLayout: NotificationLayout.BigPicture,
      ),
      schedule: NotificationCalendar.fromDate(date: time),
      actionButtons: [
        NotificationActionButton(key: 'DISMISS', label: 'Dismiss', actionType: ActionType.DismissAction),
      ],
    );
  }

  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // =========================================================
  // FIX: METHODS REQUIRED BY CALENDAR SCREEN
  // =========================================================

  static Future<void> scheduleDeadlineNotification({
    required int id,
    required String title,
    required DateTime date,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'calendar_channel',
        title: '📅 Deadline: $title',
        body: 'Scheduled for ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
        // Make sure this asset exists, or comment out if not
        bigPicture: 'asset://assets/notifications/astra_calendar.png',
        notificationLayout: NotificationLayout.BigPicture,
      ),
      schedule: NotificationCalendar.fromDate(date: date),
    );
  }

  // =========================================================
  // METHODS FOR PROFILE SCREEN (Engagement)
  // =========================================================

  // 1. Daily Summary
  static Future<void> scheduleDailySummary(TimeOfDay time) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 888,
        channelKey: 'engagement_channel',
        title: '☀️ Daily Briefing',
        body: 'Commander, your tasks and stats are ready for review.',
        bigPicture: 'asset://assets/notifications/astra_happy.png',
        notificationLayout: NotificationLayout.BigPicture,
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        repeats: true,
      ),
    );
  }

  // 2. Training Reminders
  static Future<void> scheduleTrainingReminders(TimeOfDay time1, TimeOfDay time2) async {
    // Session 1
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 701,
        channelKey: 'engagement_channel',
        title: '⚡ Training Session 1',
        body: 'Time to grind XP. Let\'s get moving!',
        bigPicture: 'asset://assets/notifications/astra_happy.png',
        notificationLayout: NotificationLayout.BigPicture,
      ),
      schedule: NotificationCalendar(hour: time1.hour, minute: time1.minute, repeats: true),
    );

    // Session 2
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 702,
        channelKey: 'engagement_channel',
        title: '🔥 Training Session 2',
        body: 'Finish the day strong, Commander.',
        bigPicture: 'asset://assets/notifications/astra_focused.png',
        notificationLayout: NotificationLayout.BigPicture,
      ),
      schedule: NotificationCalendar(hour: time2.hour, minute: time2.minute, repeats: true),
    );
  }

  // 3. Sad Astra (Streak Protection)
  static Future<void> resetStreakProtection() async {
    // Cancel any existing "Sad Astra" alert
    await AwesomeNotifications().cancel(666);

    // Schedule new one for 24 hours later
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 666,
        channelKey: 'engagement_channel',
        title: 'Astra misses you...',
        body: 'We haven\'t seen you in 24h. Your streak is at risk!',
        bigPicture: 'asset://assets/notifications/astra_sad.png',
        notificationLayout: NotificationLayout.BigPicture,
      ),
      schedule: NotificationCalendar.fromDate(
        date: DateTime.now().add(const Duration(hours: 24)),
      ),
    );
  }

  // =========================================================
  // DUMMY NOTIFICATIONS FOR TESTING
  // =========================================================

  static Future<void> sendDummyNotification(String type) async {
    final now = DateTime.now();
    
    switch (type) {
      case 'achievement':
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch ~/ 1000,
            channelKey: 'engagement_channel',
            title: '🏆 Achievement Unlocked!',
            body: 'You\'ve completed 7 day streak! Astra is proud of you!',
            bigPicture: 'asset://assets/notifications/astra_happy.png',
            notificationLayout: NotificationLayout.BigPicture,
          ),
        );
        break;
      case 'reminder':
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch ~/ 1000,
            channelKey: 'engagement_channel',
            title: '⚡ Daily Challenge Ready!',
            body: 'New tasks available! Complete 3 quests to earn 500 XP.',
          ),
        );
        break;
      case 'mission':
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch ~/ 1000,
            channelKey: 'engagement_channel',
            title: '🎯 Critical Mission!',
            body: 'Cardio Run (30 min) - Earn +60 XP & +4 Embers',
          ),
        );
        break;
      case 'streak':
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch ~/ 1000,
            channelKey: 'engagement_channel',
            title: '🔥 Streak Alert!',
            body: 'Your 15 day streak is ending in 2 hours. Keep it alive!',
            bigPicture: 'asset://assets/notifications/astra_focused.png',
            notificationLayout: NotificationLayout.BigPicture,
          ),
        );
        break;
      case 'reward':
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch ~/ 1000,
            channelKey: 'engagement_channel',
            title: '💰 Rewards Pending!',
            body: 'You have 250 Embers ready to spend at the Supply Depot.',
          ),
        );
        break;
      case 'levelup':
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch ~/ 1000,
            channelKey: 'engagement_channel',
            title: '⬆️ Level Up!',
            body: 'Congratulations! You\'ve reached Level 5. New abilities unlocked!',
            bigPicture: 'asset://assets/notifications/astra_happy.png',
            notificationLayout: NotificationLayout.BigPicture,
          ),
        );
        break;
    }
  }

  // --- UTILITIES ---

  static Future<void> cancelBriefing() async {
    await AwesomeNotifications().cancel(888);
  }

  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  static Future<void> showInstant(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'engagement_channel',
        title: title,
        body: body,
      ),
    );
  }
}