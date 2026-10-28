import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_exception.dart';
import '../models/achievement.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';

/// Result returned by the authoritative server-side completion transaction.
class CompletionResult {
  final bool success;
  final bool alreadyCompleted;
  final String completionId;
  final int xpAwarded;
  final int totalXp;
  final int currentLevel;
  final int currentStreak;
  final int longestStreak;
  final List<Achievement> unlockedAchievements;

  const CompletionResult({
    required this.success,
    required this.alreadyCompleted,
    required this.completionId,
    required this.xpAwarded,
    required this.totalXp,
    required this.currentLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.unlockedAchievements,
  });

  factory CompletionResult.fromJson(Map<String, dynamic> json) {
    final achievementsRaw = json['unlocked_achievements'] as List? ?? [];
    final unlocked = achievementsRaw
        .map((e) => Achievement.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return CompletionResult(
      success: json['success'] as bool? ?? false,
      alreadyCompleted: json['already_completed'] as bool? ?? false,
      completionId: json['completion_id']?.toString() ?? '',
      xpAwarded: (json['xp_awarded'] as num?)?.toInt() ?? 0,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 1,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      unlockedAchievements: unlocked,
    );
  }
}

/// Repository for habit operations and mission completions.
class HabitRepository {
  final SupabaseClient? _client;

  HabitRepository(this._client);

  /// Fetches all active (non-archived) habits for the user.
  Future<List<Habit>> fetchActiveHabits(String userId) async {
    _ensureClient();
    try {
      final response = await _client!
          .from('habits')
          .select()
          .eq('user_id', userId)
          .eq('is_archived', false)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((item) => Habit.fromJson(item as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException('Gagal memuat kebiasaan: ${e.message}',
          code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
          'Terjadi kendala saat membaca data kebiasaan: $e');
    }
  }

  /// Fetches all archived habits for the user.
  Future<List<Habit>> fetchArchivedHabits(String userId) async {
    _ensureClient();
    try {
      final response = await _client!
          .from('habits')
          .select()
          .eq('user_id', userId)
          .eq('is_archived', true)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((item) => Habit.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DatabaseException('Gagal memuat arsip kebiasaan: $e');
    }
  }

  /// Creates a new habit persistently.
  Future<Habit> createHabit(Habit habit) async {
    _ensureClient();
    try {
      final payload = habit.toJson()..remove('id');
      final response =
          await _client!.from('habits').insert(payload).select().single();

      return Habit.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Gagal membuat kebiasaan: ${e.message}',
          code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Gagal menyimpan kebiasaan: $e');
    }
  }

  /// Updates an existing habit.
  Future<Habit> updateHabit(Habit habit) async {
    _ensureClient();
    try {
      final payload = habit.toJson()..remove('id');
      payload['updated_at'] = DateTime.now().toUtc().toIso8601String();

      final response = await _client!
          .from('habits')
          .update(payload)
          .eq('id', habit.id)
          .eq('user_id', habit.userId)
          .select()
          .single();

      return Habit.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Gagal memperbarui kebiasaan: ${e.message}',
          code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Gagal menyimpan perubahan kebiasaan: $e');
    }
  }

  /// Archives a habit.
  Future<void> archiveHabit(String habitId, String userId) async {
    _ensureClient();
    try {
      await _client!
          .from('habits')
          .update({
            'is_archived': true,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', habitId)
          .eq('user_id', userId);
    } catch (e) {
      throw DatabaseException('Gagal mengarsipkan kebiasaan: $e');
    }
  }

  /// Unarchives / reactivates a habit.
  Future<void> unarchiveHabit(String habitId, String userId) async {
    _ensureClient();
    try {
      await _client!
          .from('habits')
          .update({
            'is_archived': false,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', habitId)
          .eq('user_id', userId);
    } catch (e) {
      throw DatabaseException('Gagal mengaktifkan kembali kebiasaan: $e');
    }
  }

  /// Deletes a habit permanently while keeping historical XP and stats intact.
  Future<void> deleteHabit(String habitId, String userId) async {
    _ensureClient();
    try {
      await _client!
          .from('habits')
          .delete()
          .eq('id', habitId)
          .eq('user_id', userId);
    } catch (e) {
      throw DatabaseException('Gagal menghapus kebiasaan: $e');
    }
  }

  /// Authoritative server-side completion transaction.
  /// Calls `complete_habit` PostgreSQL RPC function.
  Future<CompletionResult> completeHabit({
    required String habitId,
    required DateTime localDate,
  }) async {
    _ensureClient();
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(localDate);
      final response = await _client!.rpc(
        'complete_habit',
        params: {
          'p_habit_id': habitId,
          'p_local_date': dateStr,
        },
      );

      final Map<String, dynamic> data = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);

      return CompletionResult.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Gagal memproses penyelesaian misi: $e');
    }
  }

  /// Fetches completions for a user on a specific date.
  Future<List<HabitCompletion>> fetchCompletionsForDate(
    String userId,
    DateTime date,
  ) async {
    _ensureClient();
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _client!
          .from('habit_completions')
          .select()
          .eq('user_id', userId)
          .eq('completion_date', dateStr);

      return (response as List)
          .map((item) => HabitCompletion.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DatabaseException('Gagal memuat status misi hari ini: $e');
    }
  }

  /// Fetches completions within a date range for analytics and weekly chart.
  Future<List<HabitCompletion>> fetchCompletionsForRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _ensureClient();
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await _client!
          .from('habit_completions')
          .select()
          .eq('user_id', userId)
          .gte('completion_date', startStr)
          .lte('completion_date', endStr)
          .order('completion_date', ascending: true);

      return (response as List)
          .map((item) => HabitCompletion.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DatabaseException('Gagal memuat histori penyelesaian: $e');
    }
  }

  void _ensureClient() {
    if (_client == null) {
      throw const DatabaseException(
        'Supabase belum terkonfigurasi.',
        code: 'MISSING_CONFIG',
      );
    }
  }
}
