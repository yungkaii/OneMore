import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../core/errors/app_exception.dart';

/// Repository handling authentication lifecycle using Supabase Auth.
class AuthRepository {
  final SupabaseClient? _client;

  AuthRepository(this._client);

  bool get isAvailable => _client != null;

  User? get currentUser => _client?.auth.currentUser;

  Session? get currentSession => _client?.auth.currentSession;

  Stream<AuthState> get authStateChanges {
    final client = _client;
    if (client == null) {
      return const Stream.empty();
    }
    return client.auth.onAuthStateChange;
  }

  /// Sign up with email, password, and optional display name.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _ensureClient();
    try {
      final response = await _client!.auth.signUp(
        email: email.trim(),
        password: password,
        data: displayName != null && displayName.trim().isNotEmpty
            ? {'display_name': displayName.trim()}
            : null,
      );
      return response;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message), code: e.statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Gagal mendaftar akun: ${e.toString()}');
    }
  }

  /// Sign in with email and password.
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _ensureClient();
    try {
      final response = await _client!.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message), code: e.statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Gagal masuk ke akun: ${e.toString()}');
    }
  }

  /// Send password reset link to user email.
  Future<void> resetPasswordForEmail(String email) async {
    _ensureClient();
    try {
      await _client!.auth.resetPasswordForEmail(email.trim());
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message), code: e.statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Gagal mengirim tautan reset: ${e.toString()}');
    }
  }

  /// Sign out current session.
  Future<void> signOut() async {
    _ensureClient();
    try {
      await _client!.auth.signOut();
    } catch (e) {
      throw AuthException('Gagal keluar akun: ${e.toString()}');
    }
  }

  void _ensureClient() {
    if (_client == null) {
      throw const AuthException(
        'Supabase belum dikonfigurasi. Silakan lengkapi konfigurasi URL dan anon key.',
        code: 'MISSING_CONFIG',
      );
    }
  }

  /// Translates common Supabase auth error messages to friendly Indonesian.
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Email atau kata sandi tidak cocok. Periksa kembali masukan Anda.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already exists')) {
      return 'Email ini sudah terdaftar. Silakan masuk atau gunakan email lain.';
    }
    if (lower.contains('password should be at least')) {
      return 'Kata sandi minimal harus 6 karakter.';
    }
    if (lower.contains('invalid email')) {
      return 'Format alamat email tidak valid.';
    }
    if (lower.contains('rate limit')) {
      return 'Terlalu banyak permintaan. Silakan tunggu beberapa saat.';
    }
    return message;
  }
}
