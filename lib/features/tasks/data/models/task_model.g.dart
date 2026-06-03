// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 3;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..description = fields[2] as String
      ..difficultyIndex = fields[3] as int
      ..recurrenceIndex = fields[4] as int
      ..isCompleted = fields[5] as bool
      ..createdAt = fields[6] as String
      ..completedAt = fields[7] as String?
      ..dueDate = fields[8] as String?
      ..category = fields[9] as String
      ..questCategory = fields[10] as String
      ..deadline = fields[11] as String?
      ..isFailed = fields[12] as bool
      ..durationDays = fields[13] as int;
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.difficultyIndex)
      ..writeByte(4)
      ..write(obj.recurrenceIndex)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.dueDate)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.questCategory)
      ..writeByte(11)
      ..write(obj.deadline)
      ..writeByte(12)
      ..write(obj.isFailed)
      ..writeByte(13)
      ..write(obj.durationDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskRecurrenceAdapter extends TypeAdapter<TaskRecurrence> {
  @override
  final int typeId = 1;

  @override
  TaskRecurrence read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskRecurrence.none;
      case 1:
        return TaskRecurrence.daily;
      case 2:
        return TaskRecurrence.weekly;
      default:
        return TaskRecurrence.none;
    }
  }

  @override
  void write(BinaryWriter writer, TaskRecurrence obj) {
    switch (obj) {
      case TaskRecurrence.none:
        writer.writeByte(0);
        break;
      case TaskRecurrence.daily:
        writer.writeByte(1);
        break;
      case TaskRecurrence.weekly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskRecurrenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskDifficultyAdapter extends TypeAdapter<TaskDifficulty> {
  @override
  final int typeId = 2;

  @override
  TaskDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskDifficulty.easy;
      case 1:
        return TaskDifficulty.medium;
      case 2:
        return TaskDifficulty.hard;
      case 3:
        return TaskDifficulty.legendary;
      default:
        return TaskDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, TaskDifficulty obj) {
    switch (obj) {
      case TaskDifficulty.easy:
        writer.writeByte(0);
        break;
      case TaskDifficulty.medium:
        writer.writeByte(1);
        break;
      case TaskDifficulty.hard:
        writer.writeByte(2);
        break;
      case TaskDifficulty.legendary:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
