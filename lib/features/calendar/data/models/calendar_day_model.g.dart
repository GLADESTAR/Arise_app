// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_day_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarDayModelAdapter extends TypeAdapter<CalendarDayModel> {
  @override
  final int typeId = 6;

  @override
  CalendarDayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarDayModel()
      ..date = fields[0] as String
      ..habitsCompleted = fields[1] as int
      ..habitsTotal = fields[2] as int
      ..anyQuestCompleted = fields[3] as bool
      ..legendaryQuestFailed = fields[4] as bool
      ..xpGained = fields[5] as int
      ..xpLost = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, CalendarDayModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.habitsCompleted)
      ..writeByte(2)
      ..write(obj.habitsTotal)
      ..writeByte(3)
      ..write(obj.anyQuestCompleted)
      ..writeByte(4)
      ..write(obj.legendaryQuestFailed)
      ..writeByte(5)
      ..write(obj.xpGained)
      ..writeByte(6)
      ..write(obj.xpLost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
