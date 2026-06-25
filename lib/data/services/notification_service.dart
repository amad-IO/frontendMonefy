import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'bill_reminder_channel';
  static const String _channelName = 'Bill Reminders';
  static const String _channelDesc = 'Pengingat tagihan jatuh tempo';

  // ── Init ─────────────────────────────────────────────────────
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@drawable/ic_notification');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Instant Test Notification (untuk testing saja) ──────────
  static Future<void> sendTestNotification() async {
    await _plugin.show(
      9999, // ID khusus untuk test
      'Waktunya Bayar Tagihan ',
      'Tagihan Wifi Indihome kamu jatuh tempo besok. Yuk bayar sekarang biar tenang!',
      _details(),
    );
  }

  // ── Notification Detail Builder ───────────────────────────────
  static NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@drawable/ic_notification', // icon monochrome khusus notifikasi
        color: Color(0xFF694EDA),          // warna aksen ungu Monefy
      ),
    );
  }

  // ── ID helpers ────────────────────────────────────────────────
  static int _idH2(int billId)      => billId * 10 + 0;
  static int _idH1(int billId)      => billId * 10 + 1;
  static int _idH0(int billId)      => billId * 10 + 2;
  static int _idOverdue(int billId) => billId * 10 + 3;

  // ── Timezone helper ───────────────────────────────────────────
  static tz.TZDateTime _wib(DateTime dt) {
    final jakarta = tz.getLocation('Asia/Jakarta');
    return tz.TZDateTime.from(dt, jakarta);
  }

  /// Hitung tanggal reminder H-N (handle lompat bulan jika hari 1 atau 2)
  static DateTime _reminderDate(DateTime dueDate, int daysBefore) {
    final d = dueDate.subtract(Duration(days: daysBefore));
    return DateTime(d.year, d.month, d.day, 9, 0); // jam 09:00
  }

  // ── Schedule semua notifikasi untuk satu bill ─────────────────
  static Future<void> scheduleAllReminders({
    required int billId,
    required String billName,
    required DateTime dueDate,
    required String cycle, // "Sekali Bayar" | "Bulanan" | "Tahunan"
  }) async {
    await cancelAllReminders(billId); // bersihkan dulu

    final h2Date = _reminderDate(dueDate, 2);
    final h1Date = _reminderDate(dueDate, 1);
    final h0Date = _reminderDate(dueDate, 0);

    final isBulanan = cycle.toLowerCase().contains('bulanan');
    final isTahunan = cycle.toLowerCase().contains('tahunan');

    // Tentukan DateTimeComponents untuk repeat
    DateTimeComponents? repeatH2H1H0;
    if (isBulanan) {
      repeatH2H1H0 = DateTimeComponents.dayOfMonthAndTime;
    } else if (isTahunan) {
      repeatH2H1H0 = DateTimeComponents.dateAndTime;
    }
    // Sekali bayar → null (tidak repeat)

    // H-2
    await _schedule(
      id: _idH2(billId),
      title: 'Halo! Ada Tagihan Mendatang ',
      body: 'Jangan lupa, tagihan $billName kamu akan jatuh tempo dalam 2 hari ya.',
      scheduledDate: h2Date,
      repeat: repeatH2H1H0,
    );

    // H-1
    await _schedule(
      id: _idH1(billId),
      title: 'Waktunya Bayar Tagihan ',
      body: 'Tagihan $billName kamu jatuh tempo besok. Yuk bayar sekarang biar tenang!',
      scheduledDate: h1Date,
      repeat: repeatH2H1H0,
    );

    // H-0
    await _schedule(
      id: _idH0(billId),
      title: 'Jatuh Tempo Hari Ini ',
      body: 'Hari ini batas akhir pembayaran $billName. Yuk segera diselesaikan!',
      scheduledDate: h0Date,
      repeat: repeatH2H1H0,
    );

    // Overdue daily (jika sudah lewat due date dan belum bayar)
    final now = DateTime.now();
    if (now.isAfter(h0Date)) {
      await scheduleOverdue(billId: billId, billName: billName);
    }

    debugPrint('Notif scheduled untuk bill $billId ($billName) cycle=$cycle');
  }

  // ── Jadwalkan daily overdue (H+1 dst) ────────────────────────
  static Future<void> scheduleOverdue({
    required int billId,
    required String billName,
  }) async {
    // Overdue: mulai jam 09:00 hari ini, repeat harian
    final now = DateTime.now();
    final todayAt9 = DateTime(now.year, now.month, now.day, 9, 0);
    // Jika jam 9 sudah lewat, jadwalkan untuk besok jam 9
    final startDate = now.isAfter(todayAt9)
        ? todayAt9.add(const Duration(days: 1))
        : todayAt9;

    final wibDate = _wib(startDate);

    await _plugin.zonedSchedule(
      _idOverdue(billId),
      'Ups, Ada Tagihan Terlewat ',
      'Tagihan $billName kamu sudah lewat jatuh tempo. Yuk segera bayar agar tenang!',
      wibDate,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily jam 09:00
    );

    debugPrint('Overdue notif dijadwalkan untuk bill $billId');
  }

  // ── Cancel hanya overdue (saat Pay) ──────────────────────────
  static Future<void> cancelOverdue(int billId) async {
    await _plugin.cancel(_idOverdue(billId));
    debugPrint('Overdue notif dibatalkan untuk bill $billId');
  }

  // ── Cancel SEMUA notif bill (saat Delete/Edit) ────────────────
  static Future<void> cancelAllReminders(int billId) async {
    await _plugin.cancel(_idH2(billId));
    await _plugin.cancel(_idH1(billId));
    await _plugin.cancel(_idH0(billId));
    await _plugin.cancel(_idOverdue(billId));
    debugPrint('Semua notif dibatalkan untuk bill $billId');
  }

  // ── Internal: schedule satu notif ────────────────────────────
  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    DateTimeComponents? repeat,
  }) async {
    final wibDate = _wib(scheduledDate);
    final now = _wib(DateTime.now());

    // Skip jika sudah lewat (kecuali ada repeat)
    if (wibDate.isBefore(now) && repeat == null) {
      debugPrint('Skip notif $id — sudah lewat & tidak repeat');
      return;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      wibDate,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeat,
    );

    debugPrint('Notif $id dijadwalkan: $scheduledDate');
  }
}