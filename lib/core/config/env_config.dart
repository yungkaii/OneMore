/// Environment configuration for One More.
/// Reads configuration passed via `--dart-define` or `--dart-define-from-file`,
/// with fallback to configured project credentials.
class EnvConfig {
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rcnxgvaewulcotnqzmjp.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjbnhndmFld3VsY290bnF6bWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMxODM5OTEsImV4cCI6MjEwODc1OTk5MX0.zDG3LJYojmwk_t1ecvWjOLFaU2WwmOCnWkurq4L3TKY',
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
