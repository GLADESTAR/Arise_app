import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/calendar_day_model.dart';
import '../../data/repositories/calendar_repository.dart';
import '../../../habits/presentation/providers/habit_provider.dart';

final _calendarRepoProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
});

final _calendarMonthProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final repo = ref.watch(_calendarRepoProvider);
  return CalendarNotifier(repo);
});

class CalendarState {
  final int year;
  final int month;
  final List<CalendarDayModel> days;

  const CalendarState({
    required this.year,
    required this.month,
    this.days = const [],
  });

  CalendarState copyWith({
    int? year,
    int? month,
    List<CalendarDayModel>? days,
  }) {
    return CalendarState(
      year:  year  ?? this.year,
      month: month ?? this.month,
      days:  days  ?? this.days,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  final CalendarRepository _repo;

  CalendarNotifier(this._repo)
      : super(CalendarState(
          year:  DateTime.now().year,
          month: DateTime.now().month,
        )) {
    _load();
  }

  void _load() {
    final days = _repo.getMonth(state.year, state.month);
    state = state.copyWith(days: days);
  }

  void previousMonth() {
    DateTime current = DateTime(state.year, state.month);
    DateTime prev    = DateTime(current.year, current.month - 1);
    state = state.copyWith(year: prev.year, month: prev.month);
    _load();
  }

  void nextMonth() {
    DateTime current = DateTime(state.year, state.month);
    DateTime next    = DateTime(current.year, current.month + 1);
    final now        = DateTime.now();
    if (next.year > now.year ||
        (next.year == now.year && next.month > now.month)) return;
    state = state.copyWith(year: next.year, month: next.month);
    _load();
  }
}

// ── Calendar Screen ───────────────────────────────────────────────────────────
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calState  = ref.watch(_calendarMonthProvider);
    final habitState = ref.watch(habitProvider);

    // Record today on every open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = ref.read(_calendarRepoProvider);
      final today = DateTime.now().toIso8601String().split('T').first;
      repo.recordDay(
        date:            today,
        habitsCompleted: habitState.completedTodayCount,
        habitsTotal:     habitState.totalCount,
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CALENDAR'),
        backgroundColor: AppColors.background,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Month navigator ─────────────────────────
                _MonthNavigator(state: calState)
                    .animate()
                    .fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // ── Legend ──────────────────────────────────
                _Legend(),
                const SizedBox(height: 16),

                // ── Calendar grid ───────────────────────────
                _CalendarGrid(
                  year:  calState.year,
                  month: calState.month,
                  days:  calState.days,
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // ── Month summary ───────────────────────────
                _MonthSummary(days: calState.days)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 300.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Month navigator ───────────────────────────────────────────────────────────
class _MonthNavigator extends ConsumerWidget {
  const _MonthNavigator({required this.state});
  final CalendarState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () =>
              ref.read(_calendarMonthProvider.notifier).previousMonth(),
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.textSecondary,
          ),
        ),
        Column(
          children: [
            Text(
              months[state.month - 1].toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              '${state.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        IconButton(
          onPressed: () =>
              ref.read(_calendarMonthProvider.notifier).nextMonth(),
          icon: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: AppColors.success, label: 'Perfect'),
        const SizedBox(width: 16),
        _LegendDot(color: AppColors.warning, label: 'Partial'),
        const SizedBox(width: 16),
        _LegendDot(color: AppColors.error,   label: 'Failed'),
        const SizedBox(width: 16),
        _LegendDot(color: AppColors.surfaceBorder, label: 'No data'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────
class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.days,
  });

  final int year, month;
  final List<CalendarDayModel> days;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // weekday: 1=Mon … 7=Sun → offset so Mon = col 0
    final startOffset = (firstDay.weekday - 1) % 7;
    final today = DateTime.now();

    final dayMap = <int, CalendarDayModel>{};
    for (final d in days) {
      final parsed = DateTime.tryParse(d.date);
      if (parsed != null) dayMap[parsed.day] = d;
    }

    final weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Week day headers
          Row(
            children: weekLabels.map((l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),

          // Day cells
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox();
              }

              final day      = index - startOffset + 1;
              final dayData  = dayMap[day];
              final date     = DateTime(year, month, day);
              final isToday  = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isFuture = date.isAfter(today);

              return _DayCell(
                day:      day,
                dayData:  dayData,
                isToday:  isToday,
                isFuture: isFuture,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.dayData,
    required this.isToday,
    required this.isFuture,
  });

  final int day;
  final CalendarDayModel? dayData;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color borderColor;

    if (isFuture) {
      dotColor   = Colors.transparent;
      borderColor = Colors.transparent;
    } else if (dayData == null) {
      dotColor   = AppColors.surfaceBorder.withAlpha(80);
      borderColor = Colors.transparent;
    } else {
      switch (dayData!.status) {
        case 'green':
          dotColor   = AppColors.success;
          borderColor = AppColors.success.withAlpha(60);
        case 'yellow':
          dotColor   = AppColors.warning;
          borderColor = AppColors.warning.withAlpha(60);
        case 'red':
          dotColor   = AppColors.error;
          borderColor = AppColors.error.withAlpha(60);
        default:
          dotColor   = AppColors.surfaceBorder;
          borderColor = Colors.transparent;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: dotColor.withAlpha(isToday ? 40 : 20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday ? AppColors.primary : borderColor,
          width: isToday ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  isToday ? FontWeight.w800 : FontWeight.w400,
              color: isToday
                  ? AppColors.primary
                  : isFuture
                      ? AppColors.textHint.withAlpha(60)
                      : AppColors.textSecondary,
            ),
          ),
          if (!isFuture && dayData != null) ...[
            const SizedBox(height: 2),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withAlpha(120),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Month summary ─────────────────────────────────────────────────────────────
class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.days});
  final List<CalendarDayModel> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Text(
          'No data for this month yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final perfect  = days.where((d) => d.status == 'green').length;
    final partial  = days.where((d) => d.status == 'yellow').length;
    final failed   = days.where((d) => d.status == 'red').length;
    final totalXp  = days.fold<int>(0, (s, d) => s + d.xpGained);
    final lostXp   = days.fold<int>(0, (s, d) => s + d.xpLost);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTH SUMMARY',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textHint,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryCell(
                  value: '$perfect', label: 'Perfect', color: AppColors.success),
              _SummaryCell(
                  value: '$partial', label: 'Partial', color: AppColors.warning),
              _SummaryCell(
                  value: '$failed',  label: 'Failed',  color: AppColors.error),
              _SummaryCell(
                  value: '+$totalXp', label: 'XP Gained', color: AppColors.primary),
              _SummaryCell(
                  value: '-$lostXp', label: 'XP Lost', color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}