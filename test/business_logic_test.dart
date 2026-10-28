import 'package:flutter_test/flutter_test.dart';
import 'package:onemore/data/models/achievement.dart';
import 'package:onemore/data/models/habit.dart';
import 'package:onemore/data/models/user_profile.dart';

void main() {
  group('Progression & XP Business Logic Tests', () {
    test('New user starts at Level 1 with 0 XP and 0/100 progress', () {
      final profile = UserProfile(
        id: 'u1',
        displayName: 'Alex',
        totalXp: 0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(profile.currentLevel, equals(1));
      expect(profile.xpInCurrentLevel, equals(0));
      expect(profile.xpRequiredForNextLevel, equals(100));
      expect(profile.levelProgress, equals(0.0));
    });

    test('70 XP results in Level 1 with 70/100 progress', () {
      final profile = UserProfile(
        id: 'u1',
        displayName: 'Alex',
        totalXp: 70,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(profile.currentLevel, equals(1));
      expect(profile.xpInCurrentLevel, equals(70));
      expect(profile.levelProgress, equals(0.70));
    });

    test('100 XP advances user to Level 2 with 0/100 progress', () {
      final profile = UserProfile(
        id: 'u1',
        displayName: 'Alex',
        totalXp: 100,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(profile.currentLevel, equals(2));
      expect(profile.xpInCurrentLevel, equals(0));
      expect(profile.levelProgress, equals(0.0));
    });

    test('250 XP results in Level 3 with 50/100 progress', () {
      final profile = UserProfile(
        id: 'u1',
        displayName: 'Alex',
        totalXp: 250,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(profile.currentLevel, equals(3));
      expect(profile.xpInCurrentLevel, equals(50));
      expect(profile.levelProgress, equals(0.50));
    });

    test('Deterministic level progression holds for high XP levels', () {
      final profile = UserProfile(
        id: 'u1',
        displayName: 'Alex',
        totalXp: 999,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      // floor(999/100) + 1 = 9 + 1 = 10
      expect(profile.currentLevel, equals(10));
      expect(profile.xpInCurrentLevel, equals(99));
      expect(profile.levelProgress, closeTo(0.99, 0.001));
    });
  });

  group('Habit Schedule Validation Tests', () {
    test('Habit scheduled for weekdays correctly identifies active days', () {
      final habit = Habit(
        id: 'h1',
        userId: 'u1',
        title: 'Membaca',
        category: 'learning',
        activeWeekdays: const [1, 3, 5], // Mon, Wed, Fri
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      // 2026-10-26 is Monday (weekday 1)
      expect(habit.isScheduledFor(DateTime(2026, 10, 26)), isTrue);
      // 2026-10-27 is Tuesday (weekday 2)
      expect(habit.isScheduledFor(DateTime(2026, 10, 27)), isFalse);
      // 2026-10-28 is Wednesday (weekday 3)
      expect(habit.isScheduledFor(DateTime(2026, 10, 28)), isTrue);
    });

    test('Archived habit is never scheduled regardless of active weekdays', () {
      final archivedHabit = Habit(
        id: 'h2',
        userId: 'u1',
        title: 'Berlari',
        category: 'health',
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        isArchived: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(archivedHabit.isScheduledFor(DateTime(2026, 10, 28)), isFalse);
    });
  });

  group('Achievement Model Tests', () {
    test('Achievement correctly differentiates locked and unlocked states', () {
      const locked = Achievement(
        id: 'first_step',
        title: 'First Step',
        description: 'Selesaikan kebiasaan pertama Anda.',
        iconName: 'directions_walk',
        targetType: 'total_completions',
        targetValue: 1,
      );
      expect(locked.isUnlocked, isFalse);

      final unlocked = locked.copyWith(unlockedAt: DateTime(2026, 10, 28));
      expect(unlocked.isUnlocked, isTrue);
      expect(unlocked.unlockedAt, isNotNull);
    });
  });
}
