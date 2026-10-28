import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _showEditNameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama Panggilan'),
        content: Form(
          key: formKey,
          child: AppTextField(
            controller: controller,
            hint: 'Nama tampilan baru',
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Nama tidak boleh kosong.';
              }
              if (v.trim().length > 60) {
                return 'Maksimal 60 karakter.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (updated != null && updated != currentName) {
      try {
        await ref
            .read(profileNotifierProvider.notifier)
            .updateDisplayName(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nama berhasil diperbarui.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui nama: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
            'Anda perlu masuk kembali untuk mengakses data kebiasaan Anda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final profileAsync = ref.watch(profileNotifierProvider);
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final storage = ref.watch(storageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Avatar & Name Card
              profileAsync.when(
                data: (profile) {
                  final name = profile?.displayName ?? 'Teman One More';
                  final email = user?.email ?? 'Akun One More';

                  return AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              AppColors.accentGreen.withValues(alpha: 0.2),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'O',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.accentGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTypography.titleLarge.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Ubah Nama',
                          onPressed: () => _showEditNameDialog(name),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
              const SizedBox(height: 24),

              // Settings Section Header
              Text(
                AppStrings.settingsTitle,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Settings Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Theme Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppStrings.themePreference,
                              style: AppTypography.bodyLarge.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        DropdownButton<ThemeMode>(
                          value: themeMode,
                          underline: const SizedBox.shrink(),
                          dropdownColor: isDark
                              ? AppColors.darkSurfaceElevated
                              : AppColors.lightSurface,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Gelap'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Terang'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('Sistem'),
                            ),
                          ],
                          onChanged: (mode) {
                            if (mode != null) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setTheme(mode);
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Reminders Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.notifications_outlined,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      title: Text(
                        AppStrings.enableReminders,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      activeThumbColor: AppColors.accentGreen,
                      value: storage.remindersEnabled,
                      onChanged: (val) async {
                        await storage.setRemindersEnabled(val);
                        final notifService =
                            ref.read(notificationServiceProvider);
                        if (val) {
                          await notifService.requestPermission();
                        } else {
                          await notifService.cancelAll();
                        }
                        setState(() {});
                      },
                    ),
                    const Divider(height: 24),

                    // Achievements quick link
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.military_tech_outlined,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      title: Text(
                        AppStrings.navAchievements,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/achievements'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.tagline,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.version,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              AppButton(
                label: AppStrings.logoutAction,
                variant: AppButtonVariant.destructive,
                icon: Icons.logout_rounded,
                onPressed: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
