import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_card.dart';
import 'widgets/weekly_bar_chart.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final profileAsync = ref.watch(profileNotifierProvider);
    final statsAsync = ref.watch(weeklyStatsProvider);
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navProgress),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: AppStrings.navAchievements,
            onPressed: () => context.push('/achievements'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentGreen,
          onRefresh: () async {
            ref.invalidate(weeklyStatsProvider);
            ref.read(profileNotifierProvider.notifier).loadProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Summary 4-grid
                profileAsync.when(
                  data: (profile) {
                    final streak = profile?.currentStreak ?? 0;
                    final longest = profile?.longestStreak ?? 0;
                    final xp = profile?.totalXp ?? 0;
                    final rate = statsAsync.value?.completionRate ?? 0.0;

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        _buildMetricCard(
                          icon: Icons.bolt_rounded,
                          accentColor: AppColors.accentXp,
                          label: AppStrings.totalXpLabel,
                          value: '$xp XP',
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          icon: Icons.local_fire_department_rounded,
                          accentColor: AppColors.accentStreak,
                          label: AppStrings.currentStreakLabel,
                          value: '$streak ${AppStrings.daysSuffix}',
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          icon: Icons.military_tech_rounded,
                          accentColor: AppColors.accentStreak,
                          label: AppStrings.longestStreakLabel,
                          value: '$longest ${AppStrings.daysSuffix}',
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          icon: Icons.trending_up_rounded,
                          accentColor: AppColors.accentGreen,
                          label: AppStrings.completionRateLabel,
                          value: '${(rate * 100).toInt()}%',
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
                const SizedBox(height: 24),

                // Weekly Chart
                statsAsync.when(
                  data: (stats) {
                    return WeeklyBarChart(stats: stats.weeklyActivity);
                  },
                  loading: () => Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) =>
                      Center(child: Text('Gagal memuat statistik: $e')),
                ),
                const SizedBox(height: 28),

                // Per-Habit Performance Section
                Text(
                  'Performa Tiap Kebiasaan',
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                habitsAsync.when(
                  data: (habits) {
                    if (habits.isEmpty) {
                      return AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Belum ada kebiasaan untuk dievaluasi.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }

                    final countMap =
                        statsAsync.value?.habitCompletionCounts ?? {};

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        final completedCount = countMap[habit.id] ?? 0;
                        final catColor =
                            AppColors.categoryColors[habit.category] ??
                                AppColors.accentGreen;

                        return AppCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.title,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      habit.category.toUpperCase(),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: catColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceElevated
                                      : AppColors.lightSurfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$completedCount selesai',
                                  style: AppTypography.statNumberSmall.copyWith(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color accentColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          Text(
            value,
            style: AppTypography.statNumber.copyWith(
              fontSize: 20,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
