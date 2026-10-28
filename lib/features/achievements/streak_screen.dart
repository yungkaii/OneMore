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
    final streak = profile?.currentStreak ?? 7;

    final achievements = [
      {
        'title': 'Pemula',
        'desc': 'Selesaikan 5 misi',
        'color': AppColors.gold,
        'icon': Icons.military_tech_rounded,
      },
      {
        'title': 'Konsisten',
        'desc': 'Streak 7 hari',
        'color': AppColors.purple,
        'icon': Icons.verified_rounded,
      },
      {
        'title': 'Produktif',
        'desc': 'Selesaikan 30 misi',
        'color': AppColors.accentStreak,
        'icon': Icons.workspace_premium_rounded,
      },
    ];

    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

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
              // Hero Flame & Weekday Row Card matching Screen 8
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

                    // "7 Hari"
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
                      'Terus pertahankan streak-mu!',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 7 Weekday flames matching Screen 8
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final isActive = i < streak;
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

              // Achievement list matching Screen 8
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ach = achievements[index];
                  final color = ach['color'] as Color;

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
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            ach['icon'] as IconData,
                            color: color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ach['title'] as String,
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ach['desc'] as String,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.darkTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
