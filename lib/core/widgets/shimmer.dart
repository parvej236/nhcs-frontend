import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A beautiful, theme-aware shimmer loading system.
///
/// Wrap any tree of [ShimmerBox] placeholders in a [Shimmer] widget and a
/// soft light sweeps diagonally across all of them in sync — the classic
/// "skeleton" loading effect used by Facebook, LinkedIn, YouTube, etc.
///
/// ```dart
/// Shimmer(
///   child: Column(
///     children: const [
///       ShimmerBox(height: 20, width: 160),
///       SizedBox(height: 12),
///       ShimmerBox(height: 120),
///     ],
///   ),
/// )
/// ```
///
/// The base/highlight colours are derived from the active [AppColors] token
/// set, so it looks correct in both light and dark mode automatically.
class Shimmer extends StatefulWidget {
  final Widget child;

  /// Duration of one full sweep across the widget.
  final Duration period;

  const Shimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1400),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);

    // Base = the resting placeholder colour; highlight = the moving glint.
    final Color base = t.isDark
        ? t.bgInput
        : t.bgInput.withValues(alpha: 0.9);
    final Color highlight = t.isDark
        ? Color.alphaBlend(Colors.white.withValues(alpha: 0.06), t.bgCard)
        : Colors.white;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            // Slide a diagonal band from far-left to far-right.
            final double dx = (_controller.value * 2 - 1) * bounds.width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Translates the shimmer gradient horizontally by [dx] logical pixels.
class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

/// A single rounded placeholder block. Colour is irrelevant — it is repainted
/// by the parent [Shimmer]'s [ShaderMask]; only its shape and size matter.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  }) : shape = null;

  /// A perfect circle (e.g. for avatars).
  const ShimmerBox.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = null,
        shape = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    // Any opaque colour works; the shader paints over it.
    const paint = Colors.white;
    if (shape is CircleBorder) {
      return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(color: paint, shape: BoxShape.circle),
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: paint,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
    );
  }
}
