import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingCompleted(true);
    if (!mounted) return;
    context.go('/register');
  }

  Future<void> _goToLogin() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingCompleted(true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Lewati',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content Carousel
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // Slide 1: Stepping stones to summit
                  _buildSlide(
                    visual: const _SteppingStonesIllustration(),
                    title: 'Bangun Kebiasaan\nRaih Versi Terbaik Dirimu',
                    subtitle:
                        'One More membantumu membangun kebiasaan positif dan berkembang melalui misi harian yang seru.',
                  ),

                  // Slide 2: Floating mission card & XP
                  _buildSlide(
                    visual: const _MissionXpIllustration(),
                    title: 'Selesaikan Misi Harian\nDapatkan XP',
                    subtitle:
                        'Lakukan kebiasaan, kumpulkan XP, naik level, dan buka berbagai achievement menarik.',
                  ),
                ],
              ),
            ),

            // Bottom Controls matching image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // 4-Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: isActive ? 22 : 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accentGreen
                              : AppColors.darkBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Big bright green pill button
                  AppButton(
                    label: _currentPage == 0 ? 'Mulai' : 'Lanjut',
                    onPressed: () {
                      if (_currentPage < 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Login prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _goToLogin,
                        child: Text(
                          'Masuk',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required Widget visual,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Center(child: visual)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 23,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Stepping stones climbing toward mountain summit with glowing green flag (matches Onboarding 1)
class _SteppingStonesIllustration extends StatelessWidget {
  const _SteppingStonesIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 240,
      child: CustomPaint(
        painter: _SteppingStonesPainter(),
      ),
    );
  }
}

class _SteppingStonesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mountain peak dark silhouette
    final mountainPaint = Paint()
      ..color = const Color(0xFF141A24)
      ..style = PaintingStyle.fill;

    final mountainPath = Path()
      ..moveTo(w * 0.1, h * 0.95)
      ..lineTo(w * 0.70, h * 0.15)
      ..lineTo(w * 0.95, h * 0.95)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    // Glowing green flag at summit
    final polePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.70, h * 0.15), Offset(w * 0.70, h * 0.05), polePaint);

    final flagPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.fill;
    final flagPath = Path()
      ..moveTo(w * 0.70, h * 0.05)
      ..lineTo(w * 0.82, h * 0.08)
      ..lineTo(w * 0.70, h * 0.11)
      ..close();
    canvas.drawPath(flagPath, flagPaint);

    // Curved glowing green stepping stones
    final stones = [
      Offset(w * 0.22, h * 0.85),
      Offset(w * 0.30, h * 0.73),
      Offset(w * 0.40, h * 0.63),
      Offset(w * 0.48, h * 0.52),
      Offset(w * 0.56, h * 0.40),
      Offset(w * 0.62, h * 0.30),
      Offset(w * 0.67, h * 0.20),
    ];

    for (int i = 0; i < stones.length; i++) {
      final pos = stones[i];
      final scale = 1.0 - (i * 0.08);

      // Glow effect
      final glowPaint = Paint()
        ..color = AppColors.accentGreen.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 34 * scale, height: 16 * scale),
        glowPaint,
      );

      // Stone oval
      final stonePaint = Paint()
        ..color = AppColors.accentGreen
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 30 * scale, height: 13 * scale),
        stonePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating mission card and glowing diamond XP badge (matches Onboarding 2)
class _MissionXpIllustration extends StatelessWidget {
  const _MissionXpIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Mission card
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            backgroundColor: AppColors.darkSurface,
            borderColor: AppColors.darkBorder,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.categoryColors['kesehatan']!
                            .withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.accentXp,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Minum Air 8 Gelas',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+20 XP',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceElevated,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Glowing Diamond XP Badge
          Positioned(
            top: -10,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0C2417),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentGreen,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.4),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.accentGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'XP',
                    style: AppTypography.statNumberSmall.copyWith(
                      color: AppColors.accentGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
