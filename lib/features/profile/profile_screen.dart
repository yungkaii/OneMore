import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
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
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ubah Profil',
          style: AppTypography.titleLarge
              .copyWith(color: AppColors.darkTextPrimary),
        ),
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
            child: const Text('Batal',
                style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Simpan',
                style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final storage = ref.watch(storageServiceProvider);
        final themeMode = ref.watch(themeModeProvider);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pengaturan Aplikasi',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette_outlined,
                              color: AppColors.darkTextSecondary, size: 20),
                          const SizedBox(width: 12),
                          Text('Tema Tampilan',
                              style: AppTypography.bodyMedium),
                        ],
                      ),
                      DropdownButton<ThemeMode>(
                        value: themeMode,
                        underline: const SizedBox.shrink(),
                        dropdownColor: AppColors.darkSurfaceElevated,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.darkTextPrimary),
                        items: const [
                          DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Gelap (Default)')),
                          DropdownMenuItem(
                              value: ThemeMode.light, child: Text('Terang')),
                          DropdownMenuItem(
                              value: ThemeMode.system, child: Text('Sistem')),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            ref.read(themeModeProvider.notifier).setTheme(mode);
                            Navigator.of(ctx).pop();
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.darkBorder, height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_outlined,
                        color: AppColors.darkTextSecondary, size: 20),
                    title: Text(AppStrings.enableReminders,
                        style: AppTypography.bodyMedium),
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
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Bantuan One More',
          style: AppTypography.titleLarge
              .copyWith(color: AppColors.darkTextPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'One more step. One more day. One more you.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aplikasi pelacak kebiasaan harian dengan gamifikasi yang membantu Anda konsisten setiap hari.\n\nJika ada pertanyaan atau kendala, hubungi kami di support@onemore.app.',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.darkTextSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar dari Akun?',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.darkTextPrimary)),
        content: Text(
          'Anda perlu masuk kembali untuk mengakses data kebiasaan Anda.',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
    final profileAsync = ref.watch(profileNotifierProvider);
    final user = ref.watch(currentUserProvider);
    final profile = profileAsync.valueOrNull;

    final displayName =
        (profile?.displayName != null && profile!.displayName.trim().isNotEmpty)
            ? profile.displayName
            : (user?.email?.split('@').first ?? 'Yukafii');
    final level = profile?.currentLevel ?? 5;
    final currentXp = profile != null ? profile.xpInCurrentLevel : 320;
    final xpForNextLevel = profile != null ? profile.xpRequiredForNextLevel : 500;
    final xpRatio =
        (currentXp / (xpForNextLevel > 0 ? xpForNextLevel : 1)).clamp(0.0, 1.0);

    final currentStreak = profile?.currentStreak ?? 7;
    const completedMissionsCount = 18;
    const unlockedAchievementsCount = 3;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Mountain Backdrop Header with Avatar
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Mountain Landscape Silhouette Canvas
                CustomPaint(
                  size: const Size(double.infinity, 220),
                  painter: _ProfileMountainPainter(),
                ),

                // Top Safe Area Bar
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Text(
                          'Profil',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined,
                              color: AppColors.darkTextSecondary),
                          onPressed: _showSettingsModal,
                        ),
                      ],
                    ),
                  ),
                ),

                // Avatar Container
                Positioned(
                  top: 130,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.darkSurfaceElevated, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: const Color(0xFF1B2332),
                            child: CustomPaint(
                              painter: _AvatarIllustrationPainter(),
                            ),
                          ),
                        ),
                      ),
                      // Verified Green Checkmark Badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.darkBackground, width: 2.5),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Content below avatar
            const SizedBox(height: 24),
            Text(
              displayName,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Level & XP Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lv. $level',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$currentXp / $xpForNextLevel XP',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: xpRatio,
                      backgroundColor: AppColors.darkSurfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accentGreen),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3-Column Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AppColors.darkBorder.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    // Streak
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/streak'),
                        child: Column(
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                color: AppColors.accentStreak, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              '$currentStreak',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Streak',
                              style: AppTypography.labelSmall
                                  .copyWith(color: AppColors.darkTextTertiary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 36, width: 1, color: AppColors.darkBorder),
                    // Misi Selesai
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/progress'),
                        child: Column(
                          children: [
                            const Icon(Icons.assignment_turned_in_rounded,
                                color: AppColors.accentGreen, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              '$completedMissionsCount',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Misi Selesai',
                              style: AppTypography.labelSmall
                                  .copyWith(color: AppColors.darkTextTertiary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 36, width: 1, color: AppColors.darkBorder),
                    // Achievement
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/achievements'),
                        child: Column(
                          children: [
                            const Icon(Icons.emoji_events_rounded,
                                color: AppColors.gold, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              '$unlockedAchievementsCount',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Achievement',
                              style: AppTypography.labelSmall
                                  .copyWith(color: AppColors.darkTextTertiary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Motivational Quote Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.darkBorder.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '"Bukan tentang seberapa cepat,\ntapi tentang seberapa konsisten."',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Menu List Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profil',
                      onTap: () => _showEditNameDialog(displayName),
                    ),
                    const Divider(
                        color: AppColors.darkBorder,
                        height: 1,
                        indent: 56,
                        endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan',
                      onTap: _showSettingsModal,
                    ),
                    const Divider(
                        color: AppColors.darkBorder,
                        height: 1,
                        indent: 56,
                        endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Bantuan',
                      onTap: _showHelpDialog,
                    ),
                    const Divider(
                        color: AppColors.darkBorder,
                        height: 1,
                        indent: 56,
                        endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Keluar',
                      iconColor: AppColors.error,
                      textColor: AppColors.error,
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? AppColors.darkTextSecondary,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: textColor ?? AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.darkTextTertiary,
      ),
      onTap: onTap,
    );
  }
}

/// Custom painter for the atmospheric mountain backdrop on Profile screen
class _ProfileMountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F141F),
          Color(0xFF1A2333),
          Color(0xFF131A26),
          Color(0xFF0B0E14),
        ],
        stops: [0.0, 0.45, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Subtle stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    final stars = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.28, size.height * 0.12),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.72, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.28),
      Offset(size.width * 0.38, size.height * 0.32),
    ];
    for (final s in stars) {
      canvas.drawCircle(s, 1.2, starPaint);
    }

    // Distant mountain layer
    final mountainDistantPaint = Paint()..color = const Color(0xFF141C2A);
    final distantPath = Path()
      ..moveTo(0, size.height * 0.65)
      ..lineTo(size.width * 0.2, size.height * 0.45)
      ..lineTo(size.width * 0.4, size.height * 0.6)
      ..lineTo(size.width * 0.65, size.height * 0.42)
      ..lineTo(size.width * 0.85, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.48)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(distantPath, mountainDistantPaint);

    // Near mountain layer
    final mountainNearPaint = Paint()..color = const Color(0xFF0B0E14);
    final nearPath = Path()
      ..moveTo(0, size.height * 0.78)
      ..lineTo(size.width * 0.25, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.75, size.height * 0.58)
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(nearPath, mountainNearPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Anime-inspired silhouette avatar painter matching the mockup
class _AvatarIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF222B3B);
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, bgPaint);

    // Warm dusk backdrop glow behind head
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE07A5F).withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.4), radius: 32));
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.4), 32, glowPaint);

    // Hair silhouette & Face
    final facePaint = Paint()..color = const Color(0xFFFFDFC4);
    // Draw face oval
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.52),
        width: size.width * 0.42,
        height: size.height * 0.44,
      ),
      facePaint,
    );

    // Anime dark hair path
    final hairPaint = Paint()..color = const Color(0xFF1E1F2A);
    final hairPath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.25,
          size.width * 0.5, size.height * 0.22)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.25,
          size.width * 0.78, size.height * 0.55)
      // hair tufts
      ..lineTo(size.width * 0.72, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.5)
      ..lineTo(size.width * 0.58, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.48)
      ..lineTo(size.width * 0.42, size.height * 0.42)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.28, size.height * 0.45)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Dark collar / shoulders
    final bodyPaint = Paint()..color = const Color(0xFF141923);
    final bodyPath = Path()
      ..moveTo(size.width * 0.2, size.height)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.76, size.width * 0.8, size.height)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
