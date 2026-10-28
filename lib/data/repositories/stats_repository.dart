import 'package:intl/intl.dart';
import '../models/habit.dart';
import 'habit_repository.dart';

class DailyActivityStat {
  final DateTime date;
  final String dayLabel; // e.g. 'Sen', 'Sel'
  final int completedCount;

  const DailyActivityStat({
    required this.date,
    required this.dayLabel,
    required this.completedCount,
  });
}

class ProgressAnalytics {
  final List<DailyActivityStat> weeklyActivity;
  final int totalCompletions;
  final double completionRate; // 0.0 to 1.0
  final Map<String, int> habitCompletionCounts; // habitId -> count

  const ProgressAnalytics({
    required this.weeklyActivity,
    required this.totalCompletions,
    required this.completionRate,
    required this.habitCompletionCounts,
  });
}

/// Computes real analytics from persisted records.
class StatsRepository {
  final HabitRepository _habitRepository;

  StatsRepository(this._habitRepository);

  Future<ProgressAnalytics> getWeeklyAnalytics({
    required String userId,
    required DateTime today,
    required List<Habit> activeHabits,
  }) async {
    final startDate = today.subtract(const Duration(days: 6));
    final completions = await _habitRepository.fetchCompletionsForRange(
      userId: userId,
      startDate: startDate,
      endDate: today,
    );

    // Group completions by date string (yyyy-MM-dd) and habitId
    final Map<String, int> dateCountMap = {};
    final Map<String, int> habitCountMap = {};

    for (final c in completions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(c.completionDate);
      dateCountMap[dateKey] = (dateCountMap[dateKey] ?? 0) + 1;
      habitCountMap[c.habitId] = (habitCountMap[c.habitId] ?? 0) + 1;
    }

    final List<DailyActivityStat> weekly = [];
    int totalScheduledOccurrences = 0;
    int totalCompleted = 0;

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final count = dateCountMap[dateKey] ?? 0;
      totalCompleted += count;

      // Calculate scheduled habits on this day of week
      final weekday = date.weekday;
      final scheduledOnDay =
          activeHabits.where((h) => h.activeWeekdays.contains(weekday)).length;
      totalScheduledOccurrences += scheduledOnDay;

      // Indonesian short day label
      final dayLabel = _getIndonesianDayShort(date.weekday);
      weekly.add(DailyActivityStat(
        date: date,
        dayLabel: dayLabel,
        completedCount: count,
      ));
    }

    final double rate = totalScheduledOccurrences > 0
        ? (totalCompleted / totalScheduledOccurrences).clamp(0.0, 1.0)
        : (totalCompleted > 0 ? 1.0 : 0.0);

    return ProgressAnalytics(
      weeklyActivity: weekly,
      totalCompletions: completions.length,
      completionRate: rate,
      habitCompletionCounts: habitCountMap,
    );
  }

  static String _getIndonesianDayShort(int weekday) {
    switch (weekday) {
      case 1:
        return 'Sen';
      case 2:
        return 'Sel';
      case 3:
        return 'Rab';
      case 4:
        return 'Kam';
      case 5:
        return 'Jum';
      case 6:
        return 'Sab';
      case 7:
        return 'Min';
      default:
        return '';
    }
  }
}
