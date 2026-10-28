import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_card.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).value;
    final streak = profile?.currentStreak ?? 0;
    final achievementsAsync = ref.watch(achievementsListProvider);
    final stats = ref.watch(weeklyStatsProvider).value;

    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Map which days in the past 7 days had completions
    final completedDaysSet = <String>{};
    if (stats != null) {
      for (final s in stats.weeklyActivity) {
        if (s.completedCount > 0) {
          completedDaysSet.add(s.dayLabel);
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title:
            const Text('Streak', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Flame & Weekday Row Card
              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                backgroundColor: AppColors.darkSurface,
                borderColor: AppColors.darkBorder,
                child: Column(
                  children: [
                    // Big fire icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentStreak.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.accentStreak,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Real Streak Days
                    Text(
                      '$streak Hari',
                      style: AppTypography.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streak > 0
                          ? 'Terus pertahankan streak-mu!'
                          : 'Selesaikan misi hari ini untuk menyalakan streak!',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 7 Weekday flames (active if user completed habit on that day)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final dayName = days[i];
                        final isActive = completedDaysSet.contains(dayName) ||
                            (streak > 0 && i < streak && i < 7);

                        return Column(
                          children: [
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accentStreak
                                        .withValues(alpha: 0.2)
                                    : AppColors.darkSurfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.accentStreak
                                      : AppColors.darkBorder,
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                size: 18,
                                color: isActive
                                    ? AppColors.accentStreak
                                    : AppColors.darkTextTertiary
                                        .withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              days[i],
                              style: AppTypography.bodySmall.copyWith(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.darkTextSecondary,
                                fontSize: 10,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Header: Pencapaian ... Lihat Semua >
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pencapaian',
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/achievements'),
                    child: Row(
                      children: [
                        Text(
                          'Lihat Semua',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.darkTextSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Real Achievement List from database
              achievementsAsync.when(
                data: (achList) {
                  final displayList = achList.take(3).toList();
                  if (displayList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Text(
                        'Belum ada pencapaian terbuka.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.darkTextSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final ach = displayList[index];
                      final isUnlocked = ach.isUnlocked;
                      final Color color = index == 0
                          ? AppColors.gold
                          : (index == 1
                              ? AppColors.purple
                              : AppColors.accentStreak);

                      return AppCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        backgroundColor: AppColors.darkSurface,
                        borderColor: AppColors.darkBorder,
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? color.withValues(alpha: 0.2)
                                    : AppColors.darkSurfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isUnlocked
                                    ? Icons.stars_rounded
                                    : Icons.lock_outline_rounded,
                                color: isUnlocked
                                    ? color
                                    : AppColors.darkTextTertiary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ach.title,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: isUnlocked
                                          ? Colors.white
                                          : AppColors.darkTextSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ach.description,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.darkTextTertiary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUnlocked)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.accentGreen,
                                size: 18,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                    ),
                  ),
                ),
                error: (e, _) => Center(child: Text('Gagal: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
