import 'package:checklist/services/local_storage.dart';
import 'package:checklist/util/task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _lastOpenKey = 'last_opened_at';
  static const _nudgeIds = [2001, 2002, 2003];

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> markAppOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastOpenKey, DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getLastOpenedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastOpenKey);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static Future<void> scheduleTaskNudges(
    List<Task> tasks,
    AppPreferences preferences,
  ) async {
    await initialize();
    await cancelTaskNudges();

    if (!preferences.notificationsEnabled) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pendingTasks = tasks.where((task) => !task.isDone).toList();
    if (pendingTasks.isEmpty) return;

    final overdueCount =
        pendingTasks.where((task) => _dateOnly(task.dueDate).isBefore(today)).length;
    final dueTodayCount =
        pendingTasks.where((task) => _dateOnly(task.dueDate) == today).length;

    final messages = [
      _composeMessage(
        pendingCount: pendingTasks.length,
        overdueCount: overdueCount,
        dueTodayCount: dueTodayCount,
        variant: 0,
      ),
      _composeMessage(
        pendingCount: pendingTasks.length,
        overdueCount: overdueCount,
        dueTodayCount: dueTodayCount,
        variant: 1,
      ),
      _composeMessage(
        pendingCount: pendingTasks.length,
        overdueCount: overdueCount,
        dueTodayCount: dueTodayCount,
        variant: 2,
      ),
    ];

    final offsets = [4, 8, 12];
    for (var i = 0; i < offsets.length; i++) {
      final scheduled = tz.TZDateTime.from(
        now.add(Duration(hours: offsets[i])),
        tz.local,
      );
      await _plugin.zonedSchedule(
        _nudgeIds[i],
        messages[i].title,
        messages[i].body,
        scheduled,
        NotificationDetails(
          android: _androidDetailsFor(preferences),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelTaskNudges() async {
    for (final id in _nudgeIds) {
      await _plugin.cancel(id);
    }
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static AndroidNotificationDetails _androidDetailsFor(
    AppPreferences preferences,
  ) {
    final soundKey = preferences.soundEnabled ? 'sound_on' : 'sound_off';
    final vibrationKey =
        preferences.vibrationEnabled ? 'vibration_on' : 'vibration_off';

    return AndroidNotificationDetails(
      'task_reminders_${soundKey}_$vibrationKey',
      'Task reminders',
      channelDescription: 'Funny nudges and overdue task reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: preferences.soundEnabled,
      enableVibration: preferences.vibrationEnabled,
    );
  }

  static _NotificationCopy _composeMessage({
    required int pendingCount,
    required int overdueCount,
    required int dueTodayCount,
    required int variant,
  }) {
    final pendingLine =
        pendingCount == 1 ? '1 task' : '$pendingCount tasks';
    final overdueLine =
        overdueCount == 0
            ? 'nothing overdue yet'
            : overdueCount == 1
            ? '1 overdue task'
            : '$overdueCount overdue tasks';
    final dueTodayLine =
        dueTodayCount == 0
            ? 'no tasks due today'
            : dueTodayCount == 1
            ? '1 task due today'
            : '$dueTodayCount tasks due today';

    switch (variant) {
      case 0:
        return _NotificationCopy(
          title: 'Tiny nudge from checkList',
          body: 'You still have $pendingLine waiting. $dueTodayLine.',
        );
      case 1:
        return _NotificationCopy(
          title: 'Your tasks are pretending to be invisible',
          body: 'Nice try, but we can still see $pendingLine and $overdueLine.',
        );
      default:
        return _NotificationCopy(
          title: 'Checklist reunion pending',
          body: '$pendingLine still want a satisfying tick. Also: $overdueLine.',
        );
    }
  }
}

class _NotificationCopy {
  final String title;
  final String body;

  const _NotificationCopy({required this.title, required this.body});
}
