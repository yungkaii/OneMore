import 'package:flutter_test/flutter_test.dart';

/// Pure unit test modeling the server-side streak state machine to verify correctness
/// across same-day, consecutive, missed-day, and month/year boundaries.
class StreakCalculator {
  static ({int currentStreak, int longestStreak, DateTime lastActiveDate})
      calculateStreak({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastActiveDate,
    required DateTime completionDate,
  }) {
    final compDateOnly =
        DateTime(completionDate.year, completionDate.month, completionDate.day);

    if (lastActiveDate == null) {
      const newStreak = 1;
      return (
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
        lastActiveDate: compDateOnly,
      );
    }

    final lastDateOnly =
        DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
    final difference = compDateOnly.difference(lastDateOnly).inDays;

    if (difference == 0) {
      // Completed another habit on the same local date: streak unchanged!
      return (
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastActiveDate: lastDateOnly,
      );
    } else if (difference == 1) {
      // Consecutive date: increment streak
      final newStreak = currentStreak + 1;
      return (
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
        lastActiveDate: compDateOnly,
      );
    } else if (difference > 1) {
      // Missed at least 1 day: reset streak to 1
      const newStreak = 1;
      return (
        currentStreak: newStreak,
        longestStreak: longestStreak,
        lastActiveDate: compDateOnly,
      );
    } else {
      // Past back-fill completion: preserve current streak
      return (
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastActiveDate: lastDateOnly,
      );
    }
  }
}

void main() {
  group('Daily Streak State Machine Tests', () {
    test('First completion sets streak to 1 and longest streak to 1', () {
      final res = StreakCalculator.calculateStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: null,
        completionDate: DateTime(2026, 10, 1),
      );

      expect(res.currentStreak, equals(1));
      expect(res.longestStreak, equals(1));
    });

    test('Multiple completions on the SAME date do NOT increment streak again',
        () {
      final first = StreakCalculator.calculateStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: null,
        completionDate: DateTime(2026, 10, 1, 8, 30),
      );

      final second = StreakCalculator.calculateStreak(
        currentStreak: first.currentStreak,
        longestStreak: first.longestStreak,
        lastActiveDate: first.lastActiveDate,
        completionDate: DateTime(2026, 10, 1, 14, 00),
      );

      expect(second.currentStreak, equals(1));
      expect(second.longestStreak, equals(1));
    });

    test(
        'Consecutive daily completion increments streak and updates longest streak',
        () {
      var state = (
        currentStreak: 1,
        longestStreak: 1,
        lastActiveDate: DateTime(2026, 10, 1),
      );

      // Day 2
      state = StreakCalculator.calculateStreak(
        currentStreak: state.currentStreak,
        longestStreak: state.longestStreak,
        lastActiveDate: state.lastActiveDate,
        completionDate: DateTime(2026, 10, 2),
      );
      expect(state.currentStreak, equals(2));
      expect(state.longestStreak, equals(2));

      // Day 3
      state = StreakCalculator.calculateStreak(
        currentStreak: state.currentStreak,
        longestStreak: state.longestStreak,
        lastActiveDate: state.lastActiveDate,
        completionDate: DateTime(2026, 10, 3),
      );
      expect(state.currentStreak, equals(3));
      expect(state.longestStreak, equals(3));
    });

    test(
        'Missing an intervening date resets current streak to 1 without erasing longest streak',
        () {
      final state = (
        currentStreak: 5,
        longestStreak: 5,
        lastActiveDate: DateTime(2026, 10, 5),
      );

      // User skips October 6th and completes on October 7th
      final res = StreakCalculator.calculateStreak(
        currentStreak: state.currentStreak,
        longestStreak: state.longestStreak,
        lastActiveDate: state.lastActiveDate,
        completionDate: DateTime(2026, 10, 7),
      );

      expect(res.currentStreak, equals(1));
      expect(res.longestStreak, equals(5)); // Longest streak preserved!
    });

    test('Correctly handles Month boundary transition (Feb 28 -> Mar 1)', () {
      final state = (
        currentStreak: 4,
        longestStreak: 4,
        lastActiveDate: DateTime(2026, 2, 28),
      );

      final res = StreakCalculator.calculateStreak(
        currentStreak: state.currentStreak,
        longestStreak: state.longestStreak,
        lastActiveDate: state.lastActiveDate,
        completionDate: DateTime(2026, 3, 1),
      );

      expect(res.currentStreak, equals(5));
      expect(res.longestStreak, equals(5));
    });

    test('Correctly handles Year boundary transition (Dec 31 -> Jan 1)', () {
      final state = (
        currentStreak: 10,
        longestStreak: 10,
        lastActiveDate: DateTime(2026, 12, 31),
      );

      final res = StreakCalculator.calculateStreak(
        currentStreak: state.currentStreak,
        longestStreak: state.longestStreak,
        lastActiveDate: state.lastActiveDate,
        completionDate: DateTime(2027, 1, 1),
      );

      expect(res.currentStreak, equals(11));
      expect(res.longestStreak, equals(11));
    });
  });
}
