import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../habits/presentation/providers/habit_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final taskState   = ref.watch(taskProvider);
    final habitState  = ref.watch(habitProvider);
    final player      = playerState.player;

    if (player == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // ── Derived analytics data ──────────────────────────────────────────────
    final totalTasks     = taskState.allTasks.length;
    final completedTasks = taskState.allTasks.where((t) => t.isCompleted).length;
    final taskRate       = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    final totalHabits     = habitState.habits.length;
    final completedHabits = habitState.completedTodayCount;
    final habitRate       = totalHabits == 0 ? 0.0 : completedHabits / totalHabits;

    // XP for each of last 7 days (from habit completions)
    final xpPerDay = _buildXpPerDay(habitState.habits);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ANALYTICS'),
        backgroundColor: AppColors.background,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Overview cards ─────────────────────────────
                const _SectionLabel('OVERVIEW'),
                const SizedBox(height: 12),
                _OverviewGrid(
                  level:          playerState.level,
                  totalXp:        player.totalXp,
                  longestStreak:  player.longestStreak,
                  currentStreak:  player.currentStreak,
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // ── XP chart ───────────────────────────────────
                const _SectionLabel('XP GAINED — LAST 7 DAYS'),
                const SizedBox(height: 12),
                _XpBarChart(xpPerDay: xpPerDay)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // ── Completion rates ───────────────────────────
                const _SectionLabel('COMPLETION RATES'),
                const SizedBox(height: 12),
                _CompletionRates(
                  taskRate:     taskRate,
                  habitRate:    habitRate,
                  completedTasks: completedTasks,
                  totalTasks:   totalTasks,
                  completedHabits: completedHabits,
                  totalHabits:  totalHabits,
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // ── Habit breakdown ────────────────────────────
                const _SectionLabel('HABIT PERFORMANCE'),
                const SizedBox(height: 12),
                _HabitBreakdown(habits: habitState.habits)
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates total XP earned per day for last 7 days from habit logs
  List<double> _buildXpPerDay(habits) {
    final result = List<double>.filled(7, 0);
    final now = DateTime.now();

    for (final habit in habits) {
      for (int i = 0; i < 7; i++) {
        final date = now
            .subtract(Duration(days: 6 - i))
            .toIso8601String()
            .split('T')
            .first;
        if (habit.completionDates.contains(date)) {
          result[i] += habit.xpPerCompletion.toDouble();
        }
      }
    }
    return result;
  }
}

// ── Overview grid ─────────────────────────────────────────────────────────────
class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({
    required this.level,
    required this.totalXp,
    required this.longestStreak,
    required this.currentStreak,
  });
  final int level, totalXp, longestStreak, currentStreak;

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Current Level', '$level', Icons.trending_up, AppColors.primary),
      ('Total XP', '$totalXp', Icons.star_outline, AppColors.warning),
      ('Current Streak', '$currentStreak days', Icons.local_fire_department_outlined, AppColors.streakFire),
      ('Best Streak', '$longestStreak days', Icons.emoji_events_outlined, AppColors.secondary),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final c = cards[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: (c.$4).withAlpha(60), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(c.$3,
                  color: c.$4, size: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.$2,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: c.$4,
                    ),
                  ),
                  Text(
                    c.$1,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── XP bar chart ──────────────────────────────────────────────────────────────
class _XpBarChart extends StatelessWidget {
  const _XpBarChart({required this.xpPerDay});
  final List<double> xpPerDay;

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now  = DateTime.now();

    // Map day index to correct weekday label
    final labels = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return days[date.weekday - 1];
    });

    final maxY = xpPerDay.isEmpty
        ? 100.0
        : (xpPerDay.reduce((a, b) => a > b ? a : b) * 1.3)
            .clamp(50.0, double.infinity);

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceElevated,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} XP',
                  const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox();
                  }
                  final isToday = index == 6;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textHint,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.surfaceBorder,
              strokeWidth: 0.5,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final isToday = i == 6;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: xpPerDay[i],
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    colors: isToday
                        ? [AppColors.primaryDark, AppColors.primary]
                        : [
                            AppColors.secondary.withAlpha(120),
                            AppColors.secondary.withAlpha(200),
                          ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Completion rates ──────────────────────────────────────────────────────────
class _CompletionRates extends StatelessWidget {
  const _CompletionRates({
    required this.taskRate,
    required this.habitRate,
    required this.completedTasks,
    required this.totalTasks,
    required this.completedHabits,
    required this.totalHabits,
  });

  final double taskRate, habitRate;
  final int completedTasks, totalTasks, completedHabits, totalHabits;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RateBar(
          label: 'Tasks Completed',
          rate: taskRate,
          detail: '$completedTasks / $totalTasks',
          color: AppColors.primary,
        ),
        const SizedBox(height: 10),
        _RateBar(
          label: 'Habits Today',
          rate: habitRate,
          detail: '$completedHabits / $totalHabits',
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class _RateBar extends StatelessWidget {
  const _RateBar({
    required this.label,
    required this.rate,
    required this.detail,
    required this.color,
  });
  final String label, detail;
  final double rate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${(rate * 100).toInt()}%  ($detail)',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(4),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * rate.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withAlpha(180), color],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(100),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Habit breakdown ───────────────────────────────────────────────────────────
class _HabitBreakdown extends StatelessWidget {
  const _HabitBreakdown({required this.habits});
  final habits;

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Text('No habits tracked yet.',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return Column(
      children: (habits as List).map<Widget>((habit) {
        final rate = habit.completionsThisWeek / 7.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.surfaceBorder, width: 0.5),
          ),
          child: Row(
            children: [
              Text(habit.icon,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(habit.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium),
                        Text(
                          '${habit.completionsThisWeek}/7 this week',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Mini week bar
                    Row(
                      children: List.generate(7, (i) {
                        final date = DateTime.now()
                            .subtract(Duration(days: 6 - i))
                            .toIso8601String()
                            .split('T')
                            .first;
                        final done =
                            habit.completionDates.contains(date);
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 1),
                            decoration: BoxDecoration(
                              color: done
                                  ? AppColors.success
                                  : AppColors.surfaceBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 2,
              ),
        ),
      ],
    );
  }
}