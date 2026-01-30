import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> _morningMessages = [
    "The Notice Board has new requests.",
    "Dawn breaks. Adventure awaits.",
    "Coins don't earn themselves, Witcher.",
    "A new day, a new contract.",
    "The path is clear. Walk it.",
    "Rise and shine, hero. XP awaits.",
    "The world needs you today.",
  ];

  final List<String> _eveningMessages = [
    "The sun is setting on your tasks.",
    "Finish your quests before the midnight bell.",
    "Don't let your streak turn to ash.",
    "The tavern awaits, but work comes first.",
    "Last chance to claim your XP.",
    "Night falls. Is your journal complete?",
    "The monsters of procrastination draw near.",
  ];

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyNotifications() async {
    // Cancel existing to avoid duplicates
    await cancelAllNotifications();

    final now = tz.TZDateTime.now(tz.local);

    // Schedule for the next 7 days to ensure variety
    for (int i = 0; i < 7; i++) {
      // 9:00 AM - Morning
      await _scheduleOneOff(
        id: 100 + i, // Unique ID per day
        title: 'New Contracts Available',
        body: _getRandomMessage(_morningMessages),
        scheduledDate: _nextInstanceOfTime(now, 9, 0, i),
      );

      // 9:00 PM (21:00) - Evening
      await _scheduleOneOff(
        id: 200 + i, // Unique ID per day
        title: 'The Day is Ending',
        body: _getRandomMessage(_eveningMessages),
        scheduledDate: _nextInstanceOfTime(now, 21, 0, i),
      );
    }
  }

  Future<void> _scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summons_channel',
          'Daily Summons',
          channelDescription: 'Daily reminders for quests',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // No matchDateTimeComponents because we want unique messages per day
    );
  }

  tz.TZDateTime _nextInstanceOfTime(tz.TZDateTime now, int hour, int minute, int dayOffset) {
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // If scheduling for today but time passed, move to next day (or handle offset)
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Add the day offset (0 = today/tomorrow depending on time, 1 = +1 day, etc.)
    return scheduledDate.add(Duration(days: dayOffset));
  }

  String _getRandomMessage(List<String> pool) {
    return pool[Random().nextInt(pool.length)];
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
