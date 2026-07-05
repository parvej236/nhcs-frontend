import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/dio_provider.dart';
import '../network/api_endpoints.dart';
import '../utils/constants.dart';

/// A single seeded "judge" account used for quick, one-tap role switching
/// during the demo / evaluation phase.
class _JudgeAccount {
  final String username;
  final String role; // AppConstants.role*
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;

  const _JudgeAccount({
    required this.username,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });
}

const List<_JudgeAccount> _judgeAccounts = [
  _JudgeAccount(
    username: 'patient_judge',
    role: AppConstants.rolePatient,
    title: 'Patient — Laila Khan',
    subtitle: 'Citizen workspace',
    route: '/user',
    icon: Icons.person_rounded,
  ),
  _JudgeAccount(
    username: 'doctor_judge',
    role: AppConstants.roleDoctor,
    title: 'Doctor — Dr. Rahim Chowdhury',
    subtitle: 'Doctor console',
    route: '/doctor',
    icon: Icons.medical_services_rounded,
  ),
  _JudgeAccount(
    username: 'hospital_judge',
    role: AppConstants.roleHospital,
    title: 'Hospital — Dhaka Medical',
    subtitle: 'Hospital authority',
    route: '/authority',
    icon: Icons.local_hospital_rounded,
  ),
];

/// Demo-only sidebar control that lets an evaluator log directly into any of the
/// seeded judge accounts from within an already-authenticated portal.
///
/// It performs a *real* login (mints a fresh JWT for the target role) and only
/// then navigates, so the existing [RouteGuards] pass legitimately — no route
/// guard is bypassed or weakened.
///
/// Set [forceDark] on the always-dark doctor/hospital sidebars; leave it false
/// for the theme-aware patient sidebar.
class JudgeRoleSwitcher extends ConsumerStatefulWidget {
  final bool forceDark;

  const JudgeRoleSwitcher({super.key, this.forceDark = false});

  @override
  ConsumerState<JudgeRoleSwitcher> createState() => _JudgeRoleSwitcherState();
}

class _JudgeRoleSwitcherState extends ConsumerState<JudgeRoleSwitcher> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _link = LayerLink();
  bool _expanded = false;
  String? _loadingUsername; // username currently signing in, if any

  AppColorTokens get _t =>
      widget.forceDark ? AppColors.dark : AppColors.of(context);

  Future<void> _loginAs(_JudgeAccount account) async {
    if (_loadingUsername != null) return;
    setState(() => _loadingUsername = account.username);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'username': account.username, 'password': 'password123'},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final roles = List<String>.from(data['roles'] as List);
      // Prefer the account's intended role; fall back to whatever it actually has.
      final activeRole = roles.contains(account.role)
          ? account.role
          : (roles.isNotEmpty ? roles.first : account.role);

      await ref.read(authProvider.notifier).login(
            token,
            'refresh_token_not_provided',
            activeRole,
            roles,
          );

      if (!mounted) return;
      setState(() {
        _loadingUsername = null;
        _expanded = false;
        _overlayController.hide();
      });
      // Navigate after auth state is set so the guard allows the target route.
      context.go(account.route);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingUsername = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Judge login failed for ${account.username}'),
          backgroundColor: _t.danger,
        ),
      );
    }
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _overlayController.show();
      } else {
        _overlayController.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final onDark = widget.forceDark;
    final labelColor = onDark ? Colors.white : t.textPrimary;
    final mutedColor = onDark ? Colors.white70 : t.textSecondary;
    final borderColor =
        onDark ? Colors.white.withValues(alpha: 0.15) : t.border;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 4),
            child: Align(
              alignment: Alignment.topLeft,
              child: TapRegion(
                onTapOutside: (event) {
                  setState(() {
                    _expanded = false;
                    _overlayController.hide();
                  });
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 228, // Matches sidebar width (260) minus margins
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.forceDark ? const Color(0xFF1E293B) : t.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'For judges test use',
                          style: GoogleFonts.inter(
                            color: t.brandPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Log in to another role directly',
                          style: GoogleFonts.inter(
                            color: mutedColor,
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._judgeAccounts.map(
                          (acc) => _JudgeTile(
                            account: acc,
                            labelColor: labelColor,
                            mutedColor: mutedColor,
                            brand: t.brandPrimary,
                            loading: _loadingUsername == acc.username,
                            disabled: _loadingUsername != null,
                            onTap: () => _loginAs(acc),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: onDark ? Colors.white.withValues(alpha: 0.05) : t.bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.science_outlined, color: t.brandPrimary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Judge Login',
                      style: GoogleFonts.inter(
                        color: labelColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: mutedColor, size: 20),
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

class _JudgeTile extends StatelessWidget {
  final _JudgeAccount account;
  final Color labelColor;
  final Color mutedColor;
  final Color brand;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _JudgeTile({
    required this.account,
    required this.labelColor,
    required this.mutedColor,
    required this.brand,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (disabled && !loading) ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Icon(account.icon, color: brand, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.title,
                        style: GoogleFonts.inter(
                          color: labelColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${account.username} · ${account.subtitle}',
                        style: GoogleFonts.inter(
                          color: mutedColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (loading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(brand),
                    ),
                  )
                else
                  Icon(Icons.login_rounded, color: mutedColor, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
