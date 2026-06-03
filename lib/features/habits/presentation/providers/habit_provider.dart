import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/achievement_model.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../core/constants/xp_constants.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final achievementRepositoryProvider =
    Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

final habitProvider =
    StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  final habitRepo       = ref.watch(habitRepositoryProvider);
  final achievementRepo = ref.watch(achievementRepositoryProvider);
  return HabitNotifier(habitRepo, achievementRepo, ref);
});

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  return AchievementNotifier(repo);
});

// ── Habit State ───────────────────────────────────────────────────────────────
class HabitState {
  final List<HabitModel> habits;
  final bool isLoading;
  final int yesterdayPenalty; // XP lost this session from missed habits

  const HabitState({
    this.habits = const [],
    this.isLoading = false,
    this.yesterdayPenalty = 0,
  });

  int get completedTodayCount =>
      habits.where((h) => h.isCompletedToday).length;

  int get totalCount => habits.length;

  double get todayCompletionRate =>
      totalCount == 0 ? 0 : completedTodayCount / totalCount;

  HabitState copyWith({
    List<HabitModel>? habits,
    bool? isLoading,
    int? yesterdayPenalty,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      yesterdayPenalty: yesterdayPenalty ?? this.yesterdayPenalty,
    );
  }
}

// ── Achievement State ─────────────────────────────────────────────────────────
class AchievementState {
  final List<AchievementModel> all;
  final List<AchievementModel> newlyUnlocked;

  const AchievementState({
    this.all = const [],
    this.newlyUnlocked = const [],
  });

  List<AchievementModel> get unlocked =>
      all.where((a) => a.isUnlocked).toList();

  List<AchievementModel> get locked =>
      all.where((a) => !a.isUnlocked).toList();

  AchievementState copyWith({
    List<AchievementModel>? all,
    List<AchievementModel>? newlyUnlocked,
  }) {
    return AchievementState(
      all: all ?? this.all,
      newlyUnlocked: newlyUnlocked ?? this.newlyUnlocked,
    );
  }
}

// ── Habit Notifier ────────────────────────────────────────────────────────────
class HabitNotifier extends StateNotifier<HabitState> {
  final HabitRepository _habitRepo;
  final AchievementRepository _achievementRepo;
  final Ref _ref;

  HabitNotifier(this._habitRepo, this._achievementRepo, this._ref)
      : super(const HabitState()) {
    _init();
  }

  Future<void> _init() async {
    await _habitRepo.seedDefaultHabits();
    await _achievementRepo.seedAchievements();

    // Apply yesterday's missed habit penalties once per app open
    await _applyYesterdayPenalties();

    // Check for failed quests
    await _checkFailedQuests();

    _load();
  }

  void _load() {
    state = state.copyWith(habits: _habitRepo.getAllHabits());
  }

  /// Deducts XP for habits missed yesterday. Called once at startup.
  Future<void> _applyYesterdayPenalties() async {
    final penalty = _habitRepo.calculateYesterdayPenalty();
    if (penalty > 0) {
      await _ref.read(playerProvider.notifier).loseXp(penalty);
      state = state.copyWith(yesterdayPenalty: penalty);
    }
  }

  /// Checks for quests that have passed their deadline.
  Future<void> _checkFailedQuests() async {
    final taskRepo   = _ref.read(taskRepositoryProvider);
    final failedQuests = taskRepo.getNewlyFailedQuests();

    for (final quest in failedQuests) {
      await taskRepo.markFailed(quest.id);

      if (quest.questCategory == XpConstants.categoryImportant) {
        // XP penalty
        await _ref.read(playerProvider.notifier).loseXp(
          XpConstants.importantQuestFailurePenalty,
        );
      } else if (quest.questCategory == XpConstants.categoryLegendary) {
        // Rank termination
        await _ref.read(playerProvider.notifier).triggerRankTermination();
      }
      // Normal quests: no consequence
    }
  }

  Future<void> addHabit({
    required String name,
    required String icon,
    required String category,
    String difficultyLevel = 'medium',
  }) async {
    final xp = XpCalculator.habitReward(difficultyLevel);
    final habit = HabitModel.create(
      id: IdGenerator.generate(),
      name: name,
      icon: icon,
      category: category,
      difficultyLevel: difficultyLevel,
      xpPerCompletion: xp,
      isCustom: true,
    );
    await _habitRepo.addHabit(habit);
    _load();
  }

  Future<void> deleteHabit(String id) async {
    await _habitRepo.deleteHabit(id);
    _load();
  }

  Future<void> completeHabit(String id) async {
    final habit = state.habits.firstWhere((h) => h.id == id);
    if (habit.isCompletedToday) return;

    final xp = await _habitRepo.completeHabit(id);
    await _ref.read(playerProvider.notifier).gainXp(xp);

    final playerRepo = _ref.read(playerRepositoryProvider);
    final player = playerRepo.getPlayer();
    if (player != null) {
      player.habitsCompleted++;
      await playerRepo.savePlayer(player);
    }

    _load();
    await _checkAchievements();
  }

  Future<void> uncompleteHabit(String id) async {
    await _habitRepo.uncompleteHabit(id);
    _load();
  }

  Future<void> _checkAchievements() async {
    final playerState = _ref.read(playerProvider);
    final taskState   = _ref.read(taskProvider);
    final player      = playerState.player;
    if (player == null) return;

    final totalHabitCompletions = state.habits
        .fold<int>(0, (sum, h) => sum + h.completionDates.length);

    final newlyUnlocked = await _achievementRepo.checkAndUnlock(
      taskCount:  taskState.allTasks.where((t) => t.isCompleted).length,
      streakDays: player.currentStreak,
      level:      playerState.level,
      habitCount: totalHabitCompletions,
    );

    if (newlyUnlocked.isNotEmpty) {
      for (final a in newlyUnlocked) {
        await _ref.read(playerProvider.notifier).gainXp(a.xpReward);
      }
      _ref.read(achievementProvider.notifier).onNewlyUnlocked(newlyUnlocked);
    }
  }

  void refresh() => _load();
}

// ── Achievement Notifier ──────────────────────────────────────────────────────
class AchievementNotifier extends StateNotifier<AchievementState> {
  final AchievementRepository _repo;

  AchievementNotifier(this._repo) : super(const AchievementState()) {
    _load();
  }

  void _load() {
    state = state.copyWith(all: _repo.getAll());
  }

  void onNewlyUnlocked(List<AchievementModel> achievements) {
    state = state.copyWith(
      all: _repo.getAll(),
      newlyUnlocked: achievements,
    );
  }

  void clearNewlyUnlocked() {
    state = state.copyWith(newlyUnlocked: []);
  }

  void refresh() => _load();
}