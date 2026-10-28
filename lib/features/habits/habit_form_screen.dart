import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/habit.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  final Habit? habitToEdit;

  const HabitFormScreen({super.key, this.habitToEdit});

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  String _selectedCategory = 'health';
  final Set<int> _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7};
  TimeOfDay? _reminderTime;

  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'health',
      'label': AppStrings.catHealth,
      'icon': Icons.favorite_rounded
    },
    {
      'id': 'learning',
      'label': AppStrings.catLearning,
      'icon': Icons.menu_book_rounded
    },
    {
      'id': 'mindfulness',
      'label': AppStrings.catMindfulness,
      'icon': Icons.self_improvement_rounded
    },
    {
      'id': 'productivity',
      'label': AppStrings.catProductivity,
      'icon': Icons.check_circle_outline_rounded
    },
    {
      'id': 'routine',
      'label': AppStrings.catRoutine,
      'icon': Icons.schedule_rounded
    },
  ];

  final List<String> _weekdayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min'
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _descController = TextEditingController(text: h?.description ?? '');

    if (h != null) {
      _selectedCategory = h.category;
      _selectedWeekdays.clear();
      _selectedWeekdays.addAll(h.activeWeekdays);
      if (h.reminderTime != null) {
        final parts = h.reminderTime!.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final min = int.tryParse(parts[1]);
          if (hour != null && min != null) {
            _reminderTime = TimeOfDay(hour: hour, minute: min);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWeekdays.isEmpty) {
      setState(() {
        _errorMessage = 'Pilih minimal satu hari aktif untuk kebiasaan ini.';
      });
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() {
        _errorMessage = 'Sesi pengguna tidak valid. Silakan masuk kembali.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifier = ref.read(habitsNotifierProvider.notifier);
      final reminderStr = _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, "0")}:${_reminderTime!.minute.toString().padLeft(2, "0")}'
          : null;

      if (widget.habitToEdit != null) {
        final updated = widget.habitToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          category: _selectedCategory,
          activeWeekdays: _selectedWeekdays.toList()..sort(),
          reminderTime: reminderStr,
        );
        await notifier.editHabit(updated);
      } else {
        final newHabit = Habit(
          id: '',
          userId: user.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          category: _selectedCategory,
          activeWeekdays: _selectedWeekdays.toList()..sort(),
          reminderTime: reminderStr,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await notifier.addHabit(newHabit);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.habitToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editHabit : AppStrings.createHabit),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Habit Title
                AppTextField(
                  controller: _titleController,
                  label: AppStrings.habitTitleLabel,
                  hint: AppStrings.habitTitleHint,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama kebiasaan wajib diisi.';
                    }
                    if (val.trim().length > 100) {
                      return 'Nama kebiasaan maksimal 100 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Habit Description
                AppTextField(
                  controller: _descController,
                  label: AppStrings.habitDescLabel,
                  hint: AppStrings.habitDescHint,
                  maxLines: 2,
                  validator: (val) {
                    if (val != null && val.trim().length > 300) {
                      return 'Keterangan maksimal 300 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                // Category Selector
                Text(
                  AppStrings.categoryLabel,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final id = c['id'] as String;
                    final label = c['label'] as String;
                    final icon = c['icon'] as IconData;
                    final isSelected = _selectedCategory == id;
                    final catColor =
                        AppColors.categoryColors[id] ?? AppColors.accentGreen;

                    return ChoiceChip(
                      avatar: Icon(
                        icon,
                        size: 16,
                        color: isSelected ? const Color(0xFF0F260C) : catColor,
                      ),
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = id);
                      },
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      selectedColor: catColor,
                      labelStyle: AppTypography.bodySmall.copyWith(
                        color: isSelected
                            ? const Color(0xFF0F260C)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? catColor
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Active Days Selector
                Text(
                  AppStrings.activeDaysLabel,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final dayNum = index + 1; // 1=Mon, 7=Sun
                    final isSelected = _selectedWeekdays.contains(dayNum);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            if (_selectedWeekdays.length > 1) {
                              _selectedWeekdays.remove(dayNum);
                            }
                          } else {
                            _selectedWeekdays.add(dayNum);
                          }
                        });
                      },
                      child: Container(
                        height: 42,
                        width: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentGreen
                              : (isDark
                                  ? AppColors.darkSurfaceElevated
                                  : AppColors.lightSurfaceElevated),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentGreen
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                        ),
                        child: Text(
                          _weekdayLabels[index],
                          style: AppTypography.bodySmall.copyWith(
                            color: isSelected
                                ? const Color(0xFF0F260C)
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Reminder Time
                Text(
                  AppStrings.reminderTimeLabel,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  onTap: _pickTime,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.alarm_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _reminderTime != null
                                ? '${_reminderTime!.hour.toString().padLeft(2, "0")}:${_reminderTime!.minute.toString().padLeft(2, "0")}'
                                : 'Atur waktu pengingat harian',
                            style: AppTypography.bodyMedium.copyWith(
                              color: _reminderTime != null
                                  ? (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary)
                                  : (isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary),
                            ),
                          ),
                        ],
                      ),
                      if (_reminderTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            setState(() => _reminderTime = null);
                          },
                        )
                      else
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.darkTextTertiary),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Submit Button
                AppButton(
                  label: AppStrings.saveChanges,
                  isLoading: _isLoading,
                  onPressed: _saveHabit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
