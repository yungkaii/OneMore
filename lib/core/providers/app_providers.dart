import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/achievement.dart';
import '../../data/models/habit.dart';
import '../../data/models/starter_habits.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../config/env_config.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

// -----------------------------------------------------------------------------
// Core Services Providers
// -----------------------------------------------------------------------------

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in main()');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!EnvConfig.isConfigured) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

// -----------------------------------------------------------------------------
// Repositories Providers
// -----------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HabitRepository(client);
});

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AchievementRepository(client);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final habitRepo = ref.watch(habitRepositoryProvider);
  return StatsRepository(habitRepo);
});

// -----------------------------------------------------------------------------
// Auth & User State
// -----------------------------------------------------------------------------

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  ref.watch(authStateChangesProvider); // reactively update on auth change
  return authRepo.currentUser;
});

// -----------------------------------------------------------------------------
// Theme State
// -----------------------------------------------------------------------------

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage) : super(_parseMode(_storage.themeMode));

  static ThemeMode _parseMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    String modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.system) modeStr = 'system';
    await _storage.setThemeMode(modeStr);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});

// -----------------------------------------------------------------------------
// User Profile Notifier
// -----------------------------------------------------------------------------

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ProfileRepository _profileRepo;
  final String? _userId;

  ProfileNotifier(this._profileRepo, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadProfile();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loadProfile() async {
    if (_userId == null) return;
    state = const AsyncValue.loading();
    try {
      final profile = await _profileRepo.fetchProfile(_userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateLocalMetrics({
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
  }) {
    state.whenData((current) {
      if (current != null) {
        state = AsyncValue.data(current.copyWith(
          totalXp: totalXp,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          lastActiveDate: DateTime.now(),
        ));
      }
    });
  }

  Future<void> updateDisplayName(String newName) async {
    if (_userId == null) return;
    try {
      final updated = await _profileRepo.updateProfile(
        userId: _userId,
        displayName: newName,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repo, user?.id);
});

// -----------------------------------------------------------------------------
// Habits Notifier
// -----------------------------------------------------------------------------

class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  final HabitRepository _repo;
  final NotificationService _notifications;
  final String? _userId;

  HabitsNotifier(this._repo, this._notifications, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadHabits();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadHabits() async {
    if (_userId == null) return;
    try {
      final habits = await _repo.fetchActiveHabits(_userId);
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Habit> addHabit(Habit habit) async {
    final created = await _repo.createHabit(habit);
    if (created.reminderTime != null) {
      await _notifications.scheduleHabitReminder(created);
    }
    await loadHabits();
    return created;
  }

  Future<Habit> editHabit(Habit habit) async {
    final updated = await _repo.updateHabit(habit);
    await _notifications.cancelHabitReminder(habit.id);
    if (updated.reminderTime != null && !updated.isArchived) {
      await _notifications.scheduleHabitReminder(updated);
    }
    await loadHabits();
    return updated;
  }

  Future<void> archiveHabit(String habitId) async {
    if (_userId == null) return;
    await _repo.archiveHabit(habitId, _userId);
    await _notifications.cancelHabitReminder(habitId);
    await loadHabits();
  }

  Future<void> deleteHabit(String habitId) async {
    if (_userId == null) return;
    await _repo.deleteHabit(habitId, _userId);
    await _notifications.cancelHabitReminder(habitId);
    await loadHabits();
  }

  Future<void> seedStarterHabits() async {
    if (_userId == null) return;
    state = const AsyncValue.loading();
    try {
      final recommended = StarterHabits.getRecommended(_userId);
      for (final h in recommended) {
        await _repo.createHabit(h);
      }
      await loadHabits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final habitsNotifierProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(habitRepositoryProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return HabitsNotifier(repo, notifications, user?.id);
});

// -----------------------------------------------------------------------------
// Today's Completions Notifier
// -----------------------------------------------------------------------------

class TodayCompletionsNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  final HabitRepository _repo;
  final String? _userId;
  final DateTime _today;

  TodayCompletionsNotifier(this._repo, this._userId, this._today)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadTodayCompletions();
    } else {
      state = const AsyncValue.data({});
    }
  }

  Future<void> loadTodayCompletions() async {
    if (_userId == null) return;
    try {
      final completions = await _repo.fetchCompletionsForDate(_userId, _today);
      final set = completions.map((c) => c.habitId).toSet();
      state = AsyncValue.data(set);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Completes a habit through the transactional RPC.
  /// Updates profile totals, streak, and newly earned achievements.
  Future<CompletionResult> completeHabit({
    required String habitId,
    required WidgetRef ref,
  }) async {
    if (_userId == null) {
      throw Exception('Pengguna tidak terautentikasi');
    }

    // Call authoritative PostgreSQL completion transaction
    final result = await _repo.completeHabit(
      habitId: habitId,
      localDate: _today,
    );

    // Update completions set locally
    state.whenData((current) {
      final updated = Set<String>.from(current)..add(habitId);
      state = AsyncValue.data(updated);
    });

    // Update profile metrics directly from the server response
    ref.read(profileNotifierProvider.notifier).updateLocalMetrics(
          totalXp: result.totalXp,
          currentStreak: result.currentStreak,
          longestStreak: result.longestStreak,
        );

    // Invalidate weekly stats, achievements, and xp history so they refresh
    ref.invalidate(weeklyStatsProvider);
    ref.invalidate(achievementsListProvider);
    ref.invalidate(xpHistoryProvider);

    return result;
  }
}

final todayCompletionsProvider =
    StateNotifierProvider<TodayCompletionsNotifier, AsyncValue<Set<String>>>(
        (ref) {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(habitRepositoryProvider);
  final now = DateTime.now();
  return TodayCompletionsNotifier(repo, user?.id, now);
});

// -----------------------------------------------------------------------------
// Achievements Provider
// -----------------------------------------------------------------------------

final achievementsListProvider = FutureProvider<List<Achievement>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(achievementRepositoryProvider);
  return repo.fetchAchievements(user.id);
});

// -----------------------------------------------------------------------------
// Weekly Stats Provider
// -----------------------------------------------------------------------------

final weeklyStatsProvider = FutureProvider<ProgressAnalytics>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const ProgressAnalytics(
      weeklyActivity: [],
      totalCompletions: 0,
      completionRate: 0.0,
      habitCompletionCounts: {},
    );
  }

  final habitsAsync = ref.watch(habitsNotifierProvider);
  final activeHabits = habitsAsync.value ?? [];
  final statsRepo = ref.watch(statsRepositoryProvider);
  final now = DateTime.now();

  return statsRepo.getWeeklyAnalytics(
    userId: user.id,
    today: now,
    activeHabits: activeHabits,
  );
});

// -----------------------------------------------------------------------------
// Real XP History Provider
// -----------------------------------------------------------------------------

final xpHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchXpHistory(user.id);
});
