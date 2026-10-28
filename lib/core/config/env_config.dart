/// Environment configuration for One More.
/// Reads configuration passed via `--dart-define` or `--dart-define-from-file`.
class EnvConfig {
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Default application timezone.
  static const String defaultTimezone = String.fromEnvironment(
    'APP_TIMEZONE',
    defaultValue: 'Asia/Jakarta',
  );

  /// Checks if valid Supabase credentials have been injected.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl.startsWith('https://');
}

