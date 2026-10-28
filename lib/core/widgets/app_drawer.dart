import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../widgets/app_logo.dart';
import '../widgets/reward_dialogs.dart';

class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({super.key, this.currentRoute = '/home'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.darkSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header with App Logo & Name matching "Menu Samping"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  const AppLogo(size: 32, showText: false, showTagline: false),
                  const SizedBox(width: 12),
                  Text(
                    'One More',
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.darkBorder, height: 1),
            const SizedBox(height: 16),

            // Navigation Items
            _buildDrawerTile(
              context,
              icon: Icons.home_rounded,
              title: 'Beranda',
              isActive: currentRoute == '/home',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.checklist_rounded,
              title: 'Misi',
              isActive:
                  currentRoute == '/missions' || currentRoute == '/habits',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/missions');
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.bar_chart_rounded,
              title: 'Statistik',
              isActive: currentRoute == '/progress',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/progress');
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.emoji_events_rounded,
              title: 'Achievement',
              isActive: currentRoute == '/achievements',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/achievements');
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              isActive: currentRoute == '/profile',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/profile');
              },
            ),

            const Spacer(),

            // Demo Actions for Reward Modals
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.stars_rounded, size: 18),
                    label: const Text('Cek Achievement Baru',
                        style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      RewardDialogs.showAchievementUnlockedDialog(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentGreen,
                      side: BorderSide(
                          color: AppColors.accentGreen.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.military_tech_rounded, size: 18),
                    label: const Text('Cek Level Up!',
                        style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      RewardDialogs.showLevelUpDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive
            ? AppColors.accentGreen.withValues(alpha: 0.15)
            : Colors.transparent,
        leading: Icon(
          icon,
          color: isActive ? AppColors.accentGreen : AppColors.darkTextSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            color: isActive ? AppColors.accentGreen : AppColors.darkTextPrimary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
