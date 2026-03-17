import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'ptodolist_reminder';
  static const _channelName = 'Daily Reminder';
  static const _notificationId = 1;
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  /// 미완료 항목이 있으면 알림 표시, 없으면 무음
  static Future<void> showSmartReminder({
    required DailyRecord? dailyRecord,
    required List<AdditionalTask> todayTasks,
  }) async {
    final routineIncomplete = dailyRecord?.routineCompletions.values
            .where((v) => !v)
            .length ??
        0;
    final taskIncomplete = todayTasks.where((t) => !t.isCompleted).length;
    final totalIncomplete = routineIncomplete + taskIncomplete;

    if (totalIncomplete == 0) {
      // 스마트 무음: 모든 항목 완료
      await _plugin.cancel(_notificationId);
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '자정 전 미완료 항목 알림',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      _notificationId,
      'pTODOlist',
      '아직 $totalIncomplete개의 할 일이 남았어요!',
      details,
    );
  }

  /// 알림 취소
  static Future<void> cancelReminder() async {
    await _plugin.cancel(_notificationId);
  }
}
