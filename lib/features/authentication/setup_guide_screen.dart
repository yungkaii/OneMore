import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';

/// Screen displayed when Supabase credentials have not been configured.
/// Strictly conforms to requirement: "If Supabase credentials have not been configured,
/// show an explicit setup state and document how to configure the application."
class SetupGuideScreen extends StatelessWidget {
  const SetupGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfigurasi Backend'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        color: AppColors.error, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.missingSupabaseConfig,
                            style: AppTypography.titleMedium
                                .copyWith(color: AppColors.error),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Koneksi ke Supabase diperlukan untuk autentikasi dan sinkronisasi data riil.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.error.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Langkah Pengaturan Supabase:',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildStepCard(
                step: '1',
                title: 'Buat Project di Supabase',
                description:
                    'Buka dashboard https://supabase.com dan buat project baru.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildStepCard(
                step: '2',
                title: 'Jalankan SQL Migration',
                description:
                    'Buka menu SQL Editor di Supabase, lalu jalankan file migration yang tersedia di folder:\n`supabase/migrations/20261028000000_init_onemore_schema.sql`',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildStepCard(
                step: '3',
                title: 'Salin URL & Anon Key',
                description:
                    'Salin `Project URL` dan `Project API Anon Key` dari menu Settings -> API.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildStepCard(
                step: '4',
                title: 'Jalankan dengan Konfigurasi',
                description:
                    'Buat file `config.json` berdasarkan `config.example.json`, lalu jalankan aplikasi menggunakan:\n`flutter run --dart-define-from-file=config.json`',
                isDark: isDark,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Kembali',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: AppTypography.statNumberSmall.copyWith(
                color: AppColors.accentGreen,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
