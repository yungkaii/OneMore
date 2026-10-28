import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Pill badge for displaying XP rewards or current XP counts.
class XpBadge extends StatelessWidget {
  final int xp;
  final bool showPlus;

  const XpBadge({
    super.key,
    required this.xp,
    this.showPlus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentXp.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentXp.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            size: 14,
            color: AppColors.accentXp,
          ),
          const SizedBox(width: 4),
          Text(
            '${showPlus ? "+" : ""}$xp XP',
            style: AppTypography.statNumberSmall.copyWith(
              fontSize: 12,
              color: AppColors.accentXp,
            ),
          ),
        ],
      ),
    );
  }
}
