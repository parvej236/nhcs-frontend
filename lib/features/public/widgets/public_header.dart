import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
// import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/l10n/app_language.dart';

/// A public marketing-site navigation item (anchor-scroll target). [labelKey]
/// is a translation key resolved against the active language at build time.
class PublicNavItem {
  final String id;
  final String labelKey;
  const PublicNavItem(this.id, this.labelKey);
}

const publicNavItems = <PublicNavItem>[
  PublicNavItem('home', 'nav_home'),
  PublicNavItem('vitals', 'nav_vitals'),
  PublicNavItem('queue', 'nav_queue'),
  PublicNavItem('blood', 'nav_blood'),
  PublicNavItem('blog', 'nav_blog'),
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
    // final themeMode = ref.watch(themeModeProvider);
    final tr = ref.watch(translationsProvider);
    // final isDark = themeMode == ThemeMode.dark;
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
                    label: tr(item.labelKey),
                    active: activeId == item.id,
                    onTap: () => onNavTap(item.id),
                  ),
              ],
            ),
          const Spacer(),
          // Language switcher (sits right beside the theme toggle)
          const LanguageSwitcher(),
          /*
          const SizedBox(width: 12),
          // Theme toggle (Commented out for future implementation)
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
          */
          const SizedBox(width: 16),
          // Login Portal
          ElevatedButton(
            onPressed: onLogin,
            child: Text(tr('login_portal')),
          ),
        ],
      ),
    );
  }
}

/// A compact language switcher pill designed to sit beside the theme toggle.
///
/// Tapping opens a menu of every [AppLanguage]; the choice is applied globally
/// and persisted immediately via [languageProvider]. Reusable anywhere in the
/// app (not just the public header).
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final current = ref.watch(languageProvider);

    return PopupMenuButton<AppLanguage>(
      tooltip: ref.watch(translationsProvider)('language'),
      onSelected: (lang) =>
          ref.read(languageProvider.notifier).setLanguage(lang),
      offset: const Offset(0, 48),
      color: t.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.border),
      ),
      itemBuilder: (context) => [
        for (final lang in AppLanguage.values)
          PopupMenuItem<AppLanguage>(
            value: lang,
            child: Row(
              children: [
                Icon(
                  lang == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: lang == current ? t.brandPrimary : t.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  lang.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight:
                        lang == current ? FontWeight.w700 : FontWeight.w500,
                    color: lang == current ? t.brandPrimary : t.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: t.bgInput,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate, color: t.brandPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              current.short,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.brandPrimary,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: t.textSecondary, size: 18),
          ],
        ),
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
