import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Crisp vector geometric logo from the design image:
/// Two intersecting modern geometric peaks: left in emerald/mint green, right in cyan/sky blue.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;

  const AppLogo({
    super.key,
    this.size = 56,
    this.showText = true,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size * 0.75),
          painter: _LogoPainter(),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'One More',
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size > 60 ? 32 : 24,
              letterSpacing: -0.5,
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            'One more step. One more day.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
              fontSize: 13,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Left peak - Vibrant Emerald Green
    final leftPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.fill;

    final leftPath = Path()
      ..moveTo(w * 0.15, h * 0.95)
      ..lineTo(w * 0.38, h * 0.05)
      ..lineTo(w * 0.50, h * 0.50)
      ..lineTo(w * 0.40, h * 0.85)
      ..lineTo(w * 0.38, h * 0.35)
      ..close();

    canvas.drawPath(leftPath, leftPaint);

    // Right peak - Sky Blue / Mint Cyan
    final rightPaint = Paint()
      ..color = AppColors.accentXp
      ..style = PaintingStyle.fill;

    final rightPath = Path()
      ..moveTo(w * 0.50, h * 0.50)
      ..lineTo(w * 0.65, h * 0.05)
      ..lineTo(w * 0.85, h * 0.95)
      ..lineTo(w * 0.65, h * 0.35)
      ..close();

    canvas.drawPath(rightPath, rightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

