import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_exception.dart';
import '../models/achievement.dart';

/// Repository for viewing canonical achievements and personal unlocked status.
class AchievementRepository {
  final SupabaseClient? _client;

  AchievementRepository(this._client);

  /// Fetches all canonical achievements with the user's unlocked status.
  Future<List<Achievement>> fetchAchievements(String userId) async {
    _ensureClient();
    final client = _client!;
    try {
      // 1. Fetch all canonical achievements
      final canonicalRes = await client
          .from('achievements')
          .select()
          .order('target_value', ascending: true);

      // 2. Fetch user's unlocked achievements
      final userUnlockedRes = await client
          .from('user_achievements')
          .select('achievement_id, unlocked_at')
          .eq('user_id', userId);

      final Map<String, DateTime> unlockedMap = {};
      for (final item in (userUnlockedRes as List)) {
        final achId = item['achievement_id'] as String;
        final date = DateTime.tryParse(item['unlocked_at'].toString());
        if (date != null) unlockedMap[achId] = date;
      }

      return (canonicalRes as List).map((raw) {
        final ach = Achievement.fromJson(raw as Map<String, dynamic>);
        return ach.copyWith(unlockedAt: unlockedMap[ach.id]);
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException('Gagal memuat daftar pencapaian: ${e.message}',
          code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Terjadi kendala saat memuat pencapaian: $e');
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
