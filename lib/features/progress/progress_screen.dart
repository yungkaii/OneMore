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
    final stats = statsAsync.value;
    final completionRate = stats != null && stats.completionRate > 0 ? stats.completionRate : 0.75;
    final totalCompletions = stats != null && stats.totalCompletions > 0 ? stats.totalCompletions : 18;
    final percentText = '${(completionRate * 100).round()}%';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Filter Pills matching Screen 9: 7 Hari | 30 Hari | Custom
              _buildFilterPills(),
              const SizedBox(height: 18),

              // Card 1: Penyelesaian Misi matching Screen 9
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
                        // Circular Donut Gauge 75%
                        SizedBox(
                          height: 72,
                          width: 72,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: completionRate,
                                strokeWidth: 8,
                                backgroundColor: AppColors.darkSurfaceElevated,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.accentGreen),
                              ),
                              Text(
                                percentText,
                                style: AppTypography.statNumberSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Stats and Mini Bar Chart on right
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$totalCompletions / 24',
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

                              // Mini weekly bars
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildMiniBar('Sen', 0.6),
                                  _buildMiniBar('Sel', 0.8),
                                  _buildMiniBar('Rab', 0.5),
                                  _buildMiniBar('Kam', 0.9),
                                  _buildMiniBar('Jum', 0.7),
                                  _buildMiniBar('Sab', 0.4),
                                  _buildMiniBar('Min', 0.85),
                                ],
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

              // Card 2: Rata-rata XP Harian matching Screen 9
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
                      '+42 XP',
                      style: AppTypography.statNumber.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Spline / Smooth Line Chart Painter
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _TrendLinePainter(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Card 3: Kebiasaan Terbaik matching Screen 9
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

                    // Habit 1: Olahraga 30 Menit - 92%
                    _buildBestHabitRow(
                      title: 'Olahraga 30 Menit',
                      percent: 92,
                      icon: Icons.directions_run_rounded,
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 14),

                    // Habit 2: Minum Air 8 Gelas - 85%
                    _buildBestHabitRow(
                      title: 'Minum Air 8 Gelas',
                      percent: 85,
                      icon: Icons.water_drop_rounded,
                      color: const Color(0xFF0284C7),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

  Widget _buildMiniBar(String day, double ratio) {
    return Column(
      children: [
        Container(
          height: 28 * ratio,
          width: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.darkTextTertiary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildBestHabitRow({
    required String title,
    required int percent,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: percent / 100.0,
                  minHeight: 5,
                  backgroundColor: AppColors.darkSurfaceElevated,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentGreen),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Text(
          '$percent%',
          style: AppTypography.statNumberSmall.copyWith(
            color: AppColors.darkTextSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = AppColors.accentGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, h * 0.75)
      ..lineTo(w * 0.18, h * 0.70)
      ..lineTo(w * 0.35, h * 0.50)
      ..lineTo(w * 0.52, h * 0.55)
      ..lineTo(w * 0.70, h * 0.30)
      ..lineTo(w * 0.88, h * 0.38)
      ..lineTo(w, h * 0.15);

    canvas.drawPath(path, linePaint);

    // End dot with glow
    final dotPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w, h * 0.15), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
