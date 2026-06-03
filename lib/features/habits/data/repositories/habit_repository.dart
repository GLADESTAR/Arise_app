import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/xp_calculator.dart';

class HabitRepository {
  static const String _boxName = 'habits';

  static Future<void> init() async {
    await Hive.openBox<HabitModel>(_boxName);
  }

  Box<HabitModel> get _box => Hive.box<HabitModel>(_boxName);

  List<HabitModel> getAllHabits() {
    return _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<HabitModel> getCompletedToday() {
    return _box.values.where((h) => h.isCompletedToday).toList();
  }

  /// Returns habits that were NOT completed yesterday.
  /// Used to apply end-of-day penalties.
  List<HabitModel> getMissedYesterday() {
    return _box.values
        .where((h) => h.wasMissedYesterday && !h.isCompletedToday)
        .toList();
  }

  Future<HabitModel> addHabit(HabitModel habit) async {
    await _box.put(habit.id, habit);
    return habit;
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
  }

  /// Completes a habit for today. Returns XP earned (from constants).
  Future<int> completeHabit(String id) async {
    final habit = _box.get(id);
    if (habit == null || habit.isCompletedToday) return 0;

    final today = DateTime.now().toIso8601String().split('T').first;
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')
        .first;

    habit.completionDates.add(today);

    if (habit.completionDates.contains(yesterday)) {
      habit.currentStreak++;
    } else {
      habit.currentStreak = 1;
    }

    if (habit.currentStreak > habit.longestStreak) {
      habit.longestStreak = habit.currentStreak;
    }

    await _box.put(id, habit);

    // Return XP based on difficulty from constants
    return XpCalculator.habitReward(habit.difficultyLevel);
  }

  Future<void> uncompleteHabit(String id) async {
    final habit = _box.get(id);
    if (habit == null || !habit.isCompletedToday) return;

    final today = DateTime.now().toIso8601String().split('T').first;
    habit.completionDates.remove(today);
    habit.currentStreak = habit.currentStreak > 0
        ? habit.currentStreak - 1
        : 0;
    await _box.put(id, habit);
  }

  /// Calculates total XP penalty for all missed habits yesterday.
  /// Call once per day at app open.
  int calculateYesterdayPenalty() {
    int total = 0;
    for (final habit in getMissedYesterday()) {
      total += XpCalculator.habitPenalty(habit.difficultyLevel);
    }
    return total;
  }

  Future<void> seedDefaultHabits() async {
    if (_box.isNotEmpty) return;

    final defaults = [
      HabitModel.create(
        id: IdGenerator.generate(),
        name: 'Study',
        icon: '📚',
        category: 'Learning',
        difficultyLevel: 'hard',
        xpPerCompletion: 20,
        isCustom: false,
      ),
      HabitModel.create(
        id: IdGenerator.generate(),
        name: 'Workout',
        icon: '💪',
        category: 'Fitness',
        difficultyLevel: 'hard',
        xpPerCompletion: 20,
        isCustom: false,
      ),
      HabitModel.create(
        id: IdGenerator.generate(),
        name: 'Reading',
        icon: '📖',
        category: 'Learning',
        difficultyLevel: 'medium',
        xpPerCompletion: 10,
        isCustom: false,
      ),
      HabitModel.create(
        id: IdGenerator.generate(),
        name: 'Sleep on time',
        icon: '😴',
        category: 'Health',
        difficultyLevel: 'medium',
        xpPerCompletion: 10,
        isCustom: false,
      ),
      HabitModel.create(
        id: IdGenerator.generate(),
        name: 'Meditate',
        icon: '🧘',
        category: 'Health',
        difficultyLevel: 'easy',
        xpPerCompletion: 5,
        isCustom: false,
      ),
    ];

    for (final habit in defaults) {
      await _box.put(habit.id, habit);
    }
  }

  int get totalCompletionsToday => getCompletedToday().length;
}