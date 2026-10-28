import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/user_profile.dart';

class XpProgressCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onTap;

  const XpProgressCard({
    super.key,
    required this.profile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = profile.currentLevel;
    final xpInLevel = profile.xpInCurrentLevel;
    final progress = profile.levelProgress;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      backgroundColor: AppColors.darkSurface,
      borderColor: AppColors.darkBorder,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lv. $currentLevel',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$xpInLevel / 100 XP',
                    style: AppTypography.statNumberSmall.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Neon glowing green progress bar matching design
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.darkSurfaceElevated,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentGreen),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
