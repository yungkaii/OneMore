import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight persistent local storage service for non-sensitive preferences.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyOnboardingDone = 'has_completed_onboarding';
  static const String _keyThemeMode =
      'app_theme_mode'; // 'dark', 'light', 'system'
  static const String _keyRemindersEnabled = 'reminders_enabled';
  static const String _keyTimezone = 'app_preferred_timezone';

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_keyOnboardingDone) ?? false;

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_keyOnboardingDone, value);
  }

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'dark';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  bool get remindersEnabled => _prefs.getBool(_keyRemindersEnabled) ?? true;

  Future<void> setRemindersEnabled(bool enabled) async {
    await _prefs.setBool(_keyRemindersEnabled, enabled);
  }

  String get preferredTimezone =>
      _prefs.getString(_keyTimezone) ?? 'Asia/Jakarta';

  Future<void> setPreferredTimezone(String tz) async {
    await _prefs.setString(_keyTimezone, tz);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
