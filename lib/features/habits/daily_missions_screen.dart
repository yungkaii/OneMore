import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/level_up_dialog.dart';
import '../../data/models/habit.dart';
import '../dashboard/widgets/mission_item_tile.dart';

class DailyMissionsScreen extends ConsumerStatefulWidget {
  const DailyMissionsScreen({super.key});

  @override
  ConsumerState<DailyMissionsScreen> createState() =>
      _DailyMissionsScreenState();
}

class _DailyMissionsScreenState extends ConsumerState<DailyMissionsScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Semua';
  final Set<String> _processingHabits = {};

  final List<String> _categories = [
    'Semua',
    'Produktivitas',
    'Kesehatan',
    'Diri',
    'Hiburan',
  ];

  String _formatDateHeader(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _handleToggleMission(Habit habit, int currentLevel) async {
    if (_processingHabits.contains(habit.id)) return;

    setState(() => _processingHabits.add(habit.id));

    try {
      final completionsNotifier = ref.read(todayCompletionsProvider.notifier);
      final result = await completionsNotifier.completeHabit(
        habitId: habit.id,
        ref: ref,
      );

      if (mounted && !result.alreadyCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+${habit.xpReward} XP diraih! (${habit.title})'),
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
      if (mounted) setState(() => _processingHabits.remove(habit.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsNotifierProvider);
    final completionsAsync = ref.watch(todayCompletionsProvider);
    final profile = ref.watch(profileNotifierProvider).value;
    final currentLevel = profile?.currentLevel ?? 1;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Misi Harian',
              style: AppTypography.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateHeader(_selectedDate),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Horizontal Week Calendar Strip (matches Screen 5)
            _buildWeekCalendarStrip(),
            const SizedBox(height: 16),

            // Horizontal Category Filter Pills (matches Screen 5)
            _buildCategoryFilterPills(),
            const SizedBox(height: 14),

            // Missions List
            Expanded(
              child: habitsAsync.when(
                data: (habits) {
                  var filtered = habits
                      .where((h) => h.isScheduledFor(_selectedDate))
                      .toList();

                  if (_selectedCategory != 'Semua') {
                    final catLower = _selectedCategory.toLowerCase();
                    filtered = filtered.where((h) {
                      final hCat = h.category.toLowerCase();
                      if (catLower == 'kesehatan') {
                        return hCat == 'health' || hCat == 'kesehatan';
                      }
                      if (catLower == 'produktivitas') {
                        return hCat == 'learning' ||
                            hCat == 'productivity' ||
                            hCat == 'produktivitas';
                      }
                      if (catLower == 'diri') {
                        return hCat == 'mindfulness' ||
                            hCat == 'diri' ||
                            hCat == 'routine';
                      }
                      return hCat == catLower;
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 40,
                            color: AppColors.darkTextTertiary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada misi untuk kategori ini',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final completedSet = completionsAsync.value ?? {};

                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final habit = filtered[index];
                      final isCompleted = completedSet.contains(habit.id);
                      final isProcessing = _processingHabits.contains(habit.id);

                      return MissionItemTile(
                        habit: habit,
                        isCompleted: isCompleted,
                        isProcessing: isProcessing,
                        onToggle: () =>
                            _handleToggleMission(habit, currentLevel),
                        onTap: () =>
                            context.push('/habits/detail', extra: habit),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                  ),
                ),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        foregroundColor: const Color(0xFF032210),
        elevation: 3,
        onPressed: () => context.push('/habits/new'),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  /// 7-day horizontal calendar selector matching Screen 5
  Widget _buildWeekCalendarStrip() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    const dayNames = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final date = startOfWeek.add(Duration(days: i));
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.accentGreen : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isSelected ? AppColors.accentGreen : AppColors.darkBorder,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    dayNames[i],
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected
                          ? const Color(0xFF032210)
                          : AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: AppTypography.statNumberSmall.copyWith(
                      color:
                          isSelected ? const Color(0xFF032210) : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Horizontal category filter pills matching Screen 5
  Widget _buildCategoryFilterPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.accentGreen : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? AppColors.accentGreen : AppColors.darkBorder,
                ),
              ),
              child: Text(
                cat,
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected
                      ? const Color(0xFF032210)
                      : AppColors.darkTextSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
