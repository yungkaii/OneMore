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

      // Fallback canonical achievements if database has not been seeded yet
      final List<Map<String, dynamic>> rawList =
          (canonicalRes as List).isNotEmpty
              ? List<Map<String, dynamic>>.from(canonicalRes)
              : _fallbackCanonicalAchievements;

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

      return rawList.map((raw) {
        final ach = Achievement.fromJson(raw);
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

  static const List<Map<String, dynamic>> _fallbackCanonicalAchievements = [
    {
      'id': 'first_step',
      'title': 'Pemula',
      'description': 'Selesaikan kebiasaan pertama Anda.',
      'icon_name': 'military_tech',
      'xp_reward': 25,
      'target_type': 'total_completions',
      'target_value': 1,
    },
    {
      'id': 'getting_started',
      'title': 'Langkah Awal',
      'description': 'Raih total akumulasi 100 XP pertamamu.',
      'icon_name': 'stars',
      'xp_reward': 30,
      'target_type': 'total_xp',
      'target_value': 100,
    },
    {
      'id': 'three_in_a_row',
      'title': 'Tiga Hari Beruntun',
      'description': 'Pertahankan streak selama 3 hari berturut-turut.',
      'icon_name': 'local_fire_department',
      'xp_reward': 35,
      'target_type': 'streak_days',
      'target_value': 3,
    },
    {
      'id': 'full_week',
      'title': 'Konsisten',
      'description': 'Tuntaskan streak konsisten selama 7 hari berturut-turut.',
      'icon_name': 'verified',
      'xp_reward': 50,
      'target_type': 'streak_days',
      'target_value': 7,
    },
    {
      'id': 'consistent_10',
      'title': 'Produktif',
      'description': 'Selesaikan total 30 misi kebiasaan harian.',
      'icon_name': 'workspace_premium',
      'xp_reward': 40,
      'target_type': 'total_completions',
      'target_value': 30,
    },
    {
      'id': 'master_of_habit',
      'title': 'Master of Habit',
      'description': 'Raih Level 5 dengan total minimal 400 XP.',
      'icon_name': 'emoji_events',
      'xp_reward': 100,
      'target_type': 'level',
      'target_value': 5,
    },
  ];
}
