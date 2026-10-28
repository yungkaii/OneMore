import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class StreakBannerCard extends StatelessWidget {
  final int days;
  final VoidCallback onTap;

  const StreakBannerCard({
    super.key,
    required this.days,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: AppColors.darkSurface,
      borderColor: AppColors.darkBorder,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentStreak.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.accentStreak,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '$days hari',
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.darkTextTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
