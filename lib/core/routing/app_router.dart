import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/reward_dialogs.dart';
import '../../data/models/habit.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/achievements/streak_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/register_screen.dart';
import '../../features/authentication/reset_password_screen.dart';
import '../../features/authentication/setup_guide_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/habits/daily_missions_screen.dart';
import '../../features/habits/habit_detail_screen.dart';
import '../../features/habits/habit_form_screen.dart';
import '../../features/habits/habit_list_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/progress/level_xp_screen.dart';
import '../../features/progress/progress_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final hasCompletedOnboarding = storage.hasCompletedOnboarding;
      final isAuthenticated = user != null;
      final path = state.uri.path;

      // 1. If onboarding not yet completed, redirect to splash or onboarding
      if (!hasCompletedOnboarding &&
          path != '/onboarding' &&
          path != '/splash') {
        return '/splash';
      }

      // 2. Auth routes
      final isAuthRoute = path == '/login' ||
          path == '/register' ||
          path == '/reset-password' ||
          path == '/onboarding' ||
          path == '/splash' ||
          path == '/setup-guide';

      // 3. Unauthenticated user trying to access app
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // 4. Authenticated user trying to access login/register/onboarding
      if (isAuthenticated &&
          (path == '/login' ||
              path == '/register' ||
              path == '/onboarding' ||
              path == '/splash')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/setup-guide',
        builder: (context, state) => const SetupGuideScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/streak',
        builder: (context, state) => const StreakScreen(),
      ),
      GoRoute(
        path: '/level-xp',
        builder: (context, state) => const LevelXpScreen(),
      ),
      GoRoute(
        path: '/habits/manage',
        builder: (context, state) => const HabitListScreen(),
      ),
      GoRoute(
        path: '/habits/new',
        builder: (context, state) => const HabitFormScreen(),
      ),
      GoRoute(
        path: '/habits/edit',
        builder: (context, state) {
          final habit = state.extra as Habit?;
          return HabitFormScreen(habitToEdit: habit);
        },
      ),
      GoRoute(
        path: '/habits/detail',
        builder: (context, state) {
          final habit = state.extra as Habit?;
          return HabitDetailScreen(habit: habit);
        },
      ),

      // Bottom Navigation Scaffold Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // 0: Beranda
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 1: Misi
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/missions',
                builder: (context, state) => const DailyMissionsScreen(),
              ),
              GoRoute(
                path: '/habits',
                builder: (context, state) => const DailyMissionsScreen(),
              ),
            ],
          ),
          // 2: Statistik
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          // 3: Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNav({super.key, required this.navigationShell});

  int _mapBranchToTabIndex(int branchIndex) {
    switch (branchIndex) {
      case 0:
        return 0; // Beranda
      case 1:
        return 1; // Misi
      case 2:
        return 3; // Statistik
      case 3:
        return 4; // Profil
      default:
        return 0;
    }
  }

  void _onTabSelected(BuildContext context, int tabIndex) {
    if (tabIndex == 2) {
      // Center "+" FAB clicked: show category picker sheet matching mockup
      RewardDialogs.showCategoryPickerSheet(context);
      return;
    }

    int branchIndex = 0;
    if (tabIndex == 0) branchIndex = 0;
    if (tabIndex == 1) branchIndex = 1;
    if (tabIndex == 3) branchIndex = 2;
    if (tabIndex == 4) branchIndex = 3;

    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTabIndex = _mapBranchToTabIndex(navigationShell.currentIndex);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          border: Border(
            top: BorderSide(
              color: AppColors.darkBorder.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 0: Beranda
                _buildNavItem(
                  context: context,
                  index: 0,
                  isActive: activeTabIndex == 0,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                ),
                // 1: Misi
                _buildNavItem(
                  context: context,
                  index: 1,
                  isActive: activeTabIndex == 1,
                  icon: Icons.checklist_rounded,
                  label: 'Misi',
                ),
                // 2: Center Elevated Green FAB "+"
                GestureDetector(
                  onTap: () => _onTabSelected(context, 2),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreen.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
                // 3: Statistik
                _buildNavItem(
                  context: context,
                  index: 3,
                  isActive: activeTabIndex == 3,
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistik',
                ),
                // 4: Profil
                _buildNavItem(
                  context: context,
                  index: 4,
                  isActive: activeTabIndex == 4,
                  icon: Icons.person_rounded,
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required bool isActive,
    required IconData icon,
    required String label,
  }) {
    final color = isActive ? AppColors.accentGreen : AppColors.darkTextTertiary;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(context, index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
