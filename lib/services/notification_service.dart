import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz_data.initializeTimeZones();
      
      String timeZoneName = 'Asia/Ho_Chi_Minh';
      try {
        final dynamic result = await FlutterTimezone.getLocalTimezone();
        if (result != null) {
          timeZoneName = result is String ? result : result.toString();
        }
      } catch (e) {
        debugPrint('Lỗi lấy múi giờ: $e');
      }

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('NotificationService: Timezone đã đặt -> $timeZoneName');
      } catch (e) {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      }
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      await _notificationsPlugin.initialize(
        const InitializationSettings(android: initializationSettingsAndroid),
        onDidReceiveNotificationResponse: (details) => debugPrint('Tapped: ${details.payload}'),
      );

      // Kênh v12 - Reset hoàn toàn cấu hình cho Xiaomi
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'skillarc_v12', 
        'Nhắc nhở quan trọng',
        description: 'Thông báo nhắc nhở mục tiêu hàng ngày (Ưu tiên cao)',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
        enableLights: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await requestPermissions();
    } catch (e) {
      debugPrint('Init Error: $e');
    }
  }

  Future<void> requestPermissions() async {
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
      try {
        await android.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('Yêu cầu quyền báo động thất bại: $e');
      }
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final scheduledDate = _nextInstanceOfTime(hour, minute);
      debugPrint('--- [LẬP LỊCH V12 DAILY] ---');
      
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'skillarc_v12',
            'Nhắc nhở quan trọng',
            channelDescription: 'Thông báo nhắc nhở mục tiêu hàng ngày',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            visibility: NotificationVisibility.public,
            ongoing: false,
            autoCancel: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Đã đặt lịch hàng ngày lúc: $scheduledDate');
    } catch (e) {
      debugPrint('Schedule Daily Error: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Hẹn giờ 7:00 sáng hàng ngày để test độ ổn định
  Future<void> schedule7AMTest() async {
    await scheduleDailyNotification(
      id: 700,
      title: 'Chào buổi sáng! ☀️',
      body: 'Đã đến 7:00 sáng, bắt đầu mục tiêu học tập hôm nay thôi!',
      hour: 7,
      minute: 0,
    );
  }

  Future<void> showInstantNotification({required int id, required String title, required String body}) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'skillarc_v12',
          'Nhắc nhở quan trọng',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }
}
