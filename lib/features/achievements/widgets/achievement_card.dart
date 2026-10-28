import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/xp_badge.dart';
import '../../../data/models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  IconData _getIcon(String name) {
    switch (name) {
      case 'directions_walk':
        return Icons.directions_walk_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'stars':
        return Icons.stars_rounded;
      case 'verified':
        return Icons.verified_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUnlocked = achievement.isUnlocked;

    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isUnlocked
          ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
          : (isDark
              ? AppColors.darkSurface.withValues(alpha: 0.4)
              : AppColors.lightSurfaceElevated.withValues(alpha: 0.6)),
      borderColor: isUnlocked
          ? AppColors.accentXp.withValues(alpha: 0.35)
          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.accentXp.withValues(alpha: 0.2)
                  : (isDark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.lightSurfaceElevated),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? AppColors.accentXp.withValues(alpha: 0.5)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Icon(
              _getIcon(achievement.iconName),
              size: 24,
              color: isUnlocked
                  ? AppColors.accentXp
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: isUnlocked
                              ? (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary)
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                    XpBadge(xp: achievement.xpReward, showPlus: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                if (isUnlocked && achievement.unlockedAt != null)
                  Text(
                    'Diraih pada ${DateFormat("d MMM yyyy", "id_ID").format(achievement.unlockedAt!)}',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    'Terkunci',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
