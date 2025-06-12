import 'package:hive/hive.dart';

part 'medicine_history.g.dart';

@HiveType(typeId: 3)
class MedicineHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicineId;

  @HiveField(2)
  final String medicineName;

  @HiveField(3)
  final DateTime takenAt;

  @HiveField(4)
  final String dosage;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final bool wasOnTime;

  @HiveField(7)
  final String? reminderId;

  MedicineHistory({
    String? id,
    required this.medicineId,
    required this.medicineName,
    DateTime? takenAt,
    required this.dosage,
    this.notes,
    this.wasOnTime = true,
    this.reminderId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       takenAt = takenAt ?? DateTime.now();

  // Copy with method
  MedicineHistory copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    DateTime? takenAt,
    String? dosage,
    String? notes,
    bool? wasOnTime,
    String? reminderId,
  }) {
    return MedicineHistory(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      takenAt: takenAt ?? this.takenAt,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      wasOnTime: wasOnTime ?? this.wasOnTime,
      reminderId: reminderId ?? this.reminderId,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'takenAt': takenAt.toIso8601String(),
      'dosage': dosage,
      'notes': notes,
      'wasOnTime': wasOnTime,
      'reminderId': reminderId,
    };
  }

  // From JSON
  factory MedicineHistory.fromJson(Map<String, dynamic> json) {
    return MedicineHistory(
      id: json['id'],
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      takenAt: DateTime.parse(json['takenAt']),
      dosage: json['dosage'],
      notes: json['notes'],
      wasOnTime: json['wasOnTime'],
      reminderId: json['reminderId'],
    );
  }

  // Get formatted date
  String get formattedDate {
    return '${takenAt.day.toString().padLeft(2, '0')}.${takenAt.month.toString().padLeft(2, '0')}.${takenAt.year}';
  }

  // Get formatted time
  String get formattedTime {
    return '${takenAt.hour.toString().padLeft(2, '0')}:${takenAt.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted date and time
  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  // Check if taken today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final takenDate = DateTime(takenAt.year, takenAt.month, takenAt.day);
    return today.isAtSameMomentAs(takenDate);
  }

  // Check if taken this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return takenAt.isAfter(weekStart.subtract(const Duration(days: 1))) &&
           takenAt.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  // Check if taken this month
  bool get isThisMonth {
    final now = DateTime.now();
    return takenAt.year == now.year && takenAt.month == now.month;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineHistory &&
        other.id == id &&
        other.medicineId == medicineId &&
        other.medicineName == medicineName &&
        other.takenAt == takenAt &&
        other.dosage == dosage &&
        other.notes == notes &&
        other.wasOnTime == wasOnTime &&
        other.reminderId == reminderId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      medicineId,
      medicineName,
      takenAt,
      dosage,
      notes,
      wasOnTime,
      reminderId,
    );
  }

  @override
  String toString() {
    return 'MedicineHistory(id: $id, medicineName: $medicineName, takenAt: $takenAt)';
  }
} 