import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/theme_provider.dart';

/// A public marketing-site navigation item (anchor-scroll target).
class PublicNavItem {
  final String id;
  final String label;
  const PublicNavItem(this.id, this.label);
}

const publicNavItems = <PublicNavItem>[
  PublicNavItem('home', 'Home'),
  PublicNavItem('vitals', 'Risk Analyzer'),
  PublicNavItem('queue', 'Specialists & Queue'),
  PublicNavItem('blood', 'Emergency Blood'),
  PublicNavItem('blog', 'Health Blog'),
];

/// Sticky top navigation for the public site. Mirrors chrome.jsx
/// NavigationHeader: red heart logo, anchor nav links, theme toggle, and a
/// "Login Portal" button.
class PublicHeader extends ConsumerWidget {
  final String activeId;
  final ValueChanged<String> onNavTap;
  final VoidCallback onLogin;

  const PublicHeader({
    super.key,
    required this.activeId,
    required this.onNavTap,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final showNav = MediaQuery.of(context).size.width > 1080;

    return Container(
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      child: Row(
        children: [
          // Logo
          InkWell(
            onTap: () => onNavTap('home'),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, color: t.brandPrimary, size: 26),
                const SizedBox(width: 10),
                Text(
                  'NHCS AI',
                  style: GoogleFonts.outfit(
                    color: t.brandPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Nav links
          if (showNav)
            Row(
              children: [
                for (final item in publicNavItems)
                  _NavLink(
                    label: item.label,
                    active: activeId == item.id,
                    onTap: () => onNavTap(item.id),
                  ),
              ],
            ),
          const Spacer(),
          // Theme toggle
          InkWell(
            onTap: () => ref.read(themeModeProvider.notifier).toggle(),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.bgInput,
                shape: BoxShape.circle,
                border: Border.all(color: t.border),
              ),
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: t.brandPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Login Portal
          ElevatedButton(
            onPressed: onLogin,
            child: const Text('Login Portal'),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: active ? t.brandPrimary : t.textSecondary,
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 22,
                decoration: BoxDecoration(
                  color: active ? t.brandPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
