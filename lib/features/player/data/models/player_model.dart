import 'package:hive/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 0)
class PlayerModel extends HiveObject {
  PlayerModel();

  // ── Existing fields (DO NOT change field numbers) ─────────────
  @HiveField(0)  late String id;
  @HiveField(1)  late String name;
  @HiveField(2)  late int totalXp;
  @HiveField(3)  late int statStr;
  @HiveField(4)  late int statInt;
  @HiveField(5)  late int statCre;
  @HiveField(6)  late int statCha;
  @HiveField(7)  late int statSkl;
  @HiveField(8)  late int statPoints;
  @HiveField(9)  late int currentStreak;
  @HiveField(10) late int longestStreak;
  @HiveField(11) late String lastActiveDate;
  @HiveField(12) late int tasksCompleted;
  @HiveField(13) late int habitsCompleted;

  // ── New fields (appended — safe for existing saves) ───────────
  /// The highest rank the user has ever earned. Never reduced by XP loss.
  /// Only changed by rank promotion or rank termination.
  @HiveField(14) late String highestRank;

  /// Peak XP ever reached — used to calculate rank milestones.
  /// Never decreases (separate from totalXp which can drop).
  @HiveField(15) late int peakXp;

  /// How many times rank termination has occurred.
  @HiveField(16) late int rankTerminations;

  /// Total legendary quests successfully completed.
  @HiveField(17) late int legendaryQuestsCompleted;

  /// Monarch unlocked flag (set manually after all requirements met).
  @HiveField(18) late bool isMonarch;

  /// Overall habit completion rate (0.0–1.0), updated daily.
  @HiveField(19) late double lifetimeCompletionRate;

  factory PlayerModel.newPlayer({
    required String name,
    required String id,
  }) {
    return PlayerModel()
      ..id = id
      ..name = name
      ..totalXp = 0
      ..statStr = 1
      ..statInt = 1
      ..statCre = 1
      ..statCha = 1
      ..statSkl = 1
      ..statPoints = 0
      ..currentStreak = 0
      ..longestStreak = 0
      ..lastActiveDate =
          DateTime.now().toIso8601String().split('T').first
      ..tasksCompleted = 0
      ..habitsCompleted = 0
      ..highestRank = 'F'
      ..peakXp = 0
      ..rankTerminations = 0
      ..legendaryQuestsCompleted = 0
      ..isMonarch = false
      ..lifetimeCompletionRate = 0.0;
  }
}