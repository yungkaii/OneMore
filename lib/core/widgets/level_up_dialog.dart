import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import 'app_button.dart';

/// Celebratory modal when the user achieves a new level.
class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final int totalXp;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.totalXp,
  });

  static Future<void> show(BuildContext context, int newLevel, int totalXp) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelUpDialog(newLevel: newLevel, totalXp: totalXp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentGreen.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.military_tech_rounded,
                size: 44,
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.levelUpTitle,
              style: AppTypography.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.levelUpSubtitle} $newLevel!',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalXp XP Total Terkumpul',
              style: AppTypography.statNumberSmall.copyWith(
                color: AppColors.accentXp,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Lanjutkan Melangkah',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
