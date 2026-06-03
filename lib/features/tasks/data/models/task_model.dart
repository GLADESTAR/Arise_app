import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
enum TaskRecurrence {
  @HiveField(0) none,
  @HiveField(1) daily,
  @HiveField(2) weekly,
}

@HiveType(typeId: 2)
enum TaskDifficulty {
  @HiveField(0) easy,
  @HiveField(1) medium,
  @HiveField(2) hard,
  @HiveField(3) legendary, // new
}

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  TaskModel();

  // ── Existing fields ───────────────────────────────────────────
  @HiveField(0) late String id;
  @HiveField(1) late String title;
  @HiveField(2) late String description;
  @HiveField(3) late int difficultyIndex;
  @HiveField(4) late int recurrenceIndex;
  @HiveField(5) late bool isCompleted;
  @HiveField(6) late String createdAt;
  @HiveField(7) late String? completedAt;
  @HiveField(8) late String? dueDate;
  @HiveField(9) late String category;

  // ── New fields ────────────────────────────────────────────────

  /// Quest category: 'normal', 'important', 'legendary'
  /// Controls what happens on failure.
  @HiveField(10) late String questCategory;

  /// Deadline date (ISO string). Used for failure detection.
  @HiveField(11) late String? deadline;

  /// Whether the deadline has passed without completion.
  @HiveField(12) late bool isFailed;

  /// Days until deadline (used for XP auto-calc).
  @HiveField(13) late int durationDays;

  // ── Computed getters ──────────────────────────────────────────
  TaskDifficulty get difficulty =>
      TaskDifficulty.values[difficultyIndex.clamp(0, TaskDifficulty.values.length - 1)];

  TaskRecurrence get recurrence =>
      TaskRecurrence.values[recurrenceIndex.clamp(0, TaskRecurrence.values.length - 1)];

  bool get isLegendaryQuest => questCategory == 'legendary';
  bool get isImportantQuest => questCategory == 'important';

  int get xpReward {
    switch (difficulty) {
      case TaskDifficulty.easy:      return 25;
      case TaskDifficulty.medium:    return 50;
      case TaskDifficulty.hard:      return 100;
      case TaskDifficulty.legendary: return 200;
    }
  }

  /// Whether this quest is past its deadline and not completed.
  bool get isPastDeadline {
    if (deadline == null || isCompleted) return false;
    final deadlineDate = DateTime.tryParse(deadline!);
    if (deadlineDate == null) return false;
    return DateTime.now().isAfter(deadlineDate);
  }

  factory TaskModel.create({
    required String id,
    required String title,
    String description = '',
    TaskDifficulty difficulty = TaskDifficulty.medium,
    TaskRecurrence recurrence = TaskRecurrence.none,
    String category = 'General',
    String questCategory = 'normal',
    String? dueDate,
    String? deadline,
    int durationDays = 1,
  }) {
    return TaskModel()
      ..id = id
      ..title = title
      ..description = description
      ..difficultyIndex = difficulty.index
      ..recurrenceIndex = recurrence.index
      ..isCompleted = false
      ..createdAt = DateTime.now().toIso8601String().split('T').first
      ..completedAt = null
      ..dueDate = dueDate
      ..category = category
      ..questCategory = questCategory
      ..deadline = deadline
      ..isFailed = false
      ..durationDays = durationDays;
  }
}