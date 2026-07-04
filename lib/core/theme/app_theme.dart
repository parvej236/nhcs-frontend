import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _themeFrom(AppColors.light);

  static ThemeData get darkTheme => _themeFrom(AppColors.dark);

  /// Builds a Material 3 [ThemeData] from a token set so both themes stay in
  /// lock-step with the design system (Inter body + Outfit display, cards
  /// radius 16, buttons/inputs radius 12).
  static ThemeData _themeFrom(AppColorTokens t) {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: t.brightness).textTheme,
    ).apply(bodyColor: t.textPrimary, displayColor: t.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: t.brandPrimary,
        brightness: t.brightness,
        primary: t.brandPrimary,
        secondary: t.brandSecondary,
        surface: t.bgCard,
        error: t.danger,
      ),
      scaffoldBackgroundColor: t.bgMain,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: t.bgCard,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: t.brandPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: t.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: t.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
          side: BorderSide(color: t.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.innerRadius),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.brandPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.innerRadius),
          ),
          side: BorderSide(color: t.brandPrimary),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: t.brandPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.bgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.innerRadius),
          borderSide: BorderSide(color: t.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.innerRadius),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.innerRadius),
          borderSide: BorderSide(color: t.brandPrimary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
      ),
      dividerTheme: DividerThemeData(color: t.border, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: t.brandPrimary.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
    );
  }
}
