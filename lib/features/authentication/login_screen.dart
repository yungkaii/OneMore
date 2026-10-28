import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/env_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Successfully signed in; GoRouter redirect handles navigation to /home
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isConfigured = EnvConfig.isConfigured;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.stairs_rounded,
                          color: AppColors.accentGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.appName,
                        style: AppTypography.headlineMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.loginTitle,
                    style: AppTypography.headlineLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.loginSubtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Missing Supabase banner
                  if (!isConfigured) ...[
                    AppCard(
                      backgroundColor: AppColors.errorContainer,
                      borderColor: AppColors.error.withValues(alpha: 0.4),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.missingSupabaseConfig,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/setup-guide'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                            ),
                            child: const Text('Panduan'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Error message banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  AppTextField(
                    controller: _emailController,
                    label: AppStrings.emailLabel,
                    hint: AppStrings.emailHint,
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email wajib diisi.';
                      }
                      if (!val.contains('@') || !val.contains('.')) {
                        return 'Format email tidak valid.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  AppTextField(
                    controller: _passwordController,
                    label: AppStrings.passwordLabel,
                    hint: AppStrings.passwordHint,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Kata sandi wajib diisi.';
                      }
                      if (val.length < 6) {
                        return 'Kata sandi minimal 6 karakter.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/reset-password'),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit
                  AppButton(
                    label: AppStrings.loginAction,
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.noAccountPrompt,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(
                          AppStrings.registerAction,
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 14,
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
