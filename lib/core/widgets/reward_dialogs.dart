import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../widgets/app_button.dart';

/// Gorgeous modal dialogs matching the mockup (Level Up, New Achievement, Category Picker)
class RewardDialogs {
  /// Shows the "Level Up!" dialog matching the bottom mockup
  static Future<void> showLevelUpDialog(
    BuildContext context, {
    int newLevel = 5,
    int currentXp = 320,
    int xpForNextLevel = 500,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.accentGreen.withValues(alpha: 0.3),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing green shield badge
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreen.withValues(alpha: 0.4),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceElevated,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.accentGreen, width: 2),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.accentGreen,
                      size: 38,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Level Up!',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lv. $newLevel',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currentXp / $xpForNextLevel XP',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Lanjut',
                variant: AppButtonVariant.primary,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the "Achievement Baru!" dialog matching the bottom mockup
  static Future<void> showAchievementUnlockedDialog(
    BuildContext context, {
    String title = 'Konsisten',
    String description = 'Selesaikan 7 hari berturut-turut',
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.15),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Golden trophy badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.gold,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Achievement Baru!',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Oke',
                variant: AppButtonVariant.primary,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the "Pilih Kategori" bottom sheet matching the bottom mockup
  static Future<void> showCategoryPickerSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Kategori',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.darkTextSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCategoryItem(
                  context,
                  title: 'Produktivitas',
                  icon: Icons.work_outline_rounded,
                  color: AppColors.accentXp,
                ),
                const SizedBox(height: 8),
                _buildCategoryItem(
                  context,
                  title: 'Kesehatan',
                  icon: Icons.water_drop_outlined,
                  color: AppColors.accentGreen,
                ),
                const SizedBox(height: 8),
                _buildCategoryItem(
                  context,
                  title: 'Diri',
                  icon: Icons.spa_outlined,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 8),
                _buildCategoryItem(
                  context,
                  title: 'Hiburan',
                  icon: Icons.sports_esports_outlined,
                  color: AppColors.purple,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Batal',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCategoryItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.push('/habits/new');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.darkTextTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
