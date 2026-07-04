import 'package:flutter/material.dart';

/// A single design-token set (mirrors the prototype's `TD` / `TL` objects in
/// system.jsx). Both a dark and a light instance are exposed via
/// [AppColors.dark] and [AppColors.light]; use [AppColors.of] to pick the
/// active set from the current [Theme] brightness.
class AppColorTokens {
  final Brightness brightness;
  final Color bgMain;
  final Color bgCard;
  final Color bgInput;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color brandPrimary;
  final Color brandSecondary;
  final Color success;
  final Color warning;
  final Color danger;

  const AppColorTokens({
    required this.brightness,
    required this.bgMain,
    required this.bgCard,
    required this.bgInput,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.brandPrimary,
    required this.brandSecondary,
    required this.success,
    required this.warning,
    required this.danger,
  });

  bool get isDark => brightness == Brightness.dark;
}

class AppColors {
  AppColors._();

  // ---- Shared shape tokens ----
  static const double radius = 16;
  static const double innerRadius = 12;

  // ---- Dark token set (default) — mirrors prototype TD ----
  static const AppColorTokens dark = AppColorTokens(
    brightness: Brightness.dark,
    bgMain: Color(0xFF0B0F19),
    bgCard: Color(0xFF131C2E),
    bgInput: Color(0xFF1B2640),
    border: Color(0xFF2A3A5A),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    brandPrimary: Color(0xFFEF4444),
    brandSecondary: Color(0xFFF87171),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
  );

  // ---- Light token set — mirrors prototype TL ----
  static const AppColorTokens light = AppColorTokens(
    brightness: Brightness.light,
    bgMain: Color(0xFFF8FAFC),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    brandPrimary: Color(0xFFDE3B3B),
    brandSecondary: Color(0xFFEF4444),
    success: Color(0xFF059669),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
  );

  /// Resolve the active token set for the current theme brightness.
  static AppColorTokens of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  // ---------------------------------------------------------------------------
  // Legacy static tokens (still referenced by the not-yet-restyled portals).
  // Brand-family colours are recoloured to the red/coral palette so existing
  // screens no longer render blue. These are progressively removed as portals
  // are restyled in later slices.
  // ---------------------------------------------------------------------------

  // Primary (Brand Red / Coral)
  static const Color primary = Color(0xFFEF4444);
  static const Color primaryDark = Color(0xFFDC2626);
  static const Color primaryLight = Color(0xFFFEE2E2);

  // Secondary (Soft Coral)
  static const Color secondary = Color(0xFFF87171);
  static const Color secondaryLight = Color(0xFFFEF2F2);

  // Accent (Clinical Red / Emergency Cross)
  static const Color accent = Color(0xFFDC2626);
  static const Color accentLight = Color(0xFFFEE2E2);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color sidebar = Color(0xFF0B0F19); // Dark navy sidebar
  static const Color sidebarHover = Color(0xFF131C2E);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFFF87171);
  static const Color infoLight = Color(0xFFFEE2E2);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E1);
}
