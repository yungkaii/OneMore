import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/level_up_dialog.dart';
import '../../data/models/habit.dart';
import 'widgets/greeting_card.dart';
import 'widgets/mission_item_tile.dart';
import 'widgets/streak_banner_card.dart';
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
                '+${habit.xpReward} XP diraih! (${habit.title})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.accentGreenDark,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );

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
    final profileAsync = ref.watch(profileNotifierProvider);
    final habitsAsync = ref.watch(habitsNotifierProvider);
    final completionsAsync = ref.watch(todayCompletionsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentGreen,
          backgroundColor: AppColors.darkSurface,
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
                // Top Greeting & Avatar
                profileAsync.when(
                  data: (profile) => GreetingCard(
                    displayName: profile?.displayName ?? 'Yukafii',
                    onAvatarTap: () => context.go('/profile'),
                  ),
                  loading: () => const GreetingCard(displayName: 'Yukafii'),
                  error: (_, __) => const GreetingCard(displayName: 'Yukafii'),
                ),
                const SizedBox(height: 18),

                // Level Progress Card
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox.shrink();
                    return XpProgressCard(
                      profile: profile,
                      onTap: () => context.push('/level-xp'),
                    );
                  },
                  loading: () => Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
                const SizedBox(height: 12),

                // Streak Banner Card
                profileAsync.when(
                  data: (profile) => StreakBannerCard(
                    days: profile?.currentStreak ?? 7,
                    onTap: () => context.push('/streak'),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Section Header: "Misi Hari Ini" ... "3/6 selesai"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Misi Hari Ini',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
                          '$doneCount/${scheduled.length} selesai',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
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

                // Mission List
                habitsAsync.when(
                  data: (habits) {
                    final now = DateTime.now();
                    final todayHabits =
                        habits.where((h) => h.isScheduledFor(now)).toList();
                    final completedSet = completionsAsync.value ?? {};
                    final profile = profileAsync.value;
                    final currentLevel = profile?.currentLevel ?? 1;

                    if (habits.isEmpty || todayHabits.isEmpty) {
                      return _buildEmptyMissionsCard(context);
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
                          onTap: () =>
                              context.push('/habits/detail', extra: habit),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accentGreen),
                      ),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Gagal memuat misi: $e'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Empty state matching the design image (mountain silhouette + "+ Tambah Misi")
  Widget _buildEmptyMissionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.landscape_rounded,
            size: 48,
            color: AppColors.darkTextTertiary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 14),
          Text(
            'Hari ini belum ada misi selesai',
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Yuk, mulai dulu dari yang kecil.\nKamu pasti bisa!',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.darkTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: const Color(0xFF032210),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Tambah Misi',
                style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () => context.push('/habits/new'),
          ),
        ],
      ),
    );
  }
}
