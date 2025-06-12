// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineHistoryAdapter extends TypeAdapter<MedicineHistory> {
  @override
  final int typeId = 3;

  @override
  MedicineHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineHistory(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      medicineName: fields[2] as String,
      takenAt: fields[3] as DateTime,
      dosage: fields[4] as String,
      notes: fields[5] as String?,
      wasOnTime: fields[6] as bool,
      reminderId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineHistory obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineId)
      ..writeByte(2)
      ..write(obj.medicineName)
      ..writeByte(3)
      ..write(obj.takenAt)
      ..writeByte(4)
      ..write(obj.dosage)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.wasOnTime)
      ..writeByte(7)
      ..write(obj.reminderId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
} 