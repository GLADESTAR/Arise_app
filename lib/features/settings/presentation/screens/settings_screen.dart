import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../habits/presentation/providers/habit_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final player = playerState.player;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        physics: const BouncingScrollPhysics(),
        children: [

          // ── Player info ──────────────────────────────────────
          if (player != null) ...[
            _SettingsCard(
              children: [
                _PlayerInfoTile(
                  name: player.name,
                  level: playerState.level,
                  rank: playerState.rank,
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
          ],

          // ── Data section ─────────────────────────────────────
          const _SectionLabel('DATA MANAGEMENT'),
          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.upload_outlined,
                iconColor: AppColors.primary,
                title: 'Export Data',
                subtitle: 'Save your progress as a JSON file',
                onTap: () => _exportData(context, ref),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.download_outlined,
                iconColor: AppColors.secondary,
                title: 'Import Data',
                subtitle: 'Restore from a backup file',
                onTap: () => _showImportDialog(context),
              ),
            ],
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // ── App section ──────────────────────────────────────
          const _SectionLabel('ABOUT'),
          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              const _SettingsTile(
                icon: Icons.info_outline,
                iconColor: AppColors.info,
                title: 'Version',
                subtitle: '1.0.0 — Phase 5 Complete',
                onTap: null,
                trailing: SizedBox(),
              ),
              _Divider(),
              const _SettingsTile(
                icon: Icons.code,
                iconColor: AppColors.secondary,
                title: 'Built with',
                subtitle: 'Flutter + Hive + Riverpod',
                onTap: null,
                trailing: SizedBox(),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // ── Danger zone ──────────────────────────────────────
          const _SectionLabel('DANGER ZONE'),
          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                iconColor: AppColors.error,
                title: 'Reset All Data',
                subtitle: 'Permanently delete all progress',
                onTap: () => _confirmReset(context, ref),
              ),
            ],
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  // ── Export data as JSON ────────────────────────────────────────────────────
  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final player = ref.read(playerProvider).player;
      final tasks  = ref.read(taskProvider).allTasks;
      final habits = ref.read(habitProvider).habits;

      final data = {
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'player': player == null
            ? null
            : {
                'name':          player.name,
                'totalXp':       player.totalXp,
                'statStr':       player.statStr,
                'statInt':       player.statInt,
                'statCre':       player.statCre,
                'statCha':       player.statCha,
                'statSkl':       player.statSkl,
                'statPoints':    player.statPoints,
                'currentStreak': player.currentStreak,
                'longestStreak': player.longestStreak,
                'tasksCompleted': player.tasksCompleted,
                'habitsCompleted': player.habitsCompleted,
              },
        'tasks': tasks
            .map((t) => {
                  'title':      t.title,
                  'difficulty': t.difficultyIndex,
                  'recurrence': t.recurrenceIndex,
                  'isCompleted': t.isCompleted,
                  'category':   t.category,
                })
            .toList(),
        'habits': habits
            .map((h) => {
                  'name':             h.name,
                  'icon':             h.icon,
                  'currentStreak':    h.currentStreak,
                  'longestStreak':    h.longestStreak,
                  'completionDates':  h.completionDates,
                  'xpPerCompletion':  h.xpPerCompletion,
                })
            .toList(),
      };

      final dir  = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/arise_backup.json');
      await file.writeAsString(jsonEncode(data));

      if (context.mounted) {
        _showSnack(
          context,
          '✓ Exported to arise_backup.json',
          AppColors.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, 'Export failed: $e', AppColors.error);
      }
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text('Import Data'),
        content: const Text(
          'Import reads arise_backup.json from your documents folder.\n\n'
          'This feature will be expanded with a file picker in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 1),
        ),
        title: const Text(
          'Reset All Data',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'This will permanently delete your player, all tasks, '
          'habits, and achievements. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('RESET EVERYTHING'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _showSnack(
        context,
        'Reset requires app restart. Close and reopen the app.',
        AppColors.warning,
      );
    }
  }

  void _showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 0.5),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── Settings card container ───────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppColors.textHint,
            size: 18,
          ),
    );
  }
}

// ── Player info tile ──────────────────────────────────────────────────────────
class _PlayerInfoTile extends StatelessWidget {
  const _PlayerInfoTile({
    required this.name,
    required this.level,
    required this.rank,
  });
  final String name, rank;
  final int level;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
      title: Text(name,
          style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        'Level $level · $rank-Rank Hunter',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const SizedBox(),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0,
      indent: 56,
      endIndent: 16,
      color: AppColors.surfaceBorder,
      thickness: 0.5,
    );
  }
}