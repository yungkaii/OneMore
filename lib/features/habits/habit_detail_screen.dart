import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/level_up_dialog.dart';
import '../../data/models/habit.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final Habit? habit;

  const HabitDetailScreen({super.key, this.habit});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  int _progressCount = 6;
  final int _targetCount = 8;
  bool _isProcessing = false;

  Habit get habit =>
      widget.habit ??
      Habit(
        id: 'fallback_water_habit',
        userId: 'default_user',
        title: 'Minum Air 8 Gelas',
        description: 'Minum minimal 8 gelas air dalam sehari (±2 liter).',
        category: 'kesehatan',
        iconName: 'water_drop',
        accentColor: 'blue',
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        isArchived: false,
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  Future<void> _handleComplete() async {
    setState(() => _isProcessing = true);
    try {
      final isRealUuid = RegExp(r'^[0-9a-fA-F\-]{36}$').hasMatch(habit.id);
      if (!isRealUuid) {
        setState(() {
          _progressCount = _targetCount;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('+20 XP diraih!'),
              backgroundColor: AppColors.accentGreenDark,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final profile = ref.read(profileNotifierProvider).value;
      final currentLevel = profile?.currentLevel ?? 1;

      final completionsNotifier = ref.read(todayCompletionsProvider.notifier);
      final result = await completionsNotifier.completeHabit(
        habitId: habit.id,
        ref: ref,
      );

      setState(() {
        _progressCount = _targetCount;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+${habit.xpReward} XP diraih!'),
            backgroundColor: AppColors.accentGreenDark,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (result.currentLevel > currentLevel) {
          LevelUpDialog.show(context, result.currentLevel, result.totalXp);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.errorContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColors[habit.category.toLowerCase()] ??
        AppColors.accentXp;
    final completions = ref.watch(todayCompletionsProvider).value ?? {};
    final isAlreadyCompleted = completions.contains(habit.id);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.darkTextSecondary),
            onPressed: () => context.push('/habits/edit', extra: habit),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section matching Screen 6
              Center(
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: catColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    color: catColor,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                habit.title,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),

              // Tags row (Category + XP)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: catColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      habit.category.toUpperCase(),
                      style: AppTypography.bodySmall.copyWith(
                        color: catColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.accentGreen.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '+${habit.xpReward} XP',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                habit.description ??
                    'Minum minimal 8 gelas air dalam sehari (±2 liter).',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Progress Hari Ini Card matching Screen 6
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
                          'Progress Hari Ini',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$_progressCount / $_targetCount gelas',
                          style: AppTypography.statNumberSmall.copyWith(
                            color: AppColors.darkTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_progressCount / _targetCount).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.darkSurfaceElevated,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentGreen),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 8 Glasses Icons row matching Screen 6
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_targetCount, (index) {
                        final isFilled = index < _progressCount;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _progressCount = index + 1;
                            });
                          },
                          child: Icon(
                            isFilled
                                ? Icons.local_drink_rounded
                                : Icons.local_drink_outlined,
                            size: 24,
                            color: isFilled
                                ? const Color(0xFF38BDF8)
                                : AppColors.darkTextTertiary
                                    .withValues(alpha: 0.4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Full width green button matching Screen 6: "✓ Tandai Selesai"
              AppButton(
                label:
                    isAlreadyCompleted ? 'Sudah Selesai' : '✓ Tandai Selesai',
                isLoading: _isProcessing,
                onPressed: isAlreadyCompleted ? null : _handleComplete,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
