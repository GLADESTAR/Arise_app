// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerModelAdapter extends TypeAdapter<PlayerModel> {
  @override
  final int typeId = 0;

  @override
  PlayerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..totalXp = fields[2] as int
      ..statStr = fields[3] as int
      ..statInt = fields[4] as int
      ..statCre = fields[5] as int
      ..statCha = fields[6] as int
      ..statSkl = fields[7] as int
      ..statPoints = fields[8] as int
      ..currentStreak = fields[9] as int
      ..longestStreak = fields[10] as int
      ..lastActiveDate = fields[11] as String
      ..tasksCompleted = fields[12] as int
      ..habitsCompleted = fields[13] as int
      ..highestRank = fields[14] as String
      ..peakXp = fields[15] as int
      ..rankTerminations = fields[16] as int
      ..legendaryQuestsCompleted = fields[17] as int
      ..isMonarch = fields[18] as bool
      ..lifetimeCompletionRate = fields[19] as double;
  }

  @override
  void write(BinaryWriter writer, PlayerModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalXp)
      ..writeByte(3)
      ..write(obj.statStr)
      ..writeByte(4)
      ..write(obj.statInt)
      ..writeByte(5)
      ..write(obj.statCre)
      ..writeByte(6)
      ..write(obj.statCha)
      ..writeByte(7)
      ..write(obj.statSkl)
      ..writeByte(8)
      ..write(obj.statPoints)
      ..writeByte(9)
      ..write(obj.currentStreak)
      ..writeByte(10)
      ..write(obj.longestStreak)
      ..writeByte(11)
      ..write(obj.lastActiveDate)
      ..writeByte(12)
      ..write(obj.tasksCompleted)
      ..writeByte(13)
      ..write(obj.habitsCompleted)
      ..writeByte(14)
      ..write(obj.highestRank)
      ..writeByte(15)
      ..write(obj.peakXp)
      ..writeByte(16)
      ..write(obj.rankTerminations)
      ..writeByte(17)
      ..write(obj.legendaryQuestsCompleted)
      ..writeByte(18)
      ..write(obj.isMonarch)
      ..writeByte(19)
      ..write(obj.lifetimeCompletionRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
