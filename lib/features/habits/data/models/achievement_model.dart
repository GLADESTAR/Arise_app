import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 5)
class AchievementModel extends HiveObject {
  AchievementModel();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String icon; // emoji

  @HiveField(4)
  late bool isUnlocked;

  @HiveField(5)
  late String? unlockedAt; // ISO date string

  @HiveField(6)
  late int xpReward; // bonus XP when unlocked

  @HiveField(7)
  late String conditionType; // "task_count", "streak", "level", "habit_count"

  @HiveField(8)
  late int conditionValue; // the number to reach

  factory AchievementModel.create({
    required String id,
    required String title,
    required String description,
    required String icon,
    required String conditionType,
    required int conditionValue,
    int xpReward = 100,
  }) {
    return AchievementModel()
      ..id = id
      ..title = title
      ..description = description
      ..icon = icon
      ..isUnlocked = false
      ..unlockedAt = null
      ..xpReward = xpReward
      ..conditionType = conditionType
      ..conditionValue = conditionValue;
  }
}