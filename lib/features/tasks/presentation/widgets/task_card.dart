import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    this.animationDelay = 0,
  });

  final TaskModel task;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int animationDelay;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final diffColor = _difficultyColor(task.difficulty);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: _DeleteBackground(),
      confirmDismiss: (_) async {
        return await _confirmDelete(context);
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.surface.withAlpha(120)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.surfaceBorder.withAlpha(80)
                : diffColor.withAlpha(60),
            width: 0.5,
          ),
          boxShadow: isCompleted
              ? []
              : [
                  BoxShadow(
                    color: diffColor.withAlpha(15),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isCompleted ? null : onComplete,
            onLongPress: onEdit,
            splashColor: diffColor.withAlpha(30),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // ── Completion circle ──────────────────────
                  GestureDetector(
                    onTap: isCompleted ? null : onComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.success.withAlpha(30)
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.success
                              : diffColor.withAlpha(150),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.success,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── Task content ───────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? AppColors.textHint
                                    : AppColors.textPrimary,
                              ),
                        ),

                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: isCompleted
                                      ? AppColors.textHint
                                      : AppColors.textSecondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 6),

                        // Tags row
                        Row(
                          children: [
                            _Tag(
                              label: task.category,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            _Tag(
                              label: _difficultyLabel(task.difficulty),
                              color: diffColor,
                            ),
                            if (task.recurrence != TaskRecurrence.none) ...[
                              const SizedBox(width: 6),
                              _Tag(
                                label: _recurrenceLabel(
                                    task.recurrence),
                                color: AppColors.secondary,
                                icon: Icons.loop,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── XP badge ───────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.surfaceBorder
                              : diffColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCompleted
                                ? Colors.transparent
                                : diffColor.withAlpha(80),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '+${task.xpReward} XP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? AppColors.textHint
                                : diffColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Edit button
                      GestureDetector(
                        onTap: onEdit,
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppColors.textHint,
                        ),
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
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }

  Color _difficultyColor(TaskDifficulty d) {
    switch (d) {
      case TaskDifficulty.easy:   return AppColors.success;
      case TaskDifficulty.medium: return AppColors.warning;
      case TaskDifficulty.hard:   return AppColors.error;
      case TaskDifficulty.legendary: return AppColors.secondary;
    }
  }

  String _difficultyLabel(TaskDifficulty d) {
    switch (d) {
      case TaskDifficulty.easy:   return 'Easy';
      case TaskDifficulty.medium: return 'Medium';
      case TaskDifficulty.hard:   return 'Hard';
      case TaskDifficulty.legendary: return 'Legendary';
    }
  }

  String _recurrenceLabel(TaskRecurrence r) {
    switch (r) {
      case TaskRecurrence.daily:  return 'Daily';
      case TaskRecurrence.weekly: return 'Weekly';
      default:                    return '';
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Small tag chip ────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(60), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Swipe-to-delete red background ────────────────────────────────────────────
class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withAlpha(80),
          width: 0.5,
        ),
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