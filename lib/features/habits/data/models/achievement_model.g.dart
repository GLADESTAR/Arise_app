// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementModelAdapter extends TypeAdapter<AchievementModel> {
  @override
  final int typeId = 5;

  @override
  AchievementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementModel()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..description = fields[2] as String
      ..icon = fields[3] as String
      ..isUnlocked = fields[4] as bool
      ..unlockedAt = fields[5] as String?
      ..xpReward = fields[6] as int
      ..conditionType = fields[7] as String
      ..conditionValue = fields[8] as int;
  }

  @override
  void write(BinaryWriter writer, AchievementModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.isUnlocked)
      ..writeByte(5)
      ..write(obj.unlockedAt)
      ..writeByte(6)
      ..write(obj.xpReward)
      ..writeByte(7)
      ..write(obj.conditionType)
      ..writeByte(8)
      ..write(obj.conditionValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
