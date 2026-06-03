import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

/// Full-screen overlay shown when the player levels up.
/// Wrap your main screen with this widget.
class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({
    super.key,
    required this.show,
    required this.newLevel,
    required this.rank,
    required this.onDismiss,
    required this.child,
  });

  final bool show;
  final int newLevel;
  final String rank;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (show)
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              color: Colors.black.withAlpha(220),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glow ring
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(120),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.secondary.withAlpha(80),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$newLevel',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withAlpha(200),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 300.ms),

                  const SizedBox(height: 32),

                  // LEVEL UP text
                  Text(
                    'LEVEL UP',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: AppColors.textPrimary,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withAlpha(180),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),

                  // Rank badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.forRank(rank),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.forRank(rank).withAlpha(30),
                    ),
                    child: Text(
                      '$rank-Rank Hunter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forRank(rank),
                        letterSpacing: 2,
                      ),
                    ),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 48),

                  // Stat points notice
                  const Text(
                    '+3 STAT POINTS AWARDED',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 3,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      .animate(delay: 700.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 48),

                  // Dismiss hint
                  const Text(
                    'TAP TO CONTINUE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 4,
                      color: AppColors.textHint,
                    ),
                  )
                      .animate(delay: 1000.ms)
                      .fadeIn(duration: 400.ms),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms),
          ),
      ],
    );
  }
}