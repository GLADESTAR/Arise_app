import 'package:hive/hive.dart';

part 'calendar_day_model.g.dart';

/// Stores the completion snapshot for a single calendar day.
@HiveType(typeId: 6)
class CalendarDayModel extends HiveObject {
  CalendarDayModel();

  /// ISO date key e.g. "2025-01-15" — also used as the Hive key.
  @HiveField(0) late String date;

  /// How many habits were completed that day.
  @HiveField(1) late int habitsCompleted;

  /// How many habits were scheduled that day.
  @HiveField(2) late int habitsTotal;

  /// Whether any quests were completed that day.
  @HiveField(3) late bool anyQuestCompleted;

  /// Whether a legendary quest was failed that day.
  @HiveField(4) late bool legendaryQuestFailed;

  /// XP gained that day.
  @HiveField(5) late int xpGained;

  /// XP lost that day.
  @HiveField(6) late int xpLost;

  // ── Day status ────────────────────────────────────────────────
  /// Green: all habits done
  /// Yellow: some habits done
  /// Red: no habits done or legendary quest failed
  String get status {
    if (legendaryQuestFailed) return 'red';
    if (habitsTotal == 0) return 'neutral';
    if (habitsCompleted == habitsTotal) return 'green';
    if (habitsCompleted > 0) return 'yellow';
    return 'red';
  }

  double get completionRate =>
      habitsTotal == 0 ? 0.0 : habitsCompleted / habitsTotal;

  factory CalendarDayModel.create({
    required String date,
    int habitsCompleted = 0,
    int habitsTotal = 0,
    bool anyQuestCompleted = false,
    bool legendaryQuestFailed = false,
    int xpGained = 0,
    int xpLost = 0,
  }) {
    return CalendarDayModel()
      ..date = date
      ..habitsCompleted = habitsCompleted
      ..habitsTotal = habitsTotal
      ..anyQuestCompleted = anyQuestCompleted
      ..legendaryQuestFailed = legendaryQuestFailed
      ..xpGained = xpGained
      ..xpLost = xpLost;
  }
}