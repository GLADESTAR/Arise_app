import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../core/widgets/xp_progress_bar.dart';
import '../../data/models/player_model.dart';
import '../providers/player_provider.dart';
import '../../../habits/presentation/providers/habit_provider.dart';
import '../../../habits/data/models/achievement_model.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final achievementState = ref.watch(achievementProvider);
    final player = playerState.player;

    if (player == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──────────────────────────────────────────
          const SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            title: Text('PLAYER STATS'),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Identity card ──────────────────────────────
                _IdentityCard(playerState: playerState)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // ── Stat points banner ─────────────────────────
                if (player.statPoints > 0)
                  _StatPointsBanner(points: player.statPoints)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0),

                if (player.statPoints > 0)
                  const SizedBox(height: 16),

                // ── Stats allocation ───────────────────────────
                const _SectionHeader(title: 'ATTRIBUTES'),
                const SizedBox(height: 12),

                _StatAllocator(player: player)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // ── Achievements ───────────────────────────────
                _SectionHeader(
                  title: 'ACHIEVEMENTS',
                  trailing:
                      '${achievementState.unlocked.length}/${achievementState.all.length}',
                ),
                const SizedBox(height: 12),

                _AchievementsGrid(
                  achievements: achievementState.all,
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // ── Lifetime stats ─────────────────────────────
                const _SectionHeader(title: 'LIFETIME STATS'),
                const SizedBox(height: 12),

                _LifetimeStats(player: player)
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Identity card ─────────────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.playerState});
  final PlayerState playerState;

  @override
  Widget build(BuildContext context) {
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
            color: rankColor.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    playerState.player!.name
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerState.player!.name.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _InfoPill(
                          label: 'LVL ${playerState.level}',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _InfoPill(
                          label: '${playerState.rank}-RANK',
                          color: rankColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          XpProgressBar(
            progress: playerState.xpProgress,
            currentXp: playerState.currentLevelXp,
            requiredXp: playerState.xpToNextLevel,
            height: 10,
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total XP: ${playerState.player!.totalXp}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Next level: ${XpCalculator.xpNeededForLevel(playerState.level)} XP',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Stat points banner ────────────────────────────────────────────────────────
class _StatPointsBanner extends StatelessWidget {
  const _StatPointsBanner({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(40),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$points STAT POINTS AVAILABLE',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Tap + to allocate points to your attributes',
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

// ── Stat allocator ────────────────────────────────────────────────────────────
class _StatAllocator extends ConsumerWidget {
  const _StatAllocator({required this.player});
  final PlayerModel player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = [
      ('STR', 'Strength', '💪', player.statStr,
          'Physical tasks and workouts'),
      ('INT', 'Intelligence', '🧠', player.statInt,
          'Study and learning tasks'),
      ('CRE', 'Creativity', '🎨', player.statCre,
          'Creative and artistic tasks'),
      ('CHA', 'Charisma', '✨', player.statCha,
          'Social and communication tasks'),
      ('SKL', 'Skill', '🎯', player.statSkl,
          'Technical and professional tasks'),
    ];

    return Column(
      children: stats.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        return _StatRow(
          stat: s.$1,
          label: s.$2,
          emoji: s.$3,
          value: s.$4,
          description: s.$5,
          canAllocate: player.statPoints > 0,
          onAllocate: () =>
              ref.read(playerProvider.notifier).allocateStat(s.$1),
          animDelay: i * 60,
        );
      }).toList(),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.stat,
    required this.label,
    required this.emoji,
    required this.value,
    required this.description,
    required this.canAllocate,
    required this.onAllocate,
    required this.animDelay,
  });

  final String stat;
  final String label;
  final String emoji;
  final int value;
  final String description;
  final bool canAllocate;
  final VoidCallback onAllocate;
  final int animDelay;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStat(stat);
    // Bar fill: each point = 2%, capped at 100%
    final barFill = (value * 0.02).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // Emoji
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),

          // Label + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          description,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    // Value badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: color.withAlpha(80), width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          width: constraints.maxWidth * barFill,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withAlpha(180),
                                color,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(120),
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
          ),
          const SizedBox(width: 10),

          // Allocate button
          GestureDetector(
            onTap: canAllocate ? onAllocate : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: canAllocate
                    ? AppColors.secondary.withAlpha(25)
                    : AppColors.surfaceBorder.withAlpha(40),
                shape: BoxShape.circle,
                border: Border.all(
                  color: canAllocate
                      ? AppColors.secondary
                      : AppColors.textHint.withAlpha(40),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: canAllocate
                    ? AppColors.secondary
                    : AppColors.textHint.withAlpha(60),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: animDelay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ── Achievements grid ─────────────────────────────────────────────────────────
class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({required this.achievements});
  final List<AchievementModel> achievements;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Text(
          'Complete tasks and habits to unlock achievements.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        return _AchievementCell(achievement: a, index: index);
      },
    );
  }
}

class _AchievementCell extends StatelessWidget {
  const _AchievementCell({
    required this.achievement,
    required this.index,
  });
  final AchievementModel achievement;
  final int index;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.warning.withAlpha(10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unlocked
                ? AppColors.warning.withAlpha(80)
                : AppColors.surfaceBorder,
            width: unlocked ? 1 : 0.5,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: AppColors.warning.withAlpha(30),
                    blurRadius: 8,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            ColorFiltered(
              colorFilter: unlocked
                  ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix([
                      0.2, 0, 0, 0, 0,
                      0, 0.2, 0, 0, 0,
                      0, 0, 0.2, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textHint,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            if (unlocked)
              Text(
                '+${achievement.xpReward} XP',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              const Icon(Icons.lock_outline,
                  size: 12, color: AppColors.textHint),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: achievement.isUnlocked
                ? AppColors.warning
                : AppColors.surfaceBorder,
            width: achievement.isUnlocked ? 1.5 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(achievement.icon,
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                achievement.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? AppColors.warning.withAlpha(20)
                      : AppColors.surfaceBorder.withAlpha(60),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: achievement.isUnlocked
                        ? AppColors.warning.withAlpha(80)
                        : AppColors.surfaceBorder,
                  ),
                ),
                child: Text(
                  achievement.isUnlocked
                      ? '✓ Unlocked — +${achievement.xpReward} XP'
                      : '🔒 Locked',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: achievement.isUnlocked
                        ? AppColors.warning
                        : AppColors.textHint,
                  ),
                ),
              ),
              if (achievement.isUnlocked &&
                  achievement.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Unlocked on ${achievement.unlockedAt}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Lifetime stats ────────────────────────────────────────────────────────────
class _LifetimeStats extends StatelessWidget {
  const _LifetimeStats({required this.player});
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Tasks Completed', '${player.tasksCompleted}', Icons.assignment_turned_in_outlined, AppColors.primary),
      ('Habits Logged', '${player.habitsCompleted}', Icons.loop, AppColors.secondary),
      ('Best Streak', '${player.longestStreak} days', Icons.local_fire_department_outlined, AppColors.streakFire),
      ('Total XP Earned', '${player.totalXp}', Icons.star_outline, AppColors.warning),
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
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final s = stats[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(s.$3, color: s.$4, size: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.$2,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: s.$4,
                    ),
                  ),
                  Text(
                    s.$1,
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

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final String? trailing;

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
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 2,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );
  }
}