import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_card.dart';

class LevelXpScreen extends ConsumerWidget {
  const LevelXpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).value;
    final level = profile?.currentLevel ?? 5;
    final xp = profile?.xpInCurrentLevel ?? 320;

    final history = [
      {
        'title': 'Minum Air 8 Gelas',
        'time': 'Hari ini • 06:12',
        'xp': 20,
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFF0284C7),
      },
      {
        'title': 'Olahraga 30 Menit',
        'time': 'Kemarin • 17:45',
        'xp': 30,
        'icon': Icons.directions_run_rounded,
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'Baca Buku 20 Menit',
        'time': '24 Okt • 20:10',
        'xp': 20,
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Tidur 7-8 Jam',
        'time': '23 Okt • 22:30',
        'xp': 20,
        'icon': Icons.bedtime_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: const Text('Level & XP',
            style: TextStyle(fontWeight: FontWeight.w700)),
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
              // Hero Level & Milestone Stepper Card matching Screen 7
              AppCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: AppColors.darkSurface,
                borderColor: AppColors.darkBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lv. $level',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          '$xp / 100 XP',
                          style: AppTypography.statNumberSmall.copyWith(
                            color: AppColors.darkTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (xp / 100.0).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.darkSurfaceElevated,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentGreen),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stepper nodes row matching Screen 7
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepNode(
                          label: 'Lv. ${level - 1}',
                          icon: Icons.military_tech_rounded,
                          isReached: true,
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: AppColors.accentGreen,
                          ),
                        ),
                        _buildStepNode(
                          label: 'Lv. $level',
                          icon: Icons.verified_rounded,
                          isCurrent: true,
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: AppColors.darkBorder,
                          ),
                        ),
                        _buildStepNode(
                          label: 'Lv. ${level + 1}',
                          icon: Icons.lock_outline_rounded,
                          isLocked: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section Header: Riwayat XP
              Text(
                'Riwayat XP',
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),

              // History items list matching Screen 7
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = history[index];
                  final color = item['color'] as Color;

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
                            item['icon'] as IconData,
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['time'] as String,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.darkTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${item['xp']} XP',
                          style: AppTypography.statNumberSmall.copyWith(
                            color: AppColors.accentGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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

  Widget _buildStepNode({
    required String label,
    required IconData icon,
    bool isReached = false,
    bool isCurrent = false,
    bool isLocked = false,
  }) {
    return Column(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.accentGreen
                : (isReached
                    ? AppColors.accentGreen.withValues(alpha: 0.2)
                    : AppColors.darkSurfaceElevated),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent || isReached
                  ? AppColors.accentGreen
                  : AppColors.darkBorder,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isCurrent
                ? const Color(0xFF032210)
                : (isReached
                    ? AppColors.accentGreen
                    : AppColors.darkTextTertiary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color:
                isCurrent ? AppColors.accentGreen : AppColors.darkTextSecondary,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
