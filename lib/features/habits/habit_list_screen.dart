import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/habit.dart';

class HabitListScreen extends ConsumerStatefulWidget {
  const HabitListScreen({super.key});

  @override
  ConsumerState<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends ConsumerState<HabitListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatWeekdays(List<int> weekdays) {
    if (weekdays.length == 7) return 'Setiap Hari';
    if (weekdays.length == 5 &&
        !weekdays.contains(6) &&
        !weekdays.contains(7)) {
      return 'Hari Kerja (Sen-Jum)';
    }
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final sorted = List<int>.from(weekdays)..sort();
    return sorted.map((d) => days[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final habitsAsync = ref.watch(habitsNotifierProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.habitsTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGreen,
          labelColor: AppColors.accentGreen,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Arsip'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Habits Tab
          habitsAsync.when(
            data: (habits) {
              if (habits.isEmpty) {
                return EmptyState(
                  icon: Icons.track_changes_rounded,
                  title: 'Belum Ada Kebiasaan',
                  message:
                      'Rancang kebiasaan pertamamu dan mulai langkah kecil hari ini.',
                  actionLabel: AppStrings.createHabit,
                  onAction: () => context.push('/habits/new'),
                );
              }

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: habits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final catColor = AppColors.categoryColors[habit.category] ??
                      AppColors.accentGreen;

                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('/habits/detail', extra: habit),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                habit.title,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                habit.category.toUpperCase(),
                                style: AppTypography.bodySmall.copyWith(
                                  color: catColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (habit.description != null &&
                            habit.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            habit.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatWeekdays(habit.activeWeekdays),
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            if (habit.reminderTime != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                habit.reminderTime!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text(e.toString())),
          ),

          // Archived Habits Tab
          FutureBuilder<List<Habit>>(
            future: user != null
                ? ref.read(habitRepositoryProvider).fetchArchivedHabits(user.id)
                : Future.value([]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2));
              }
              final archived = snapshot.data ?? [];
              if (archived.isEmpty) {
                return const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Tidak Ada Arsip',
                  message:
                      'Kebiasaan yang kamu arsipkan akan tersimpan di sini tanpa menghapus riwayat XP.',
                );
              }

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: archived.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final habit = archived[index];
                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('/habits/detail', extra: habit),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.archivedNotice,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.darkTextTertiary),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
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
