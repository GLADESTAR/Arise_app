import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    super.key,
    required this.progress,       // 0.0 to 1.0
    required this.currentXp,
    required this.requiredXp,
    this.height = 10,
    this.showLabel = true,
    this.animate = true,
  });

  final double progress;
  final int currentXp;
  final int requiredXp;
  final double height;
  final bool showLabel;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EXP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                ),
                Text(
                  '$currentXp / $requiredXp',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

        // Track + fill
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.xpBackground,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: AppColors.primary.withAlpha(40),
              width: 0.5,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fillWidth = constraints.maxWidth * progress.clamp(0.0, 1.0);
              return Stack(
                children: [
                  // Glow layer
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      width: fillWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height / 2),
                        color: AppColors.primary.withAlpha(40),
                      ),
                    ),
                  ),
                  // Solid fill
                  Positioned(
                    left: 0,
                    top: height * 0.2,
                    bottom: height * 0.2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      width: fillWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height / 2),
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(160),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ).animate(target: animate ? 1 : 0).shimmer(
              duration: 2000.ms,
              color: AppColors.primaryLight.withAlpha(40),
              delay: 500.ms,
            ),
      ],
    );
  }
}