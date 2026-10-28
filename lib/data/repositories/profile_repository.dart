import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_profile.dart';

/// Repository for managing user profile and authoritative progress metrics.
class ProfileRepository {
  final SupabaseClient? _client;

  ProfileRepository(this._client);

  /// Fetches the profile for the authenticated user.
  Future<UserProfile> fetchProfile(String userId) async {
    _ensureClient();
    try {
      final response = await _client!
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // Automatically initialize profile if trigger hasn't fired yet
        return await initializeProfile(
          userId: userId,
          displayName: 'Teman One More',
        );
      }

      return UserProfile.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Gagal memuat profil: ${e.message}',
          code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Terjadi kendala saat membaca profil: $e');
    }
  }

  /// Initializes a profile record if missing.
  Future<UserProfile> initializeProfile({
    required String userId,
    required String displayName,
  }) async {
    _ensureClient();
    try {
      final name =
          displayName.trim().isNotEmpty ? displayName.trim() : 'Teman One More';

      final data = {
        'id': userId,
        'display_name': name,
        'total_xp': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'timezone': 'Asia/Jakarta',
      };

      try {
        final response =
            await _client!.from('profiles').upsert(data).select().single();
        return UserProfile.fromJson(response);
      } catch (_) {
        // Fallback: check if row was created by database trigger
        final existing = await _client!
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (existing != null) {
          return UserProfile.fromJson(existing);
        }
        // Fallback return local representation so UI is never blocked
        return UserProfile(
          id: userId,
          displayName: name,
          totalXp: 0,
          currentStreak: 0,
          longestStreak: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      throw DatabaseException('Gagal menginisialisasi profil: $e');
    }
  }

  /// Updates profile metadata (display name, avatar, timezone).
  Future<UserProfile> updateProfile({
    required String userId,
    required String displayName,
    String? avatarUrl,
    String? timezone,
  }) async {
    _ensureClient();
    try {
      final updates = <String, dynamic>{
        'display_name': displayName.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (timezone != null) updates['timezone'] = timezone;

      final response = await _client!
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Gagal memperbarui profil: ${e.message}',
          code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Terjadi kendala saat memperbarui profil: $e');
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
