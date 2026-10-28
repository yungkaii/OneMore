import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_card.dart';

class LevelXpScreen extends ConsumerWidget {
  const LevelXpScreen({super.key});

  String _formatTimestamp(dynamic createdAtRaw) {
    if (createdAtRaw == null) return 'Baru saja';
    DateTime? dt = DateTime.tryParse(createdAtRaw.toString())?.toLocal();
    if (dt == null) return 'Baru saja';

    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isYesterday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day - 1;

    final timeStr = DateFormat('HH:mm').format(dt);

    if (isToday) return 'Hari ini • $timeStr';
    if (isYesterday) return 'Kemarin • $timeStr';
    return '${DateFormat("d MMM", "id_ID").format(dt)} • $timeStr';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).value;
    final level = profile?.currentLevel ?? 1;
    final xp = profile?.xpInCurrentLevel ?? 0;
    final historyAsync = ref.watch(xpHistoryProvider);

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
              // Hero Level & Milestone Stepper Card
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

                    // Stepper nodes row matching level progression
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepNode(
                          label: level > 1 ? 'Lv. ${level - 1}' : 'Mulai',
                          icon: level > 1
                              ? Icons.military_tech_rounded
                              : Icons.flag_rounded,
                          isReached: level > 1,
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: level > 1
                                ? AppColors.accentGreen
                                : AppColors.darkBorder,
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

              // Real History Items from Supabase
              historyAsync.when(
                data: (historyList) {
                  if (historyList.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 32),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 38,
                            color: AppColors.darkTextTertiary
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum Ada Riwayat XP',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Selesaikan misi kebiasaan harian pertamamu\nuntuk mulai mengumpulkan XP!',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.darkTextSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: historyList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = historyList[index];
                      final habitData = item['habits'] as Map<String, dynamic>?;
                      final title =
                          habitData?['title'] as String? ?? 'Penyelesaian Misi';
                      final timeStr = _formatTimestamp(item['created_at']);
                      final xpDelta = item['xp_awarded'] ?? 15;

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
                                color: AppColors.accentGreen
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.task_alt_rounded,
                                color: AppColors.accentGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    timeStr,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.darkTextSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+$xpDelta XP',
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
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                    ),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Gagal memuat riwayat: $e'),
                  ),
                ),
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
