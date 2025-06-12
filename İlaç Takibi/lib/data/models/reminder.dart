import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final TimeOfDay time;

  @HiveField(2)
  final List<int> days; // 1 = Monday, 7 = Sunday

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final DateTime? lastTaken;

  @HiveField(5)
  final String? notificationId;

  @HiveField(6)
  final String? notes;

  Reminder({
    String? id,
    required this.time,
    required this.days,
    this.isActive = true,
    this.lastTaken,
    this.notificationId,
    this.notes,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  String get timeString {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get daysString {
    const dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days.map((day) => dayNames[day - 1]).join(', ');
  }

  bool get isToday {
    final today = DateTime.now().weekday;
    return days.contains(today);
  }

  bool get isOverdue {
    if (!isActive || !isToday) return false;
    
    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    return now.isAfter(reminderTime);
  }

  Reminder copyWith({
    String? id,
    TimeOfDay? time,
    List<int>? days,
    bool? isActive,
    DateTime? lastTaken,
    String? notificationId,
    String? notes,
  }) {
    return Reminder(
      id: id ?? this.id,
      time: time ?? this.time,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
      lastTaken: lastTaken ?? this.lastTaken,
      notificationId: notificationId ?? this.notificationId,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.time == time &&
        listEquals(other.days, days) &&
        other.isActive == isActive &&
        other.lastTaken == lastTaken &&
        other.notificationId == notificationId &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      time,
      Object.hashAll(days),
      isActive,
      lastTaken,
      notificationId,
      notes,
    );
  }

  @override
  String toString() {
    return 'Reminder(id: $id, time: $time, days: $days, isActive: $isActive)';
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'days': days,
      'isActive': isActive,
      'lastTaken': lastTaken?.toIso8601String(),
      'notificationId': notificationId,
      'notes': notes,
    };
  }

  // From JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
      days: List<int>.from(json['days']),
      isActive: json['isActive'],
      lastTaken: json['lastTaken'] != null 
          ? DateTime.parse(json['lastTaken']) 
          : null,
      notificationId: json['notificationId'],
      notes: json['notes'],
    );
  }

  // Get days as string list
  List<String> get daysAsStrings {
    const dayNames = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days.map((day) => dayNames[day - 1]).toList();
  }

  // Get short day names
  List<String> get shortDayNames {
    const shortNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days.map((day) => shortNames[day - 1]).toList();
  }

  // Get time as string
  String get timeString {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Check if reminder is for today
  bool get isForToday {
    final today = DateTime.now().weekday;
    return days.contains(today);
  }

  // Get next reminder time
  DateTime? get nextReminderTime {
    if (!isActive) return null;
    
    final now = DateTime.now();
    final today = now.weekday;
    
    // Check if there's a reminder today
    if (days.contains(today)) {
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      if (now.isBefore(reminderTime)) {
        return reminderTime;
      }
    }
    
    // Find next reminder day
    for (int i = 1; i <= 7; i++) {
      final checkDay = (today + i - 1) % 7 + 1;
      if (days.contains(checkDay)) {
        final nextDate = now.add(Duration(days: i));
        return DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          time.hour,
          time.minute,
        );
      }
    }
    
    return null;
  }
}

// TimeOfDay adapter for Hive
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 2;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
} 