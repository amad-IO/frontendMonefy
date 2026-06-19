import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Inisialisasi dasar sistem notifikasi
  static Future<void> init() async {
    // 1. Inisialisasi zona waktu HP
    tz.initializeTimeZones();

    // 2. Konfigurasi ikon notifikasi untuk Android (menggunakan ikon bawaan launcher)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // 3. Daftarkan konfigurasi ke plugin
    await _notificationsPlugin.initialize(initializationSettings);

    // 4. Minta izin akses notifikasi untuk Android 13 ke atas
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Menjadwalkan notifikasi pengingat H-2 (atau 10 detik untuk testing)
  static Future<void> scheduleBillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dueDate,
  }) async {
    // 1. Trik Uji Coba 10 detik (pastikan gunakan .toUtc())
    final DateTime reminderDate = DateTime.now().add(
        const Duration(seconds: 10)).toUtc();

    // 2. Untuk nanti jika sudah selesai tes, gunakan baris di bawah ini:
    // final DateTime reminderDate = dueDate.subtract(const Duration(days: 2)).toUtc();

    // Jika waktu pengingat sudah lewat, abaikan
    if (reminderDate.isBefore(DateTime.now().toUtc())) return;

    // UBAH: Gunakan tz.UTC sebagai zona waktu standar agar tidak bergeser 7 jam
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        reminderDate, tz.UTC);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'bill_reminder_channel',
      'Peringatan Tagihan',
      channelDescription: 'Pengingat tagihan H-2 sebelum jatuh tempo',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true, // Menampilkan waktu notifikasi
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}