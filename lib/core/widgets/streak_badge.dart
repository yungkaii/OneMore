import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Pill badge displaying current or longest streak with warm amber styling.
class StreakBadge extends StatelessWidget {
  final int days;
  final bool isCompact;

  const StreakBadge({
    super.key,
    required this.days,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentStreak.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentStreak.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: AppColors.accentStreak,
          ),
          const SizedBox(width: 4),
          Text(
            '$days ${days == 1 ? "Hari" : "Hari"}',
            style: AppTypography.statNumberSmall.copyWith(
              fontSize: isCompact ? 12 : 13,
              color: AppColors.accentStreak,
            ),
          ),
        ],
      ),
    );
  }
}
