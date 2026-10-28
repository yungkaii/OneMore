import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final storage = ref.read(storageServiceProvider);
      final user = ref.read(currentUserProvider);

      if (!storage.hasCompletedOnboarding) {
        context.go('/onboarding');
      } else if (user == null) {
        context.go('/login');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Atmospheric Mountain Landscape Background
          CustomPaint(
            size: size,
            painter: _MountainLandscapePainter(),
          ),

          // Central Logo and Branding
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Padding(
                padding: EdgeInsets.only(bottom: 120),
                child: AppLogo(
                  size: 80,
                  showText: true,
                  showTagline: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Atmospheric landscape painter with dark peaks, dawn glow, and wanderer silhouette
class _MountainLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF090B10),
          Color(0xFF0E131E),
          Color(0xFF1E1718),
          Color(0xFF452219),
          Color(0xFF6B331A),
        ],
        stops: [0.0, 0.45, 0.65, 0.78, 0.88],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Distant mountain layer
    final distantPaint = Paint()
      ..color = const Color(0xFF1A1620).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final distantPath = Path()
      ..moveTo(0, h * 0.75)
      ..lineTo(w * 0.25, h * 0.68)
      ..lineTo(w * 0.55, h * 0.72)
      ..lineTo(w * 0.85, h * 0.66)
      ..lineTo(w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(distantPath, distantPaint);

    // Foreground dark cliff on the left with wanderer
    final cliffPaint = Paint()
      ..color = const Color(0xFF0B0E14)
      ..style = PaintingStyle.fill;

    final cliffPath = Path()
      ..moveTo(0, h * 0.70)
      ..lineTo(w * 0.42, h * 0.74)
      ..lineTo(w * 0.48, h * 0.77)
      ..lineTo(w * 0.52, h * 0.82)
      ..lineTo(w * 0.60, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(cliffPath, cliffPaint);

    // Right foreground mountain
    final rightCliffPath = Path()
      ..moveTo(w * 0.55, h)
      ..lineTo(w * 0.75, h * 0.78)
      ..lineTo(w * 0.90, h * 0.80)
      ..lineTo(w, h * 0.75)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(rightCliffPath, cliffPaint);

    // Silhouette of lone adventurer on top of the cliff
    final wandererPaint = Paint()
      ..color = const Color(0xFF0B0E14)
      ..style = PaintingStyle.fill;

    final cx = w * 0.38;
    final cy = h * 0.738;

    // Body & backpack
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 14), width: 7, height: 16),
        const Radius.circular(2),
      ),
      wandererPaint,
    );
    // Head
    canvas.drawCircle(Offset(cx, cy - 25), 3.5, wandererPaint);
    // Backpack
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx - 3.5, cy - 16), width: 4.5, height: 9),
        const Radius.circular(2),
      ),
      wandererPaint,
    );
    // Legs
    canvas.drawRect(Rect.fromLTWH(cx - 3, cy - 6, 2.5, 7), wandererPaint);
    canvas.drawRect(Rect.fromLTWH(cx + 0.5, cy - 6, 2.5, 7), wandererPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
