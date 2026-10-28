import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/xp_badge.dart';
import '../../../data/models/habit.dart';

class MissionItemTile extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final bool isProcessing;
  final VoidCallback onToggle;

  const MissionItemTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.isProcessing,
    required this.onToggle,
  });

  String _getCategoryLabel(String cat) {
    switch (cat) {
      case 'health':
        return AppStrings.catHealth;
      case 'learning':
        return AppStrings.catLearning;
      case 'mindfulness':
        return AppStrings.catMindfulness;
      case 'productivity':
        return AppStrings.catProductivity;
      case 'routine':
      default:
        return AppStrings.catRoutine;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor =
        AppColors.categoryColors[habit.category] ?? AppColors.accentGreen;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: isCompleted
          ? (isDark
              ? AppColors.darkSurface.withValues(alpha: 0.5)
              : AppColors.lightSurfaceElevated.withValues(alpha: 0.5))
          : null,
      child: Row(
        children: [
          // Checkbox / Loading Circle
          GestureDetector(
            onTap: isProcessing ? null : onToggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.accentGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.accentGreen
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 2,
                ),
              ),
              child: isProcessing
                  ? const Padding(
                      padding: EdgeInsets.all(4),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accentGreen),
                      ),
                    )
                  : (isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Color(0xFF0F260C),
                        )
                      : null),
            ),
          ),
          const SizedBox(width: 14),

          // Habit Title & Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: isCompleted
                        ? (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary)
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getCategoryLabel(habit.category),
                        style: AppTypography.bodySmall.copyWith(
                          color: catColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (habit.reminderTime != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.alarm_rounded,
                        size: 12,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        habit.reminderTime!,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // XP Badge
          const SizedBox(width: 8),
          XpBadge(xp: habit.xpReward, showPlus: true),
        ],
      ),
    );
  }
}
