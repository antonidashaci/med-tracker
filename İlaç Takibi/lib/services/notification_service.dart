import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/models/reminder.dart';
import '../data/models/medicine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Timezone initialization
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // TODO: Navigate to medicine detail or mark as taken
    print('Notification tapped: ${response.payload}');
  }

  // Schedule medicine reminder
  Future<void> scheduleMedicineReminder(
    Medicine medicine,
    Reminder reminder,
  ) async {
    if (!reminder.isActive) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Schedule for each day in reminder
    for (final day in reminder.days) {
      final reminderTime = DateTime(
        today.year,
        today.month,
        today.day,
        reminder.time.hour,
        reminder.time.minute,
      );

      // If time has passed today, schedule for next occurrence
      if (reminderTime.isBefore(now)) {
        final daysUntilNext = (day - now.weekday + 7) % 7;
        if (daysUntilNext == 0) daysUntilNext = 7; // Next week
        
        reminderTime.add(Duration(days: daysUntilNext));
      } else {
        // Today, but check if it's the right day
        if (now.weekday != day) {
          final daysUntilNext = (day - now.weekday + 7) % 7;
          reminderTime.add(Duration(days: daysUntilNext));
        }
      }

      // Schedule notification
      await _scheduleNotification(
        id: int.parse('${medicine.id.hashCode}${reminder.id.hashCode}'),
        title: 'İlaç Hatırlatıcısı',
        body: '${medicine.name} - ${medicine.dosage} ${medicine.dosageUnit}',
        scheduledDate: reminderTime,
        payload: 'medicine_${medicine.id}_${reminder.id}',
      );
    }
  }

  // Schedule single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = 
        const AndroidNotificationDetails(
      'medicine_reminders',
      'İlaç Hatırlatıcıları',
      channelDescription: 'İlaç alma hatırlatıcıları',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      enableLights: true,
      color: Color(0xFF007AFF), // iOS blue
    );

    final DarwinNotificationDetails iosDetails = 
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel medicine reminder
  Future<void> cancelMedicineReminder(
    Medicine medicine,
    Reminder reminder,
  ) async {
    final notificationId = int.parse('${medicine.id.hashCode}${reminder.id.hashCode}');
    await _notifications.cancel(notificationId);
  }

  // Cancel all reminders for a medicine
  Future<void> cancelAllMedicineReminders(Medicine medicine) async {
    for (final reminder in medicine.reminders) {
      await cancelMedicineReminder(medicine, reminder);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = 
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Test Bildirimi',
      'Bu bir test bildirimidir',
      details,
    );
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return true; // iOS always returns true if permissions are granted
  }

  // Show stock alert notification
  Future<void> showStockAlert(Medicine medicine) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'stock_alert_channel',
      'Stok Uyarıları',
      channelDescription: 'İlaç stok uyarıları',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = 
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      medicine.hashCode + 1000, // Unique ID for stock alerts
      'Stok Uyarısı',
      '${medicine.name} stok seviyesi düşük! (${medicine.stockCount} adet kaldı)',
      details,
    );
  }
} 