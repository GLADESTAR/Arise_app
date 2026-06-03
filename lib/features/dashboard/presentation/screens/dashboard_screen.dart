import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../core/widgets/xp_progress_bar.dart';
import '../../../../core/widgets/level_up_overlay.dart';
import '../../../player/data/repositories/player_repository.dart';
import '../../../player/presentation/providers/player_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../core/widgets/xp_progress_bar.dart';
import '../../../../core/widgets/level_up_overlay.dart';
import '../../../player/data/repositories/player_repository.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import 'package:go_router/go_router.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // If no player exists, show the onboarding dialog after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final player = ref.read(playerProvider).player;
      if (player == null) _showOnboarding();
    });
  }

  void _showOnboarding() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _OnboardingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);

    return LevelUpOverlay(
      show: playerState.justLeveledUp,
      newLevel: playerState.newLevel,
      rank: playerState.rank,
      onDismiss: () => ref.read(playerProvider.notifier).clearLevelUp(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: playerState.player == null
            ? const _LoadingView()
            : _DashboardBody(playerState: playerState),
      ),
    );
  }
}

// ── Loading / empty state ──────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

// ── Main dashboard body ────────────────────────────────────────────────────────
class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.playerState});
  final PlayerState playerState;

  @override
  Widget build(BuildContext context) {
    final player = playerState.player!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Top App Bar ────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 0,
          floating: true,
          snap: true,
          backgroundColor: AppColors.background,
          title: Row(
            children: [
              // App logo / name
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'ARISE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const Spacer(),
              // Streak badge
              _StreakBadge(streak: player.currentStreak),
            ],
          ),
           actions: [
    IconButton(
      icon: const Icon(
        Icons.settings_outlined,
      ),
      onPressed: () => context.go('/settings'),
    ),
  ],
),
        

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Player hero card ───────────────────────────
              _PlayerHeroCard(playerState: playerState)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // ── Stats row ─────────────────────────────────
              _StatsRow(player: player)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

             // ── Today's tasks preview ─────────────────────
              const _SectionTitle(title: "Today's Tasks")
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 12),

              _TodaysTasksPreview()
                  .animate(delay: 250.ms)
                  .fadeIn(duration: 400.ms),

              // ── Quick actions ──────────────────────────────
              const _SectionTitle(title: 'Quick Actions')
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 12),

              _QuickActionsRow()
                  .animate(delay: 450.ms)
                  .fadeIn(duration: 400.ms),

            ]),
          ),
        ),
      ],
    );
  }
}

// ── Player hero card ──────────────────────────────────────────────────────────
class _PlayerHeroCard extends StatelessWidget {
  const _PlayerHeroCard({required this.playerState});
  final PlayerState playerState;

  @override
  Widget build(BuildContext context) {
    final player = playerState.player!;
    final rankColor = AppColors.forRank(playerState.rank);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceElevated, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + rank row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      player.name.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
              ),

              // Rank badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: rankColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: rankColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withAlpha(60),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Text(
                  '${playerState.rank}-RANK',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: rankColor,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Level + total XP row
          Row(
            children: [
              _InfoChip(
                label: 'LEVEL',
                value: '${playerState.level}',
                valueColor: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _InfoChip(
                label: 'TOTAL XP',
                value: '${player.totalXp}',
                valueColor: AppColors.textPrimary,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // XP progress bar
          XpProgressBar(
            progress: playerState.xpProgress,
            currentXp: playerState.currentLevelXp,
            requiredXp: playerState.xpToNextLevel,
            height: 10,
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.greetingMorning;
    if (hour < 17) return AppStrings.greetingAfternoon;
    return AppStrings.greetingEvening;
  }
}

// ── Info chip (level / XP display) ───────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textHint,
                letterSpacing: 2,
                fontSize: 10,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.player});
  final player;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('STR', player.statStr),
      ('INT', player.statInt),
      ('CRE', player.statCre),
      ('CHA', player.statCha),
      ('SKL', player.statSkl),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats.map((s) => _StatBadge(stat: s.$1, value: s.$2)).toList(),
    );
  }
}

// ── Individual stat badge ─────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.stat, required this.value});
  final String stat;
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStat(stat);
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80), width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            stat,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Streak badge ──────────────────────────────────────────────────────────────
class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.streakFire.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.streakFire.withAlpha(80),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              color: AppColors.streakFire,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

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
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 2,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

// ── Quest placeholder card ────────────────────────────────────────────────────
class _QuestPlaceholderCard extends StatelessWidget {
  const _QuestPlaceholderCard({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_clock,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$type Quests',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Unlocks in Phase 3',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick action buttons ──────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_task, 'Add Task', AppColors.primary),
      (Icons.loop, 'Log Habit', AppColors.secondary),
      (Icons.emoji_events, 'Quests', AppColors.warning),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _QuickActionButton(
              icon: a.$1,
              label: a.$2,
              color: a.$3,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // Wired in Phase 3
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withAlpha(40),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(60), width: 0.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Onboarding dialog (first launch) ─────────────────────────────────────────
class _OnboardingDialog extends ConsumerStatefulWidget {
  const _OnboardingDialog();

  @override
  ConsumerState<_OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends ConsumerState<_OnboardingDialog> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    await ref.read(playerProvider.notifier).createPlayer(name);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGlow,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'WELCOME, HUNTER',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    letterSpacing: 3,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your name to begin your journey.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Your name',
                prefixIcon: Icon(Icons.person_outline,
                    color: AppColors.textHint, size: 18),
              ),
              onSubmitted: (_) => _create(),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _create,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('ARISE'),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.9, 0.9),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
// ── Today's tasks preview on dashboard ────────────────────────────────────────
class _TodaysTasksPreview extends ConsumerWidget {
  const _TodaysTasksPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final tasks = taskState.todaysTasks.take(3).toList();

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGlow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_task,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No tasks yet. Tap Tasks to add your first quest.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.isCompleted
                  ? AppColors.surfaceBorder.withAlpha(60)
                  : AppColors.surfaceBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Completion dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                  boxShadow: task.isCompleted
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(100),
                            blurRadius: 6,
                          )
                        ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: task.isCompleted
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
              ),
              Text(
                '+${task.xpReward} XP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: task.isCompleted
                      ? AppColors.textHint
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}