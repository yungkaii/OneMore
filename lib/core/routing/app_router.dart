import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../data/models/habit.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/register_screen.dart';
import '../../features/authentication/reset_password_screen.dart';
import '../../features/authentication/setup_guide_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/habits/habit_detail_screen.dart';
import '../../features/habits/habit_form_screen.dart';
import '../../features/habits/habit_list_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
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

      // 1. If onboarding not yet completed, redirect to onboarding
      if (!hasCompletedOnboarding && path != '/onboarding') {
        return '/onboarding';
      }

      // 2. Auth routes
      final isAuthRoute = path == '/login' ||
          path == '/register' ||
          path == '/reset-password' ||
          path == '/onboarding' ||
          path == '/setup-guide';

      // 3. Unauthenticated user trying to access app
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // 4. Authenticated user trying to access login/register/onboarding
      if (isAuthenticated &&
          (path == '/login' || path == '/register' || path == '/onboarding')) {
        return '/home';
      }

      return null;
    },
    routes: [
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
          final habit = state.extra as Habit;
          return HabitDetailScreen(habit: habit);
        },
      ),

      // Bottom Navigation Scaffold Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline_rounded),
            selectedIcon: Icon(Icons.check_circle_rounded),
            label: AppStrings.navHabits,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: AppStrings.navProgress,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}
