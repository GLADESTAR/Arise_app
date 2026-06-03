import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QUEST BOARD'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withAlpha(80),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${taskState.completedTodayCount} done today',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          tabs: [
            Tab(text: 'ALL  (${taskState.allTasks.length})'),
            Tab(text: 'TODAY  (${taskState.todaysTasks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TaskList(
            tasks: taskState.allTasks,
            emptyMessage: AppStrings.noTasks,
          ),
          _TaskList(
            tasks: taskState.todaysTasks,
            emptyMessage: 'No tasks for today.\nAdd one below!',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'ADD TASK',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ).animate().scale(
            delay: 400.ms,
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  void _showTaskSheet(BuildContext context, {TaskModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskFormSheet(existing: existing),
    );
  }
}

// ── Task list ─────────────────────────────────────────────────────────────────
class _TaskList extends ConsumerWidget {
  const _TaskList({
    required this.tasks,
    required this.emptyMessage,
  });

  final List<TaskModel> tasks;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 56, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                    height: 1.6,
                  ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          key: Key(task.id),
          task: task,
          animationDelay: index * 50,
          onComplete: () =>
              ref.read(taskProvider.notifier).completeTask(task.id),
          onEdit: () => _showEditSheet(context, task),
          onDelete: () =>
              ref.read(taskProvider.notifier).deleteTask(task.id),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskFormSheet(existing: task),
    );
  }
}

// ── Task form sheet ───────────────────────────────────────────────────────────
class _TaskFormSheet extends ConsumerStatefulWidget {
  const _TaskFormSheet({this.existing});
  final TaskModel? existing;

  @override
  ConsumerState<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<_TaskFormSheet> {
  // ── Controllers ───────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _descController  = TextEditingController();

  // ── Form state ────────────────────────────────────────────────
  TaskDifficulty _difficulty    = TaskDifficulty.medium;
  TaskRecurrence _recurrence    = TaskRecurrence.none;
  String         _category      = 'General';
  String         _questCategory = 'normal';
  int            _durationDays  = 7;
  int?           _customXp;
  bool           _useCustomXp   = false;
  bool           _isLoading     = false;

  // ── Picker options ────────────────────────────────────────────
  final _categories = [
    'General', 'Study', 'Fitness', 'Health',
    'Work', 'Creative', 'Social', 'Finance',
  ];

  final _questCategories = ['normal', 'important', 'legendary'];

  bool get _isEditing => widget.existing != null;

  // Auto-calculated XP based on difficulty and duration
  int get _suggestedXp => XpCalculator.suggestedQuestXp(
        _difficultyKey(_difficulty),
        _durationDays,
      );

  // Final XP used when submitting
  int get _finalXp =>
      _useCustomXp && _customXp != null ? _customXp! : _suggestedXp;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.existing!;
      _titleController.text = t.title;
      _descController.text  = t.description;
      _difficulty    = t.difficulty;
      _recurrence    = t.recurrence;
      _category      = t.category;
      _questCategory = t.questCategory;
      _durationDays  = t.durationDays > 0 ? t.durationDays : 7;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(taskProvider.notifier);

    final deadlineDate = DateTime.now()
        .add(Duration(days: _durationDays))
        .toIso8601String()
        .split('T')
        .first;

    if (_isEditing) {
      final updated = widget.existing!
        ..title         = _titleController.text.trim()
        ..description   = _descController.text.trim()
        ..difficultyIndex = _difficulty.index
        ..recurrenceIndex = _recurrence.index
        ..category      = _category
        ..questCategory = _questCategory
        ..durationDays  = _durationDays;
      await notifier.updateTask(updated);
    } else {
      await notifier.addTask(
        title:         _titleController.text.trim(),
        description:   _descController.text.trim(),
        difficulty:    _difficulty,
        recurrence:    _recurrence,
        category:      _category,
        questCategory: _questCategory,
        deadline:      deadlineDate,
        durationDays:  _durationDays,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top:   BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          left:  BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          right: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Handle bar ─────────────────────────────────
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ──────────────────────────────────────
            Text(
              _isEditing ? 'EDIT TASK' : 'NEW TASK',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 20),

            // ── Task title input ───────────────────────────
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Task title *',
                prefixIcon: Icon(Icons.assignment_outlined,
                    color: AppColors.textHint, size: 18),
              ),
            ),
            const SizedBox(height: 12),

            // ── Description input ──────────────────────────
            TextField(
              controller: _descController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                prefixIcon: Icon(Icons.notes,
                    color: AppColors.textHint, size: 18),
              ),
            ),
            const SizedBox(height: 20),

            // ── Difficulty picker ──────────────────────────
            const _Label('DIFFICULTY'),
            const SizedBox(height: 8),
            Row(
              children: TaskDifficulty.values.map((d) {
                final isSelected = _difficulty == d;
                final color = _diffColor(d);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _difficulty = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withAlpha(30)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : AppColors.surfaceBorder,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _diffLabel(d),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? color
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Recurrence picker ──────────────────────────
            const _Label('RECURRENCE'),
            const SizedBox(height: 8),
            Row(
              children: TaskRecurrence.values.map((r) {
                final isSelected = _recurrence == r;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _recurrence = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary.withAlpha(25)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.surfaceBorder,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Text(
                          _recLabel(r),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Category picker ────────────────────────────
            const _Label('CATEGORY'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(25)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceBorder,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Quest category picker ──────────────────────
            const _Label('QUEST CATEGORY'),
            const SizedBox(height: 4),
            const Text(
              'Normal = no penalty  •  Important = XP loss  •  Legendary = rank termination',
              style: TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
            const SizedBox(height: 8),
            Row(
              children: _questCategories.map((qc) {
                final isSelected = _questCategory == qc;
                final color = qc == 'legendary'
                    ? AppColors.error
                    : qc == 'important'
                        ? AppColors.warning
                        : AppColors.success;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _questCategory = qc),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withAlpha(25)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : AppColors.surfaceBorder,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Text(
                          qc.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? color
                                : AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Duration slider ────────────────────────────
            const _Label('DURATION (DAYS)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _durationDays.toDouble(),
                    min: 1,
                    max: 365,
                    divisions: 364,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceBorder,
                    onChanged: (v) =>
                        setState(() => _durationDays = v.toInt()),
                  ),
                ),
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primary.withAlpha(80)),
                  ),
                  child: Text(
                    '${_durationDays}d',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── XP reward ──────────────────────────────────
            const _Label('XP REWARD'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.surfaceBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      // Suggested XP display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SUGGESTED',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textHint,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_suggestedXp XP',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            '${_durationDays}d × ${_xpMultiplier(_difficulty)} per day',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                      // Custom XP toggle
                      Row(
                        children: [
                          const Text(
                            'Custom',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Switch(
                            value: _useCustomXp,
                            onChanged: (v) =>
                                setState(() => _useCustomXp = v),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Custom XP input — shown only when toggled on
                  if (_useCustomXp) ...[
                    const SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter custom XP amount',
                        prefixIcon: const Icon(Icons.star_outline,
                            color: AppColors.textHint, size: 18),
                        helperText:
                            'Suggested: $_suggestedXp XP',
                        helperStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => _customXp = int.tryParse(v)),
                    ),
                  ],

                  // Final XP preview
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withAlpha(60),
                          width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt,
                            color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Reward on completion: +$_finalXp XP',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Submit button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'SAVE CHANGES' : 'CREATE TASK'),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(
          begin: 0.3,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Color _diffColor(TaskDifficulty d) {
    switch (d) {
      case TaskDifficulty.easy:      return AppColors.success;
      case TaskDifficulty.medium:    return AppColors.warning;
      case TaskDifficulty.hard:      return AppColors.error;
      case TaskDifficulty.legendary: return AppColors.secondary;
    }
  }

  String _diffLabel(TaskDifficulty d) {
    switch (d) {
      case TaskDifficulty.easy:      return 'EASY';
      case TaskDifficulty.medium:    return 'MEDIUM';
      case TaskDifficulty.hard:      return 'HARD';
      case TaskDifficulty.legendary: return 'LEGEND';
    }
  }

  /// Key used for XP calculation lookup in XpConstants.
  String _difficultyKey(TaskDifficulty d) {
    switch (d) {
      case TaskDifficulty.easy:      return 'easy';
      case TaskDifficulty.medium:    return 'medium';
      case TaskDifficulty.hard:      return 'hard';
      case TaskDifficulty.legendary: return 'legendary';
    }
  }

  /// XP multiplier label shown in the XP breakdown.
  int _xpMultiplier(TaskDifficulty d) {
    switch (d) {
      case TaskDifficulty.easy:      return 10;
      case TaskDifficulty.medium:    return 20;
      case TaskDifficulty.hard:      return 40;
      case TaskDifficulty.legendary: return 60;
    }
  }

  String _recLabel(TaskRecurrence r) {
    switch (r) {
      case TaskRecurrence.none:   return 'ONCE';
      case TaskRecurrence.daily:  return 'DAILY';
      case TaskRecurrence.weekly: return 'WEEKLY';
    }
  }
}

// ── Small label widget ────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
        letterSpacing: 2,
      ),
    );
  }
}