import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/level_up_dialog.dart';
import '../../data/models/habit.dart';
import 'widgets/greeting_card.dart';
import 'widgets/mission_item_tile.dart';
import 'widgets/xp_progress_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Set<String> _processingHabits = {};

  Future<void> _handleCompleteHabit(Habit habit, int currentLevel) async {
    if (_processingHabits.contains(habit.id)) return;

    setState(() {
      _processingHabits.add(habit.id);
    });

    try {
      final completionsNotifier = ref.read(todayCompletionsProvider.notifier);
      final result = await completionsNotifier.completeHabit(
        habitId: habit.id,
        ref: ref,
      );

      if (mounted) {
        if (!result.alreadyCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppStrings.xpEarnedToast} (${habit.title})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.accentGreenDark,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Level up celebration check
          if (result.currentLevel > currentLevel) {
            LevelUpDialog.show(context, result.currentLevel, result.totalXp);
          }
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
      if (mounted) {
        setState(() {
          _processingHabits.remove(habit.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final profileAsync = ref.watch(profileNotifierProvider);
    final habitsAsync = ref.watch(habitsNotifierProvider);
    final completionsAsync = ref.watch(todayCompletionsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentGreen,
          onRefresh: () async {
            ref.read(profileNotifierProvider.notifier).loadProfile();
            ref.read(habitsNotifierProvider.notifier).loadHabits();
            ref.read(todayCompletionsProvider.notifier).loadTodayCompletions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Profile Greeting
                profileAsync.when(
                  data: (profile) => GreetingCard(
                    displayName: profile?.displayName ?? 'Teman One More',
                  ),
                  loading: () => const GreetingCard(displayName: '...'),
                  error: (_, __) =>
                      const GreetingCard(displayName: 'Teman One More'),
                ),
                const SizedBox(height: 20),

                // XP & Level Progression Card
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox.shrink();
                    return XpProgressCard(profile: profile);
                  },
                  loading: () => Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
                const SizedBox(height: 28),

                // Missions Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.todayMissionsTitle,
                      style: AppTypography.titleLarge.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    habitsAsync.when(
                      data: (habits) {
                        final now = DateTime.now();
                        final scheduled =
                            habits.where((h) => h.isScheduledFor(now)).toList();
                        final completedSet = completionsAsync.value ?? {};
                        final doneCount = scheduled
                            .where((h) => completedSet.contains(h.id))
                            .length;
                        return Text(
                          '$doneCount dari ${scheduled.length} ${AppStrings.completedCountSuffix}',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Missions List
                habitsAsync.when(
                  data: (habits) {
                    final now = DateTime.now();
                    final todayHabits =
                        habits.where((h) => h.isScheduledFor(now)).toList();
                    final completedSet = completionsAsync.value ?? {};
                    final profile = profileAsync.value;
                    final currentLevel = profile?.currentLevel ?? 1;

                    if (habits.isEmpty) {
                      return EmptyState(
                        icon: Icons.checklist_rounded,
                        title: 'Mulai Langkah Pertamamu',
                        message:
                            'Tambahkan kebiasaan harian baru untuk mulai mengumpulkan XP dan streak.',
                        actionLabel: AppStrings.createHabit,
                        onAction: () => context.push('/habits/new'),
                      );
                    }

                    if (todayHabits.isEmpty) {
                      return const EmptyState(
                        icon: Icons.event_available_rounded,
                        title: AppStrings.noMissionsScheduled,
                        message:
                            'Kamu tidak memiliki jadwal kebiasaan aktif untuk hari ini.',
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayHabits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final habit = todayHabits[index];
                        final isCompleted = completedSet.contains(habit.id);
                        final isProcessing =
                            _processingHabits.contains(habit.id);

                        return MissionItemTile(
                          habit: habit,
                          isCompleted: isCompleted,
                          isProcessing: isProcessing,
                          onToggle: () =>
                              _handleCompleteHabit(habit, currentLevel),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Gagal memuat misi: $e'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        foregroundColor: const Color(0xFF0F260C),
        elevation: 2,
        onPressed: () => context.push('/habits/new'),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
