import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Token-driven UI primitives mirroring the prototype's system.jsx
/// (`Card`, `Btn`, `Input`, `Select`, `Chip`, `Progress`). Every primitive
/// resolves its colours from [AppColors.of] so it responds to the active
/// theme mode automatically.

/// A surface card with themed background, border and rounded corners.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;
  final double? width;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.background,
    this.borderColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? t.bgCard,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: borderColor ?? t.border),
      ),
      child: child,
    );
  }
}

enum AppButtonVariant { primary, secondary, outline, danger }

/// A themed button with primary / secondary / outline / danger variants.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);

    Color bg;
    Color fg;
    Border? border;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = t.brandPrimary;
        fg = Colors.white;
        border = null;
        break;
      case AppButtonVariant.secondary:
        bg = t.bgInput;
        fg = t.textPrimary;
        border = Border.all(color: t.border);
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = t.brandPrimary;
        border = Border.all(color: t.brandPrimary);
        break;
      case AppButtonVariant.danger:
        bg = t.danger;
        fg = Colors.white;
        border = null;
        break;
    }

    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppColors.innerRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppColors.innerRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppColors.innerRadius),
              border: border,
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: fontSize + 4, color: fg),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: fg,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled text field with an uppercase caption, mirroring `Input`.
class AppInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: t.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            suffix: suffix,
          ),
        ),
      ],
    );
  }
}

class AppSelectOption<T> {
  final T value;
  final String label;
  const AppSelectOption({required this.value, required this.label});
}

/// A labelled dropdown mirroring `Select`.
class AppSelect<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;

  const AppSelect({
    super.key,
    this.label,
    required this.value,
    required this.options,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: t.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          dropdownColor: t.bgCard,
          style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
          items: options
              .map(
                (o) =>
                    DropdownMenuItem<T>(value: o.value, child: Text(o.label)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

enum AppChipStatus { normal, warning, danger, success }

/// A soft status pill mirroring `Chip`.
class AppChip extends StatelessWidget {
  final String label;
  final AppChipStatus status;

  const AppChip({
    super.key,
    required this.label,
    this.status = AppChipStatus.normal,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    Color color;
    switch (status) {
      case AppChipStatus.warning:
        color = t.warning;
        break;
      case AppChipStatus.danger:
        color = t.danger;
        break;
      case AppChipStatus.success:
      case AppChipStatus.normal:
        color = t.success;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A slim progress bar mirroring `Progress`.
class AppProgress extends StatelessWidget {
  final double value;
  final double max;
  final Color? color;

  const AppProgress({
    super.key,
    required this.value,
    this.max = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final fraction = (max == 0 ? 0.0 : (value / max)).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 8,
        backgroundColor: t.bgInput,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? t.brandPrimary),
      ),
    );
  }
}
