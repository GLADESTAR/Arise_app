import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 4)
class HabitModel extends HiveObject {
  HabitModel();

  // ── Existing fields (unchanged) ───────────────────────────────
  @HiveField(0)  late String id;
  @HiveField(1)  late String name;
  @HiveField(2)  late String icon;
  @HiveField(3)  late int xpPerCompletion;
  @HiveField(4)  late int currentStreak;
  @HiveField(5)  late int longestStreak;
  @HiveField(6)  late List<String> completionDates;
  @HiveField(7)  late String createdAt;
  @HiveField(8)  late bool isCustom;
  @HiveField(9)  late String category;

  // ── New field ─────────────────────────────────────────────────
  /// Difficulty: 'easy', 'medium', 'hard'
  /// Controls both XP reward and missed-day penalty.
  @HiveField(10) late String difficultyLevel;

  // ── Computed getters ──────────────────────────────────────────
  bool get isCompletedToday {
    final today = DateTime.now().toIso8601String().split('T').first;
    return completionDates.contains(today);
  }

  List<DateTime> get completionDateTimes {
    return completionDates
        .map((d) => DateTime.tryParse(d))
        .whereType<DateTime>()
        .toList();
  }

  int get completionsThisWeek {
    final now = DateTime.now();
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final date = now
          .subtract(Duration(days: i))
          .toIso8601String()
          .split('T')
          .first;
      if (completionDates.contains(date)) count++;
    }
    return count;
  }

  /// Was this habit missed yesterday?
  bool get wasMissedYesterday {
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')
        .first;
    return !completionDates.contains(yesterday);
  }

  factory HabitModel.create({
    required String id,
    required String name,
    required String icon,
    required String category,
    String difficultyLevel = 'medium',
    int xpPerCompletion = 10,
    bool isCustom = true,
  }) {
    return HabitModel()
      ..id = id
      ..name = name
      ..icon = icon
      ..xpPerCompletion = xpPerCompletion
      ..currentStreak = 0
      ..longestStreak = 0
      ..completionDates = []
      ..createdAt = DateTime.now().toIso8601String().split('T').first
      ..isCustom = isCustom
      ..category = category
      ..difficultyLevel = difficultyLevel;
  }
}