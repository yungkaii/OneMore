import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  final List<String> _starterHabits = [
    'Membaca Buku 15 Menit',
    'Minum Air 2 Liter',
    'Olahraga Ringan 15 Menit',
    'Belajar 20 Menit',
    'Tidur Tepat Waktu',
    'Menulis Catatan Refleksi',
  ];

  final Set<String> _selectedHabits = {
    'Membaca Buku 15 Menit',
    'Minum Air 2 Liter',
  };

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_currentPage < 2)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                AppStrings.skip,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildSlide(
                    icon: Icons.alt_route_rounded,
                    title: AppStrings.onboardingTitle1,
                    subtitle: AppStrings.onboardingSubtitle1,
                    isDark: isDark,
                  ),
                  _buildSlide(
                    icon: Icons.bolt_rounded,
                    title: AppStrings.onboardingTitle2,
                    subtitle: AppStrings.onboardingSubtitle2,
                    isDark: isDark,
                  ),
                  _buildInteractiveSlide(isDark: isDark),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: isActive ? 24 : 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accentGreen
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: _currentPage == 2
                        ? AppStrings.getStarted
                        : AppStrings.continueText,
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSlide({required bool isDark}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            AppStrings.enterDisplayName,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 20,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _nameController,
            hint: AppStrings.displayNameHint,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.chooseStarterHabits,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _starterHabits.map((habit) {
              final isSelected = _selectedHabits.contains(habit);
              return FilterChip(
                label: Text(habit),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedHabits.add(habit);
                    } else {
                      _selectedHabits.remove(habit);
                    }
                  });
                },
                backgroundColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
                selectedColor: AppColors.accentGreen.withValues(alpha: 0.2),
                checkmarkColor: AppColors.accentGreen,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.accentGreen
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                labelStyle: AppTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.accentGreen
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
