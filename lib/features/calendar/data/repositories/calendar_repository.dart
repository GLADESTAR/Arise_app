import 'package:hive_flutter/hive_flutter.dart';
import '../models/calendar_day_model.dart';

class CalendarRepository {
  static const String _boxName = 'calendar';

  static Future<void> init() async {
    await Hive.openBox<CalendarDayModel>(_boxName);
  }

  Box<CalendarDayModel> get _box =>
      Hive.box<CalendarDayModel>(_boxName);

  CalendarDayModel? getDay(String date) => _box.get(date);

  List<CalendarDayModel> getMonth(int year, int month) {
    return _box.values
        .where((d) {
          final parsed = DateTime.tryParse(d.date);
          return parsed != null &&
              parsed.year == year &&
              parsed.month == month;
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Records or updates today's completion snapshot.
  Future<void> recordDay({
    required String date,
    required int habitsCompleted,
    required int habitsTotal,
    bool anyQuestCompleted = false,
    bool legendaryQuestFailed = false,
    int xpGained = 0,
    int xpLost = 0,
  }) async {
    final existing = _box.get(date);
    if (existing != null) {
      existing.habitsCompleted = habitsCompleted;
      existing.habitsTotal = habitsTotal;
      existing.anyQuestCompleted =
          existing.anyQuestCompleted || anyQuestCompleted;
      existing.legendaryQuestFailed =
          existing.legendaryQuestFailed || legendaryQuestFailed;
      existing.xpGained += xpGained;
      existing.xpLost += xpLost;
      await _box.put(date, existing);
    } else {
      final day = CalendarDayModel.create(
        date: date,
        habitsCompleted: habitsCompleted,
        habitsTotal: habitsTotal,
        anyQuestCompleted: anyQuestCompleted,
        legendaryQuestFailed: legendaryQuestFailed,
        xpGained: xpGained,
        xpLost: xpLost,
      );
      await _box.put(date, day);
    }
  }

  List<CalendarDayModel> getAll() => _box.values.toList();
}