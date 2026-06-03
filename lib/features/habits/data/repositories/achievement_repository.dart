import 'package:hive_flutter/hive_flutter.dart';
import '../models/achievement_model.dart';
import '../../../../core/utils/id_generator.dart';

class AchievementRepository {
  static const String _boxName = 'achievements';

  static Future<void> init() async {
    await Hive.openBox<AchievementModel>(_boxName);
  }

  Box<AchievementModel> get _box =>
      Hive.box<AchievementModel>(_boxName);

  List<AchievementModel> getAll() => _box.values.toList();

  List<AchievementModel> getUnlocked() =>
      _box.values.where((a) => a.isUnlocked).toList();

  List<AchievementModel> getLocked() =>
      _box.values.where((a) => !a.isUnlocked).toList();

  /// Unlocks an achievement and returns the XP reward
  Future<int> unlock(String id) async {
    final achievement = _box.get(id);
    if (achievement == null || achievement.isUnlocked) return 0;

    achievement.isUnlocked = true;
    achievement.unlockedAt =
        DateTime.now().toIso8601String().split('T').first;
    await _box.put(id, achievement);
    return achievement.xpReward;
  }

  /// Checks all achievements against current stats.
  /// Returns list of newly unlocked achievements.
  Future<List<AchievementModel>> checkAndUnlock({
    required int taskCount,
    required int streakDays,
    required int level,
    required int habitCount,
  }) async {
    final newlyUnlocked = <AchievementModel>[];

    for (final achievement in _box.values) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.conditionType) {
        case 'task_count':
          shouldUnlock = taskCount >= achievement.conditionValue;
        case 'streak':
          shouldUnlock = streakDays >= achievement.conditionValue;
        case 'level':
          shouldUnlock = level >= achievement.conditionValue;
        case 'habit_count':
          shouldUnlock = habitCount >= achievement.conditionValue;
      }

      if (shouldUnlock) {
        await unlock(achievement.id);
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// Seeds the default achievements if none exist
  Future<void> seedAchievements() async {
    if (_box.isNotEmpty) return;

    final achievements = [
      // ── Task achievements ──────────────────────────────
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'First Blood',
        description: 'Complete your first task.',
        icon: '⚔️',
        conditionType: 'task_count',
        conditionValue: 1,
        xpReward: 50,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Grinder',
        description: 'Complete 10 tasks.',
        icon: '🗡️',
        conditionType: 'task_count',
        conditionValue: 10,
        xpReward: 100,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Veteran',
        description: 'Complete 50 tasks.',
        icon: '🏆',
        conditionType: 'task_count',
        conditionValue: 50,
        xpReward: 300,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Legend',
        description: 'Complete 100 tasks.',
        icon: '👑',
        conditionType: 'task_count',
        conditionValue: 100,
        xpReward: 500,
      ),

      // ── Streak achievements ────────────────────────────
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'On a Roll',
        description: 'Maintain a 3-day streak.',
        icon: '🔥',
        conditionType: 'streak',
        conditionValue: 3,
        xpReward: 75,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak.',
        icon: '🌟',
        conditionType: 'streak',
        conditionValue: 7,
        xpReward: 150,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Unstoppable',
        description: 'Maintain a 30-day streak.',
        icon: '⚡',
        conditionType: 'streak',
        conditionValue: 30,
        xpReward: 500,
      ),

      // ── Level achievements ─────────────────────────────
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Awakened',
        description: 'Reach Level 5.',
        icon: '✨',
        conditionType: 'level',
        conditionValue: 5,
        xpReward: 100,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Hunter',
        description: 'Reach Level 10.',
        icon: '🎯',
        conditionType: 'level',
        conditionValue: 10,
        xpReward: 200,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Elite',
        description: 'Reach Level 25.',
        icon: '💎',
        conditionType: 'level',
        conditionValue: 25,
        xpReward: 500,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Shadow Monarch',
        description: 'Reach Level 50.',
        icon: '👁️',
        conditionType: 'level',
        conditionValue: 50,
        xpReward: 1000,
      ),

      // ── Habit achievements ─────────────────────────────
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Creature of Habit',
        description: 'Complete a habit 10 times.',
        icon: '🌱',
        conditionType: 'habit_count',
        conditionValue: 10,
        xpReward: 100,
      ),
      AchievementModel.create(
        id: IdGenerator.generate(),
        title: 'Disciplined',
        description: 'Complete a habit 30 times.',
        icon: '🧠',
        conditionType: 'habit_count',
        conditionValue: 30,
        xpReward: 250,
      ),
    ];

    for (final a in achievements) {
      await _box.put(a.id, a);
    }
  }
}