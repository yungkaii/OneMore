import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/habit.dart';

class MissionItemTile extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final bool isProcessing;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const MissionItemTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.isProcessing,
    required this.onToggle,
    this.onTap,
  });

  IconData _getHabitIcon(String title, String category) {
    final lower = title.toLowerCase();
    if (lower.contains('minum') ||
        lower.contains('air') ||
        lower.contains('water')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('olahraga') ||
        lower.contains('lari') ||
        lower.contains('gym')) {
      return Icons.directions_run_rounded;
    }
    if (lower.contains('baca') ||
        lower.contains('buku') ||
        lower.contains('book')) {
      return Icons.menu_book_rounded;
    }
    if (lower.contains('tidur') ||
        lower.contains('sleep') ||
        lower.contains('istirahat')) {
      return Icons.bedtime_rounded;
    }
    if (lower.contains('makan') ||
        lower.contains('pola') ||
        lower.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('belajar') ||
        lower.contains('kerja') ||
        lower.contains('fokus')) {
      return Icons.laptop_mac_rounded;
    }
    return Icons.task_alt_rounded;
  }

  Color _getIconBgColor(String title, String category) {
    final lower = title.toLowerCase();
    if (lower.contains('minum')) return const Color(0xFF0284C7);
    if (lower.contains('olahraga')) return const Color(0xFF6366F1);
    if (lower.contains('baca')) return const Color(0xFF3B82F6);
    if (lower.contains('tidur')) return const Color(0xFF8B5CF6);
    if (lower.contains('makan')) return const Color(0xFF64748B);
    if (lower.contains('belajar') || lower.contains('kerja')) {
      return const Color(0xFF4F46E5);
    }
    return AppColors.accentGreenDark;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconBgColor(habit.title, habit.category);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: AppColors.darkSurface,
      borderColor: AppColors.darkBorder,
      onTap: onTap ?? onToggle,
      child: Row(
        children: [
          // Squircle Icon container matching design image
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getHabitIcon(habit.title, habit.category),
              color: iconColor.withValues(alpha: 0.9),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Title & XP label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: AppTypography.titleMedium.copyWith(
                    color:
                        isCompleted ? AppColors.darkTextTertiary : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '+${habit.xpReward} XP',
                  style: AppTypography.bodySmall.copyWith(
                    color: isCompleted
                        ? AppColors.darkTextTertiary
                        : AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Circular Checkbox matching design image
          GestureDetector(
            onTap: isProcessing ? null : onToggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.accentGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.accentGreen
                      : const Color(0xFF475569),
                  width: 1.8,
                ),
              ),
              child: isProcessing
                  ? const Padding(
                      padding: EdgeInsets.all(4),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accentGreen),
                      ),
                    )
                  : (isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: Color(0xFF032210),
                        )
                      : null),
            ),
          ),
        ],
      ),
    );
  }
}
