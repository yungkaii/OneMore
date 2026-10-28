import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_card.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedFilter = 0; // 0 = 7 Hari, 1 = 30 Hari, 2 = Custom

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(weeklyStatsProvider);
    final profile = ref.watch(profileNotifierProvider).value;
    final habits = ref.watch(habitsNotifierProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: Text(
          'Statistik',
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) {
            final completionRate = stats.completionRate;
            final percentText = '${(completionRate * 100).round()}%';
            final totalCompletions = stats.totalCompletions;

            final scheduledTotal = habits.fold<int>(
              0,
              (sum, h) => sum + h.activeWeekdays.length,
            );
            final targetDenominator =
                scheduledTotal > 0 ? scheduledTotal : max(1, totalCompletions);

            // Calculate daily average XP
            final activeDays =
                stats.weeklyActivity.where((s) => s.completedCount > 0).length;
            final totalXp = profile?.totalXp ?? 0;
            final avgXp = activeDays > 0 ? (totalXp / activeDays).round() : 0;

            // Sort best habits from real counts
            final completedHabits = habits
                .where((h) => (stats.habitCompletionCounts[h.id] ?? 0) > 0)
                .toList()
              ..sort((a, b) => (stats.habitCompletionCounts[b.id] ?? 0)
                  .compareTo(stats.habitCompletionCounts[a.id] ?? 0));

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Pills
                  _buildFilterPills(),
                  const SizedBox(height: 18),

                  // Card 1: Penyelesaian Misi
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: AppColors.darkSurface,
                    borderColor: AppColors.darkBorder,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penyelesaian Misi',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Circular Donut Gauge
                            SizedBox(
                              height: 72,
                              width: 72,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: completionRate,
                                    strokeWidth: 8,
                                    backgroundColor:
                                        AppColors.darkSurfaceElevated,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColors.accentGreen),
                                  ),
                                  Text(
                                    percentText,
                                    style:
                                        AppTypography.statNumberSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Real Stats and Weekly Bar Chart
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$totalCompletions / $targetDenominator',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'misi selesai',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.darkTextSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Real Weekly Bars
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: () {
                                      final maxCount = stats.weeklyActivity
                                          .map((s) => s.completedCount)
                                          .fold<int>(
                                              0, (a, b) => a > b ? a : b);
                                      return stats.weeklyActivity.map((s) {
                                        final ratio = maxCount > 0
                                            ? (s.completedCount / maxCount)
                                                .clamp(0.12, 1.0)
                                            : 0.1;
                                        return _buildMiniBar(s.dayLabel, ratio,
                                            s.completedCount > 0);
                                      }).toList();
                                    }(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 2: Rata-rata XP Harian
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: AppColors.darkSurface,
                    borderColor: AppColors.darkBorder,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rata-rata XP Harian',
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/level-xp'),
                              child: Text(
                                'Lihat Semua >',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.darkTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '+$avgXp XP',
                          style: AppTypography.statNumber.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Real Dynamic Spline Line Chart
                        SizedBox(
                          height: 54,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _TrendLinePainter(
                              dataPoints: stats.weeklyActivity
                                  .map((s) => s.completedCount.toDouble())
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 3: Kebiasaan Terbaik
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: AppColors.darkSurface,
                    borderColor: AppColors.darkBorder,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kebiasaan Terbaik',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (completedHabits.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Belum ada aktivitas kebiasaan minggu ini.\nSelesaikan misimu untuk melihat kebiasaan terbaik!',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.darkTextSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          )
                        else
                          ...completedHabits.take(3).map((habit) {
                            final count =
                                stats.habitCompletionCounts[habit.id] ?? 0;
                            final scheduled = habit.activeWeekdays.length;
                            final pct = scheduled > 0
                                ? ((count / scheduled) * 100)
                                    .round()
                                    .clamp(1, 100)
                                : 100;
                            final catColor = AppColors.categoryColors[
                                    habit.category.toLowerCase()] ??
                                AppColors.accentGreen;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildBestHabitRow(
                                title: habit.title,
                                percent: pct,
                                icon: _getHabitIcon(habit.category),
                                color: catColor,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
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
              child: Text('Gagal memuat statistik: $e'),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getHabitIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
      case 'kesehatan':
        return Icons.water_drop_rounded;
      case 'learning':
        return Icons.menu_book_rounded;
      case 'mindfulness':
      case 'diri':
        return Icons.self_improvement_rounded;
      case 'productivity':
      case 'produktivitas':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  Widget _buildBestHabitRow({
    required String title,
    required int percent,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$percent%',
              style: AppTypography.statNumberSmall.copyWith(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percent / 100.0).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.darkSurfaceElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPills() {
    const filters = ['7 Hari', '30 Hari', 'Custom'];
    return Row(
      children: List.generate(filters.length, (i) {
        final isSelected = _selectedFilter == i;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.darkSurfaceElevated
                    : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? AppColors.accentGreen : AppColors.darkBorder,
                ),
              ),
              child: Text(
                filters[i],
                style: AppTypography.bodySmall.copyWith(
                  color:
                      isSelected ? Colors.white : AppColors.darkTextSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMiniBar(String day, double ratio, bool hasCompletions) {
    return Column(
      children: [
        Container(
          height: 28 * ratio,
          width: 8,
          decoration: BoxDecoration(
            color: hasCompletions
                ? const Color(0xFF38BDF8)
                : AppColors.darkSurfaceElevated,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: AppTypography.bodySmall.copyWith(
            color: hasCompletions
                ? AppColors.darkTextSecondary
                : AppColors.darkTextTertiary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final List<double> dataPoints;

  _TrendLinePainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final maxVal = dataPoints.fold<double>(0.0, (a, b) => a > b ? a : b);
    final denom = maxVal > 0 ? maxVal : 1.0;

    final path = Path();
    final stepX = size.width / max(1, dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y =
          size.height - (dataPoints[i] / denom * (size.height * 0.75) + 6);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height -
            (dataPoints[i - 1] / denom * (size.height * 0.75) + 6);
        final cx1 = prevX + (x - prevX) / 2;
        final cy1 = prevY;
        final cx2 = prevX + (x - prevX) / 2;
        final cy2 = y;
        path.cubicTo(cx1, cy1, cx2, cy2, x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Glowing last node dot
    final lastX = size.width;
    final lastY =
        size.height - (dataPoints.last / denom * (size.height * 0.75) + 6);
    final dotPaint = Paint()..color = AppColors.accentGreen;
    canvas.drawCircle(Offset(lastX, lastY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) => true;
}
