import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // Gunakan zona waktu Jakarta (WIB)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // Tindakan saat notifikasi diklik
      },
    );
  }

  Future<void> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  /// Membatalkan semua notifikasi yang sudah dijadwalkan agar tidak dobel
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Menjadwalkan notifikasi untuk setiap mata pelajaran hari ini
  Future<void> scheduleClassNotifications(List<dynamic> schedules) async {
    await cancelAllNotifications(); // Bersihkan yang lama

    final now = DateTime.now();

    int id = 0;
    for (var schedule in schedules) {
      if (schedule['jam_mulai'] != null) {
        final String jamMulaiStr = schedule['jam_mulai'];
        final String mataPelajaran = schedule['mata_pelajaran'] ?? 'Pelajaran';
        final String guru = schedule['guru']?['nama'] ?? 'Guru';

        try {
          // Parse jam_mulai (format "HH:mm:ss")
          final parts = jamMulaiStr.split(':');
          final int hour = int.parse(parts[0]);
          final int minute = int.parse(parts[1]);

          // Buat DateTime untuk jadwal tersebut di hari ini
          DateTime scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);

          // Jika jam mulai masih di masa depan (hari ini), jadwalkan
          if (scheduleTime.isAfter(now)) {
            await _scheduleNotification(
              id: id++,
              title: 'Jam Pelajaran Dimulai!',
              body: 'Mata Pelajaran $mataPelajaran dengan $guru sedang aktif. Jangan lupa absen!',
              scheduledDate: scheduleTime,
            );
          }
        } catch (e) {
          print("Error parsing time for notification: $e");
        }
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_channel',
          'Notifikasi Jam Pelajaran',
          channelDescription: 'Pengingat saat jam pelajaran akan dimulai',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print("Scheduled notification ID $id for $scheduledDate");
  }
}
