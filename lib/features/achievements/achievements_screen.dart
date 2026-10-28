import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import 'widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final achievementsAsync = ref.watch(achievementsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navAchievements),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentGreen,
          onRefresh: () async {
            ref.invalidate(achievementsListProvider);
          },
          child: achievementsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const Center(
                  child: Text('Belum ada data pencapaian.'),
                );
              }

              final unlockedCount = list.where((a) => a.isUnlocked).length;

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: list.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pencapaian Terbuka',
                            style: AppTypography.titleMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            '$unlockedCount dari ${list.length}',
                            style: AppTypography.statNumberSmall.copyWith(
                              fontSize: 13,
                              color: AppColors.accentXp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final achievement = list[index - 1];
                  return AchievementCard(achievement: achievement);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat pencapaian: $e'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
