import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'reminder.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final String frequency;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final String? imagePath;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final List<Reminder> reminders;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final String? qrCode;

  @HiveField(14)
  final String dosageUnit;

  @HiveField(15)
  final int? stockCount;

  @HiveField(16)
  final int? stockThreshold;

  @HiveField(17)
  final List<String>? interactionIds;

  Medicine({
    String? id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.category,
    required this.startDate,
    this.endDate,
    this.notes,
    this.imagePath,
    this.isActive = true,
    List<Reminder>? reminders,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.qrCode,
    required this.dosageUnit,
    this.stockCount,
    this.stockThreshold,
    this.interactionIds,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       reminders = reminders ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get fullDosage => '$dosage $dosageUnit';

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get hasActiveReminders {
    return reminders.any((reminder) => reminder.isActive);
  }

  List<Reminder> get activeReminders {
    return reminders.where((reminder) => reminder.isActive).toList();
  }

  List<Reminder> get todayReminders {
    final today = DateTime.now().weekday;
    return reminders.where((reminder) => 
      reminder.isActive && reminder.days.contains(today)
    ).toList();
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? imagePath,
    bool? isActive,
    List<Reminder>? reminders,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? qrCode,
    String? dosageUnit,
    int? stockCount,
    int? stockThreshold,
    List<String>? interactionIds,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      reminders: reminders ?? this.reminders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      qrCode: qrCode ?? this.qrCode,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      stockCount: stockCount ?? this.stockCount,
      stockThreshold: stockThreshold ?? this.stockThreshold,
      interactionIds: interactionIds ?? this.interactionIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine &&
        other.id == id &&
        other.name == name &&
        other.dosage == dosage &&
        other.frequency == frequency &&
        other.category == category &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.notes == notes &&
        other.imagePath == imagePath &&
        other.isActive == isActive &&
        listEquals(other.reminders, reminders) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.qrCode == qrCode &&
        other.dosageUnit == dosageUnit &&
        other.stockCount == stockCount &&
        other.stockThreshold == stockThreshold &&
        listEquals(other.interactionIds, interactionIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      dosage,
      frequency,
      category,
      startDate,
      endDate,
      notes,
      imagePath,
      isActive,
      Object.hashAll(reminders),
      createdAt,
      updatedAt,
      qrCode,
      dosageUnit,
      stockCount,
      stockThreshold,
      Object.hashAll(interactionIds),
    );
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, dosage: $dosage, isActive: $isActive)';
  }
} 