import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class TaskRepository {
  static const String _boxName = 'tasks';

  static Future<void> init() async {
    await Hive.openBox<TaskModel>(_boxName);
  }

  Box<TaskModel> get _box => Hive.box<TaskModel>(_boxName);

  List<TaskModel> getAllTasks() {
    final tasks = _box.values.toList();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  List<TaskModel> getTodaysTasks() {
    final today = DateTime.now().toIso8601String().split('T').first;
    return _box.values.where((task) {
      if (task.recurrence == TaskRecurrence.none) {
        return !task.isCompleted || task.completedAt == today;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  List<TaskModel> getPendingTasks() {
    return _box.values
        .where((t) => !t.isCompleted && !t.isFailed)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Returns quests that are past deadline and not yet marked failed.
  List<TaskModel> getNewlyFailedQuests() {
    return _box.values
        .where((t) => !t.isCompleted && !t.isFailed && t.isPastDeadline)
        .toList();
  }

  Future<TaskModel> addTask(TaskModel task) async {
    await _box.put(task.id, task);
    return task;
  }

  Future<void> updateTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<int> completeTask(String id) async {
    final task = _box.get(id);
    if (task == null || task.isCompleted) return 0;
    task.isCompleted = true;
    task.completedAt =
        DateTime.now().toIso8601String().split('T').first;
    await _box.put(id, task);
    return task.xpReward;
  }

  /// Marks a task as failed (called when deadline passes).
  Future<void> markFailed(String id) async {
    final task = _box.get(id);
    if (task == null) return;
    task.isFailed = true;
    await _box.put(id, task);
  }

  Future<void> resetDailyTasks() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    for (final task in _box.values) {
      if (task.recurrence == TaskRecurrence.daily &&
          task.isCompleted &&
          task.completedAt != today) {
        task.isCompleted = false;
        task.completedAt = null;
        await _box.put(task.id, task);
      }
    }
  }

  Future<void> resetWeeklyTasks() async {
    for (final task in _box.values) {
      if (task.recurrence == TaskRecurrence.weekly && task.isCompleted) {
        final completed = task.completedAt;
        if (completed == null) continue;
        final completedDate = DateTime.parse(completed);
        if (DateTime.now().difference(completedDate).inDays >= 7) {
          task.isCompleted = false;
          task.completedAt = null;
          await _box.put(task.id, task);
        }
      }
    }
  }

  int get totalCompleted =>
      _box.values.where((t) => t.isCompleted).length;
}