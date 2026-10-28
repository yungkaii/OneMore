import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/habit.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  bool _isLoading = false;

  Future<void> _toggleArchive() async {
    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(habitsNotifierProvider.notifier);
      if (widget.habit.isArchived) {
        await ref
            .read(habitRepositoryProvider)
            .unarchiveHabit(widget.habit.id, widget.habit.userId);
        await notifier.loadHabits();
      } else {
        await notifier.archiveHabit(widget.habit.id);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah arsip: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kebiasaan?'),
        content: const Text(
          'Kebiasaan ini akan dihapus dari daftar. Catatan XP dan pencapaian yang sudah diraih tidak akan hilang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final notifier = ref.read(habitsNotifierProvider.notifier);
        await notifier.deleteHabit(widget.habit.id);
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habit = widget.habit;
    final catColor =
        AppColors.categoryColors[habit.category] ?? AppColors.accentGreen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kebiasaan'),
        actions: [
          if (!habit.isArchived)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/habits/edit', extra: habit),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Habit Header Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        habit.category.toUpperCase(),
                        style: AppTypography.statNumberSmall.copyWith(
                          fontSize: 11,
                          color: catColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      habit.title,
                      style: AppTypography.headlineMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (habit.description != null &&
                        habit.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        habit.description!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Settings Details Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRow(
                      icon: Icons.bolt_rounded,
                      label: 'Hadiah Misi',
                      value: '+15 XP per hari',
                      isDark: isDark,
                      accentColor: AppColors.accentXp,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Jadwal Hari',
                      value: habit.activeWeekdays.length == 7
                          ? 'Setiap Hari'
                          : '${habit.activeWeekdays.length} hari per minggu',
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      icon: Icons.alarm_rounded,
                      label: 'Pengingat Waktu',
                      value: habit.reminderTime ?? 'Tidak aktif',
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      icon: habit.isArchived
                          ? Icons.archive_rounded
                          : Icons.check_circle_outline_rounded,
                      label: 'Status Kebiasaan',
                      value: habit.isArchived ? 'Diarsipkan' : 'Aktif',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Archive / Unarchive Action
              AppButton(
                label: habit.isArchived
                    ? AppStrings.unarchiveHabit
                    : AppStrings.archiveHabit,
                variant: AppButtonVariant.secondary,
                isLoading: _isLoading,
                onPressed: _toggleArchive,
              ),
              const SizedBox(height: 12),

              // Delete Action
              AppButton(
                label: AppStrings.deleteHabit,
                variant: AppButtonVariant.destructive,
                isLoading: _isLoading,
                onPressed: _confirmDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? accentColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: accentColor ??
                  (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontSize: 14,
            color: accentColor ??
                (isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
