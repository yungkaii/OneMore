import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/repositories/stats_repository.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<DailyActivityStat> stats;

  const WeeklyBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    int maxCount = 0;
    for (final s in stats) {
      if (s.completedCount > maxCount) maxCount = s.completedCount;
    }
    // Set a sensible minimum ceiling of 4 for visual proportions
    final ceiling = max(maxCount, 4);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas 7 Hari Terakhir',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                'Misi Selesai',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.map((stat) {
                final ratio = stat.completedCount / ceiling;
                final barHeight = (ratio * 100).clamp(4.0, 100.0);
                final hasActivity = stat.completedCount > 0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      stat.completedCount > 0 ? '${stat.completedCount}' : '',
                      style: AppTypography.statNumberSmall.copyWith(
                        fontSize: 11,
                        color: hasActivity
                            ? AppColors.accentGreen
                            : (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 24,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: hasActivity
                            ? AppColors.accentGreen
                            : (isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.lightSurfaceElevated),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: hasActivity
                              ? AppColors.accentGreen
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stat.dayLabel,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
