import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/config/env_config.dart';
import 'core/providers/app_providers.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local persistent preferences
  final sharedPrefs = await SharedPreferences.getInstance();
  final storageService = StorageService(sharedPrefs);

  // 2. Initialize local notifications & timezone
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 3. Initialize Supabase if configuration is supplied
  if (EnvConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  } else {
    debugPrint(
      'Notice: Supabase credentials not found. Run with --dart-define-from-file=config.json or view the setup guide.',
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const OneMoreApp(),
    ),
  );
}
