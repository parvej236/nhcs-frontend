import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dio_provider.dart';
// import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/widgets/app_primitives.dart';
import '../widgets/public_header.dart' show LanguageSwitcher;

/// The themed authentication portal served at `/login`. Mirrors the prototype
/// LoginPortal: a "Back to Home" chip, a left brand panel, and a right card
/// with a Sign In / Register tab switcher. Patient self-register only; Doctor /
/// Hospital accounts are seeded and reachable via the quick demo-login buttons.
class LoginPortalPage extends ConsumerStatefulWidget {
  const LoginPortalPage({super.key});

  @override
  ConsumerState<LoginPortalPage> createState() => _LoginPortalPageState();
}

class _LoginPortalPageState extends ConsumerState<LoginPortalPage> {
  bool _isRegister = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _usernameController = TextEditingController(text: 'patient_judge');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: 'password123');
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  /// Chooses a sensible default active role: prefer an elevated role, else
  /// fall back to PATIENT. Multi-role users can still switch via the sidebar
  /// WorkspaceSwitcher afterwards.
  String _defaultRole(List<String> roles) {
    if (roles.contains('HOSPITAL')) return 'HOSPITAL';
    if (roles.contains('DOCTOR')) return 'DOCTOR';
    if (roles.contains('PATIENT')) return 'PATIENT';
    return roles.isNotEmpty ? roles.first : 'PATIENT';
  }

  String _routeForRole(String role) {
    switch (role) {
      case 'PATIENT':
        return '/user';
      case 'DOCTOR':
        return '/doctor';
      case 'HOSPITAL':
        return '/authority';
      default:
        return '/';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    final t = AppColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: t.danger),
    );
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final email = _emailController.text.trim();
    final fullName = _fullNameController.text.trim();

    if (username.isEmpty ||
        password.isEmpty ||
        (_isRegister && (email.isEmpty || fullName.isEmpty))) {
      _showError(ref.read(translationsProvider)('auth_err_fill_fields'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        _isRegister ? ApiEndpoints.register : ApiEndpoints.login,
        data: _isRegister
            ? {
                'username': username,
                'email': email,
                'password': password,
                'fullName': fullName,
                'role': 'PATIENT', // patient self-register only
              }
            : {
                'username': username,
                'password': password,
              },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final roles = List<String>.from(data['roles'] as List);
      // A fresh registration is always a patient.
      final activeRole = _isRegister ? 'PATIENT' : _defaultRole(roles);

      await ref.read(authProvider.notifier).login(
            token,
            'refresh_token_not_provided',
            activeRole,
            roles,
          );

      if (mounted) {
        context.go(_routeForRole(ref.read(authProvider).role ?? activeRole));
      }
    } catch (e) {
      var message = 'Authentication failed';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        } else {
          message = e.message ?? message;
        }
      }
      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    // final themeMode = ref.watch(themeModeProvider);
    // final isDark = themeMode == ThemeMode.dark;
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: t.bgMain,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar: Back to Home + theme toggle
                  Row(
                    children: [
                      _BackToHomeChip(onTap: () => context.go('/'), tr: tr),
                      const Spacer(),
                      const LanguageSwitcher(),
                      /*
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () =>
                            ref.read(themeModeProvider.notifier).toggle(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: t.bgInput,
                            shape: BoxShape.circle,
                            border: Border.all(color: t.border),
                          ),
                          child: Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: t.brandPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      */
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Responsive two-column / stacked layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 860;
                      final brand = _BrandPanel(t: t, tr: tr);
                      final card = _AuthCard(
                        t: t,
                        tr: tr,
                        isRegister: _isRegister,
                        isLoading: _isLoading,
                        usernameController: _usernameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        fullNameController: _fullNameController,
                        obscurePassword: _obscurePassword,
                        onToggleObscure: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        onTab: (register) =>
                            setState(() => _isRegister = register),
                        onSubmit: _submit,
                      );

                      if (!wide) {
                        return Column(
                          children: [
                            brand,
                            const SizedBox(height: 36),
                            card,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: brand),
                          const SizedBox(width: 56),
                          Expanded(flex: 5, child: card),
                        ],
                      );
                    },
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

class _BackToHomeChip extends StatelessWidget {
  final VoidCallback onTap;
  final AppTranslations tr;
  const _BackToHomeChip({required this.onTap, required this.tr});

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: t.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, size: 16, color: t.textPrimary),
            const SizedBox(width: 8),
            Text(
              tr('auth_back_home'),
              style: GoogleFonts.inter(
                color: t.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  final AppColorTokens t;
  final AppTranslations tr;
  const _BrandPanel({required this.t, required this.tr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: t.brandPrimary, size: 30),
            const SizedBox(width: 10),
            Text(
              tr('auth_portal_title'),
              style: GoogleFonts.outfit(
                color: t.brandPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          tr('auth_brand_heading'),
          style: GoogleFonts.outfit(
            color: t.textPrimary,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          tr('auth_brand_subtitle'),
          style: GoogleFonts.inter(
            color: t.textSecondary,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        _BrandBullet(
          t: t,
          icon: Icons.favorite_border,
          text: tr('auth_bullet_vault'),
        ),
        const SizedBox(height: 14),
        _BrandBullet(
          t: t,
          icon: Icons.monitor_heart_outlined,
          text: tr('auth_bullet_analytics'),
        ),
      ],
    );
  }
}

class _BrandBullet extends StatelessWidget {
  final AppColorTokens t;
  final IconData icon;
  final String text;
  const _BrandBullet({required this.t, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: t.brandPrimary, size: 18),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  final AppColorTokens t;
  final AppTranslations tr;
  final bool isRegister;
  final bool isLoading;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool> onTab;
  final VoidCallback onSubmit;

  const _AuthCard({
    required this.t,
    required this.tr,
    required this.isRegister,
    required this.isLoading,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.fullNameController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onTab,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab switcher
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: t.border, width: 2)),
            ),
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                _Tab(
                  t: t,
                  label: tr('auth_tab_signin'),
                  active: !isRegister,
                  onTap: () => onTab(false),
                ),
                const SizedBox(width: 20),
                _Tab(
                  t: t,
                  label: tr('auth_tab_register'),
                  active: isRegister,
                  onTap: () => onTab(true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (isRegister) ...[
            AppInput(
              label: tr('auth_field_full_name'),
              hint: 'Nehal Ahmmed',
              controller: fullNameController,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: tr('auth_field_email'),
              hint: 'nehal@gmail.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: tr('auth_field_username'),
              hint: tr('auth_hint_choose_username'),
              controller: usernameController,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: tr('auth_field_password'),
              hint: tr('auth_hint_create_password'),
              controller: passwordController,
              obscureText: obscurePassword,
              suffix: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: t.textSecondary,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
            ),
          ] else ...[
            AppInput(
              label: tr('auth_field_username'),
              hint: tr('auth_hint_username_example'),
              controller: usernameController,
              suffix: PopupMenuButton<String>(
                icon: Icon(Icons.arrow_drop_down_rounded, color: t.textSecondary),
                tooltip: tr('auth_select_demo_user'),
                onSelected: (val) {
                  usernameController.text = val;
                  passwordController.text = 'password123';
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('JUDGE CHECKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent)),
                  ),
                  const PopupMenuItem(value: 'patient_judge', child: Text('patient_judge (Judge Check Patient - Laila Khan)')),
                  const PopupMenuItem(value: 'doctor_judge', child: Text('doctor_judge (Judge Check Doctor - Dr. Rahim Chowdhury)')),
                  const PopupMenuItem(value: 'hospital_judge', child: Text('hospital_judge (Judge Check Medical - Dhaka Medical)')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('DEVELOPERS & ADMINS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                  ),
                  const PopupMenuItem(value: 'nehal', child: Text('nehal (Developer)')),
                  const PopupMenuItem(value: 'admin', child: Text('admin (Admin)')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppInput(
              label: tr('auth_field_password'),
              hint: '••••••••',
              controller: passwordController,
              obscureText: obscurePassword,
              suffix: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: t.textSecondary,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
            ),
          ],
          const SizedBox(height: 22),
          AppButton(
            label: isLoading
                ? (isRegister ? tr('auth_btn_registering') : tr('auth_btn_signing_in'))
                : (isRegister
                    ? tr('auth_btn_register')
                    : tr('auth_btn_signin')),
            expand: true,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final AppColorTokens t;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({
    required this.t,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? t.brandPrimary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: active ? t.brandPrimary : t.textSecondary,
          ),
        ),
      ),
    );
  }
}
