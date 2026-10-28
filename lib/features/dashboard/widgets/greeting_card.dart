import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class GreetingCard extends StatelessWidget {
  final String displayName;
  final VoidCallback? onAvatarTap;

  const GreetingCard({
    super.key,
    required this.displayName,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hai, $displayName',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('👋', style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'One more step. One more day.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),

        // Circular Avatar with green ring (matches design image)
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentGreen.withValues(alpha: 0.8),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF282F3E),
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Y',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
