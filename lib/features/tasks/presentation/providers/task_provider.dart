import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../core/constants/xp_constants.dart';

/// Exported so habit_provider can access the task repo.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final taskProvider =
    StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repo, ref);
});

// ── Task State ────────────────────────────────────────────────────────────────
class TaskState {
  final List<TaskModel> allTasks;
  final List<TaskModel> todaysTasks;
  final bool isLoading;
  final String? lastCompletedTaskTitle;
  final int lastXpGained;

  const TaskState({
    this.allTasks = const [],
    this.todaysTasks = const [],
    this.isLoading = false,
    this.lastCompletedTaskTitle,
    this.lastXpGained = 0,
  });

  int get pendingCount =>
      allTasks.where((t) => !t.isCompleted && !t.isFailed).length;

  int get completedTodayCount =>
      todaysTasks.where((t) => t.isCompleted).length;

  TaskState copyWith({
    List<TaskModel>? allTasks,
    List<TaskModel>? todaysTasks,
    bool? isLoading,
    String? lastCompletedTaskTitle,
    int? lastXpGained,
  }) {
    return TaskState(
      allTasks: allTasks ?? this.allTasks,
      todaysTasks: todaysTasks ?? this.todaysTasks,
      isLoading: isLoading ?? this.isLoading,
      lastCompletedTaskTitle:
          lastCompletedTaskTitle ?? this.lastCompletedTaskTitle,
      lastXpGained: lastXpGained ?? this.lastXpGained,
    );
  }
}

// ── Task Notifier ─────────────────────────────────────────────────────────────
class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repo;
  final Ref _ref;

  TaskNotifier(this._repo, this._ref) : super(const TaskState()) {
    _load();
  }

  void _load() {
    _repo.resetDailyTasks();
    _repo.resetWeeklyTasks();
    state = state.copyWith(
      allTasks:    _repo.getAllTasks(),
      todaysTasks: _repo.getTodaysTasks(),
    );
  }

  Future<void> addTask({
    required String title,
    String description = '',
    TaskDifficulty difficulty = TaskDifficulty.medium,
    TaskRecurrence recurrence = TaskRecurrence.none,
    String category = 'General',
    String questCategory = 'normal',
    String? dueDate,
    String? deadline,
    int durationDays = 1,
  }) async {
    final task = TaskModel.create(
      id: IdGenerator.generate(),
      title: title,
      description: description,
      difficulty: difficulty,
      recurrence: recurrence,
      category: category,
      questCategory: questCategory,
      dueDate: dueDate,
      deadline: deadline,
      durationDays: durationDays,
    );
    await _repo.addTask(task);
    _load();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repo.updateTask(task);
    _load();
  }

  Future<void> deleteTask(String id) async {
    await _repo.deleteTask(id);
    _load();
  }

  Future<void> completeTask(String id) async {
    final task = state.allTasks.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('Task not found'),
    );
    if (task.isCompleted || task.isFailed) return;

    final xp = await _repo.completeTask(id);

    // Award XP
    await _ref.read(playerProvider.notifier).gainXp(xp);

    // Track legendary quest completions
    if (task.isLegendaryQuest) {
      final playerRepo = _ref.read(playerRepositoryProvider);
      final player = playerRepo.getPlayer();
      if (player != null) {
        player.legendaryQuestsCompleted++;
        player.tasksCompleted++;
        await playerRepo.savePlayer(player);
      }
    } else {
      final playerRepo = _ref.read(playerRepositoryProvider);
      final player = playerRepo.getPlayer();
      if (player != null) {
        player.tasksCompleted++;
        await playerRepo.savePlayer(player);
      }
    }

    state = state.copyWith(
      lastCompletedTaskTitle: task.title,
      lastXpGained: xp,
    );
    _load();
  }

  void refresh() => _load();
}