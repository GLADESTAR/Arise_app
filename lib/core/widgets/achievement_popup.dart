import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../../features/habits/data/models/achievement_model.dart';

/// Shows a stack of achievement unlock popups at the top of the screen.
/// Wrap your app shell with this.
class AchievementPopupOverlay extends StatefulWidget {
  const AchievementPopupOverlay({
    super.key,
    required this.achievements,
    required this.onDismissed,
    required this.child,
  });

  final List<AchievementModel> achievements;
  final VoidCallback onDismissed;
  final Widget child;

  @override
  State<AchievementPopupOverlay> createState() =>
      _AchievementPopupOverlayState();
}

class _AchievementPopupOverlayState
    extends State<AchievementPopupOverlay> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(AchievementPopupOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.achievements != oldWidget.achievements &&
        widget.achievements.isNotEmpty) {
      _currentIndex = 0;
    }
  }

  void _next() {
    if (_currentIndex < widget.achievements.length - 1) {
      setState(() => _currentIndex++);
    } else {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.achievements.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: _next,
              child: _AchievementBanner(
                key: ValueKey(_currentIndex),
                achievement: widget.achievements[_currentIndex],
                remaining: widget.achievements.length - _currentIndex - 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _AchievementBanner extends StatelessWidget {
  const _AchievementBanner({
    super.key,
    required this.achievement,
    required this.remaining,
  });

  final AchievementModel achievement;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withAlpha(80),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.warning.withAlpha(120),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'ACHIEVEMENT UNLOCKED',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                        letterSpacing: 2,
                      ),
                    ),
                    if (remaining > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+$remaining more',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // XP reward
          Column(
            children: [
              Text(
                '+${achievement.xpReward}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.warning,
                ),
              ),
              const Text(
                'XP',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 300.ms)
        .then(delay: 3000.ms)
        .slideY(begin: 0, end: -1, duration: 300.ms, curve: Curves.easeIn)
        .fadeOut(duration: 200.ms);
  }
}