import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/habit_model.dart';
import '../providers/habit_provider.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitProvider);
    final habits = habitState.habits;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DAILY RITUALS'),
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
                  '${habitState.completedTodayCount}/${habits.length} today',
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
      ),

      body: habits.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                return _HabitTile(
                  key: Key(habits[index].id),
                  habit: habits[index],
                  index: index,
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'ADD HABIT',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ).animate().scale(
            delay: 400.ms,
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddHabitSheet(),
    );
  }
}

// ── Habit tile ────────────────────────────────────────────────────────────────
class _HabitTile extends ConsumerWidget {
  const _HabitTile({
    super.key,
    required this.habit,
    required this.index,
  });

  final HabitModel habit;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = habit.isCompletedToday;

    return Dismissible(
      key: Key('dismiss_${habit.id}'),
      direction: habit.isCustom
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: _DeleteBg(),
      confirmDismiss: (_) async {
        if (!habit.isCustom) return false;
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.surfaceBorder),
            ),
            title: const Text('Delete Habit'),
            content: Text(
                'Delete "${habit.name}"? Your streak will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          ref.read(habitProvider.notifier).deleteHabit(habit.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withAlpha(10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withAlpha(60)
                : AppColors.surfaceBorder,
            width: isCompleted ? 1 : 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleTap(context, ref),
            splashColor: isCompleted
                ? Colors.transparent
                : AppColors.secondary.withAlpha(30),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // ── Emoji icon ─────────────────────────
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withAlpha(20)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.success.withAlpha(80)
                            : AppColors.surfaceBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        habit.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Name + streak ──────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Streak
                            if (habit.currentStreak > 0) ...[
                              const Text('🔥',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 3),
                              Text(
                                '${habit.currentStreak} day streak',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.streakFire,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ] else
                              Text(
                                'No streak yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            const SizedBox(width: 8),
                            // Week dots
                            ..._buildWeekDots(habit),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Right side ─────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // XP badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success.withAlpha(20)
                              : AppColors.secondary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.success.withAlpha(60)
                                : AppColors.secondary.withAlpha(60),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          isCompleted
                              ? '✓ Done'
                              : '+${habit.xpPerCompletion} XP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${habit.completionsThisWeek}/7 this week',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }

  /// 7 dots showing completion history for the past week
  List<Widget> _buildWeekDots(HabitModel habit) {
    return List.generate(7, (i) {
      final date = DateTime.now()
          .subtract(Duration(days: 6 - i))
          .toIso8601String()
          .split('T')
          .first;
      final done = habit.completionDates.contains(date);
      final isToday = i == 6;
      return Padding(
        padding: const EdgeInsets.only(right: 3),
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.success
                : (isToday
                    ? AppColors.primary.withAlpha(60)
                    : AppColors.surfaceBorder),
            border: isToday && !done
                ? Border.all(color: AppColors.primary, width: 1)
                : null,
          ),
        ),
      );
    });
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (habit.isCompletedToday) {
      // Allow undo with a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          content: Text(
            '${habit.name} already completed today.',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.primary,
            onPressed: () =>
                ref.read(habitProvider.notifier).uncompleteHabit(habit.id),
          ),
        ),
      );
      return;
    }

    ref.read(habitProvider.notifier).completeHabit(habit.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
              color: AppColors.success, width: 0.5),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle,
                color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text(
              '${habit.name} done! +${habit.xpPerCompletion} XP',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Week dots delete background ───────────────────────────────────────────────
class _DeleteBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withAlpha(80), width: 0.5),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: AppColors.error, size: 22),
          SizedBox(height: 4),
          Text(
            'DELETE',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'No habits yet.\nAdd your first daily ritual.',
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
}

// ── Add habit bottom sheet ────────────────────────────────────────────────────
class _AddHabitSheet extends ConsumerStatefulWidget {
  const _AddHabitSheet();

  @override
  ConsumerState<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<_AddHabitSheet> {
  final _nameController = TextEditingController();
 String _selectedIcon       = '⭐';
  String _selectedCategory   = 'General';
  String _selectedDifficulty = 'medium';

  final _icons = [
    '⭐', '📚', '💪', '🏃', '🧘', '💧', '🥗', '😴',
    '✍️', '🎨', '🎵', '💻', '📖', '🌿', '🧠', '🎯',
  ];

  final _categories = [
    'General', 'Learning', 'Fitness',
    'Health', 'Creative', 'Mindfulness',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  Widget _buildDifficultyOption(
    String value,
    String label,
    String xpLabel,
    Color color,
  ) {
    final isSelected = _selectedDifficulty == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDifficulty = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(25) : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppColors.surfaceBorder,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                xpLabel,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? color : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;
    await ref.read(habitProvider.notifier).addHabit(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          category: _selectedCategory,
          difficultyLevel: _selectedDifficulty,
        );
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
          top: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          left: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
          right: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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

            Text(
              'NEW HABIT',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 20),

            // Name input
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Habit name *',
                prefixIcon: Icon(Icons.loop,
                    color: AppColors.textHint, size: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Icon picker
            const _SheetLabel('PICK AN ICON'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((icon) {
                final selected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.secondary.withAlpha(30)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.secondary
                            : AppColors.surfaceBorder,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(icon,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Category
            const _SheetLabel('CATEGORY'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.secondary.withAlpha(25)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? AppColors.secondary
                            : AppColors.surfaceBorder,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Difficulty picker
            const _SheetLabel('DIFFICULTY'),
            const SizedBox(height: 4),
            const Text(
              'Controls XP reward and missed-day penalty',
              style: TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDifficultyOption('easy',   'EASY',   '+5 XP / -2',  AppColors.success),
                const SizedBox(width: 6),
                _buildDifficultyOption('medium', 'MEDIUM', '+10 XP / -5', AppColors.warning),
                const SizedBox(width: 6),
                _buildDifficultyOption('hard',   'HARD',   '+20 XP / -10',AppColors.error),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: const Text('CREATE HABIT'),
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
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
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