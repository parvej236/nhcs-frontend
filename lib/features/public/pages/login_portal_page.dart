import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/widgets/app_primitives.dart';

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
      _showError('Please fill out all required fields');
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
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

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
                      _BackToHomeChip(onTap: () => context.go('/')),
                      const Spacer(),
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
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Responsive two-column / stacked layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 860;
                      final brand = _BrandPanel(t: t);
                       final card = _AuthCard(
                        t: t,
                        isRegister: _isRegister,
                        isLoading: _isLoading,
                        usernameController: _usernameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        fullNameController: _fullNameController,
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
  const _BackToHomeChip({required this.onTap});

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
              'Back to Home',
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
  const _BrandPanel({required this.t});

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
              'NHCS Portal',
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
          'Access Your Centralized Health Registries',
          style: GoogleFonts.outfit(
            color: t.textPrimary,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Log in to manage appointments, issue clinical prescriptions, '
          'provide laboratory evaluations, and view electronic health vault '
          'registries.',
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
          text: 'Secure health vault records',
        ),
        const SizedBox(height: 14),
        _BrandBullet(
          t: t,
          icon: Icons.monitor_heart_outlined,
          text: 'Live clinical analytics sync for patients and doctors',
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
  final bool isRegister;
  final bool isLoading;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;
  final ValueChanged<bool> onTab;
  final VoidCallback onSubmit;

  const _AuthCard({
    required this.t,
    required this.isRegister,
    required this.isLoading,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.fullNameController,
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
                  label: 'Sign In',
                  active: !isRegister,
                  onTap: () => onTab(false),
                ),
                const SizedBox(width: 20),
                _Tab(
                  t: t,
                  label: 'Register',
                  active: isRegister,
                  onTap: () => onTab(true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (isRegister) ...[
            AppInput(
              label: 'Full Name',
              hint: 'Nehal Ahmmed',
              controller: fullNameController,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Email Address',
              hint: 'nehal@gmail.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Username',
              hint: 'Choose username',
              controller: usernameController,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Password',
              hint: 'Create password',
              controller: passwordController,
              obscureText: true,
            ),
          ] else ...[
            AppInput(
              label: 'Username',
              hint: 'e.g. patient',
              controller: usernameController,
              suffix: PopupMenuButton<String>(
                icon: Icon(Icons.arrow_drop_down_rounded, color: t.textSecondary),
                tooltip: 'Select Demo User',
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
              label: 'Password',
              hint: '••••••••',
              controller: passwordController,
              obscureText: true,
            ),
          ],
          const SizedBox(height: 22),
          AppButton(
            label: isLoading
                ? (isRegister ? 'Registering…' : 'Signing In…')
                : (isRegister
                    ? 'Register Health Profile'
                    : 'Sign In to Portal'),
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
