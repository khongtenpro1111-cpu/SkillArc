import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive/hive.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final _notificationBox = Hive.box('notificationBox');

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

      // Tích hợp Firebase Cloud Messaging (FCM)
      try {
        final fcm = FirebaseMessaging.instance;
        await fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        String? token = await fcm.getToken();
        debugPrint('FCM Token: $token');

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Nhận thông báo FCM ở Foreground: ${message.notification?.title}');
          if (message.notification != null) {
            showInstantNotification(
              id: message.hashCode,
              title: message.notification!.title ?? '',
              body: message.notification!.body ?? '',
            );
          }
        });
      } catch (e) {
        debugPrint('FCM Initialization Warning (Normal if Firebase is not configured): $e');
      }

      // Tự động lên lịch thông báo cố định 7:00 sáng cho cả tuần (mỗi ngày một nội dung khác nhau)
      await scheduleWeekly7AMNotifications();

      // Hiển thị thông báo chào mừng động dựa trên khung giờ mở app hiện tại
      await showDynamicNotificationBasedOnTime();
      await seedInitialNotifications();
    } catch (e) {
      debugPrint('Init Error: $e');
    }
  }

  Future<void> showDynamicNotificationBasedOnTime() async {
    final now = DateTime.now();
    final hour = now.hour;
    
    String title = '';
    String body = '';
    
    if (hour >= 5 && hour < 12) {
      title = 'Chào buổi sáng! ☀️';
      body = 'Bắt đầu ngày mới tràn đầy năng lượng bằng một bài học nhé!';
    } else if (hour >= 12 && hour < 18) {
      title = 'Chào buổi chiều! ☕️';
      body = 'Tiếp tục rèn luyện kỹ năng và hoàn thành lộ trình hôm nay nào!';
    } else if (hour >= 18 && hour < 22) {
      title = 'Buổi tối vui vẻ! 🌙';
      body = 'Dành chút thời gian ôn tập kiến thức hôm nay nhé!';
    } else {
      title = 'Đã về đêm rồi! 🦉';
      body = 'Kiên trì học tập là rất tốt, nhưng hãy nghỉ ngơi sớm nhé!';
    }
    
    await showInstantNotification(id: 888, title: title, body: body);
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
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    debugPrint('--- [LẬP LỊCH V12 DAILY] ---');
    try {
      // Đầu tiên, thử chế độ lập lịch chính xác (exactAllowWhileIdle)
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Đã đặt lịch chính xác (Exact) hàng ngày lúc: $scheduledDate');
    } catch (e) {
      debugPrint('Lỗi lập lịch chính xác: $e. Thử chuyển sang chế độ không chính xác (Inexact) làm dự phòng...');
      try {
        // Dự phòng (Fallback): sử dụng inexactAllowWhileIdle không yêu cầu quyền đặc biệt (dành cho Android 13/14+ bị chặn quyền báo thức chính xác)
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
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('Đã đặt lịch không chính xác (Inexact) làm dự phòng thành công lúc: $scheduledDate');
      } catch (ex) {
        debugPrint('Lỗi lập lịch dự phòng: $ex');
      }
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

  // Lên lịch thông báo 7:00 sáng tự động cho 7 ngày tới (không cần mở app, nội dung mỗi ngày một khác)
  Future<void> scheduleWeekly7AMNotifications() async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      
      final List<String> dailyMessages = [
        'Một ngày mới bắt đầu! Hãy hoàn thành mục tiêu học lập trình hôm nay nhé! 🚀',
        'Thử thách hôm nay: Dành 15 phút để ôn tập cấu trúc dữ liệu và giải thuật. 💡',
        'Tập trung tạo nên sự khác biệt. Hãy tiếp tục lộ trình học tập của bạn nào! 🎯',
        'Bạn đã sẵn sàng cho thử thách code hôm nay chưa? Bắt đầu ngay thôi! 💻',
        'Kiên trì là chìa khóa của thành công. Học hỏi thêm điều mới mỗi ngày! 🌟',
        'Hãy kiểm tra các thử thách mới trên hệ thống hôm nay để tích luỹ XP nhé! 🏆',
        'Cuối tuần rồi! Hãy xem lại tiến độ kỹ năng bạn đã đạt được trong tuần qua. 📊',
      ];

      for (int i = 0; i < 7; i++) {
        // Lấy mốc 7:00 sáng của ngày thứ i kể từ hôm nay
        tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 7, 0);
        scheduledDate = scheduledDate.add(Duration(days: i));
        
        // Nếu thời điểm đó đã trôi qua hôm nay, bỏ qua và dời sang hôm sau
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        
        final int notificationId = 700 + i; // ID duy nhất cho mỗi ngày: 700 -> 706
        final String body = dailyMessages[scheduledDate.weekday - 1]; // Tin nhắn dựa trên ngày trong tuần (T2 - CN)

        try {
          await _notificationsPlugin.zonedSchedule(
            notificationId,
            'Chào buổi sáng! ☀️',
            body,
            scheduledDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'skillarc_v12',
                'Nhắc nhở hàng ngày',
                channelDescription: 'Thông báo nhắc nhở học tập cố định lúc 7h sáng',
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
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
          debugPrint('Đã lên lịch 7AM ngày ${scheduledDate.day}/${scheduledDate.month}: $body');
        } catch (e) {
          // Dự phòng cho máy thiếu quyền báo thức chính xác
          try {
            await _notificationsPlugin.zonedSchedule(
              notificationId,
              'Chào buổi sáng! ☀️',
              body,
              scheduledDate,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'skillarc_v12',
                  'Nhắc nhở hàng ngày',
                  channelDescription: 'Thông báo nhắc nhở học tập cố định lúc 7h sáng',
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
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            );
            debugPrint('Đã lên lịch dự phòng (inexact) 7AM ngày ${scheduledDate.day}: $body');
          } catch (ex) {
            debugPrint('Lỗi đặt lịch dự phòng 7AM: $ex');
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi lập lịch tuần 7AM: $e');
    }
  }

  Future<void> showInstantNotification({required int id, required String title, required String body}) async {
    await saveNotification(title: title, body: body);
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

  // --- HỆ THỐNG LƯU TRỮ LỊCH SỬ THÔNG BÁO ---

  // Lưu thông báo mới vào database
  Future<void> saveNotification({
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    final key = now.millisecondsSinceEpoch.toString();
    final notification = {
      'id': key,
      'title': title,
      'body': body,
      'timestamp': now.toIso8601String(),
      'isRead': false,
    };
    await _notificationBox.put(key, notification);
    await _notificationBox.flush();
    debugPrint('NotificationService: Đã lưu thông báo mới: $title');
  }

  // Lấy tất cả thông báo
  List<Map<String, dynamic>> getAllNotifications() {
    final List<Map<String, dynamic>> list = [];
    for (var key in _notificationBox.keys) {
      final value = _notificationBox.get(key);
      if (value is Map) {
        list.add(Map<String, dynamic>.from(value));
      }
    }
    // Sắp xếp giảm dần theo timestamp
    list.sort((a, b) {
      final tA = DateTime.parse(a['timestamp'] ?? '');
      final tB = DateTime.parse(b['timestamp'] ?? '');
      return tB.compareTo(tA);
    });
    return list;
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String id) async {
    final notification = _notificationBox.get(id);
    if (notification is Map) {
      final updated = Map<String, dynamic>.from(notification);
      updated['isRead'] = true;
      await _notificationBox.put(id, updated);
      await _notificationBox.flush();
    }
  }

  // Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    for (var key in _notificationBox.keys) {
      final notification = _notificationBox.get(key);
      if (notification is Map && notification['isRead'] == false) {
        final updated = Map<String, dynamic>.from(notification);
        updated['isRead'] = true;
        await _notificationBox.put(key, updated);
      }
    }
    await _notificationBox.flush();
  }

  // Xóa một thông báo
  Future<void> deleteNotification(String id) async {
    await _notificationBox.delete(id);
    await _notificationBox.flush();
  }

  // Xóa toàn bộ thông báo
  Future<void> clearAllNotifications() async {
    await _notificationBox.clear();
    await _notificationBox.flush();
  }

  // Tạo dữ liệu mẫu nếu rỗng
  Future<void> seedInitialNotifications() async {
    if (_notificationBox.isEmpty) {
      final now = DateTime.now();
      final items = [
        {
          'id': 'seed_1',
          'title': 'Chào mừng đến với SkillArc! 🎉',
          'body': 'Bắt đầu hành trình chinh phục các kỹ năng IT và xây dựng lộ trình sự nghiệp đỉnh cao ngay hôm nay!',
          'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
          'isRead': false,
        },
        {
          'id': 'seed_2',
          'title': 'Gợi ý học tập hôm nay 💡',
          'body': 'Hãy dành 15 phút ôn tập cấu trúc dữ liệu cơ bản để củng cố nền tảng lập trình vững chắc.',
          'timestamp': now.subtract(const Duration(days: 1)).toIso8601String(),
          'isRead': true,
        },
        {
          'id': 'seed_3',
          'title': 'Thử thách lập trình mới 🏆',
          'body': 'Đã có thử thách tuần mới trên hệ thống. Hoàn thành để nhận thêm điểm XP và leo hạng nhé!',
          'timestamp': now.subtract(const Duration(days: 2)).toIso8601String(),
          'isRead': true,
        },
      ];

      for (var item in items) {
        await _notificationBox.put(item['id'], item);
      }
      await _notificationBox.flush();
      debugPrint('NotificationService: Đã seed dữ liệu thông báo mẫu.');
    }
  }

  static const _channel = MethodChannel('com.example.skill_arc/settings');

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool? result = await _channel.invokeMethod('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (e) {
      debugPrint('Lỗi kiểm tra tối ưu hóa pin: $e');
      return false;
    }
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      debugPrint('Lỗi yêu cầu bỏ qua tối ưu hóa pin: $e');
    }
  }

  Future<void> openAutostartSettings() async {
    try {
      await _channel.invokeMethod('openAutostartSettings');
    } catch (e) {
      debugPrint('Lỗi mở cài đặt tự khởi chạy: $e');
    }
  }

  Future<void> openExactAlarmSettings() async {
    try {
      await _channel.invokeMethod('openExactAlarmSettings');
    } catch (e) {
      debugPrint('Lỗi mở cài đặt báo động chính xác: $e');
    }
  }
}
