import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer.dart';

/// A shimmer skeleton that mirrors the real [PatientDashboardPage] layout so
/// the transition from loading → loaded feels seamless (no layout jump).
class PatientDashboardSkeleton extends StatelessWidget {
  const PatientDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Row(
        children: const [
          Expanded(child: _MainColumnSkeleton()),
          _RightPanelSkeleton(),
        ],
      ),
    );
  }
}

class _MainColumnSkeleton extends StatelessWidget {
  const _MainColumnSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: t.bgCard,
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          child: Row(
            children: const [
              Expanded(child: ShimmerBox(height: 44, width: double.infinity)),
              SizedBox(width: 16),
              ShimmerBox(width: 44, height: 44),
              SizedBox(width: 8),
              ShimmerBox(width: 44, height: 44),
              SizedBox(width: 8),
              ShimmerBox(width: 44, height: 44),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Digital health card (big gradient block)
                ShimmerBox(
                  height: 210,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 24),
                // AI summary panel
                ShimmerBox(
                  height: 96,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(16),
                ),
                const SizedBox(height: 24),
                // "Quick Services" heading
                const ShimmerBox(height: 22, width: 180),
                const SizedBox(height: 16),
                // 4 quick action cards
                Row(
                  children: const [
                    Expanded(child: _ActionCardSkeleton()),
                    SizedBox(width: 16),
                    Expanded(child: _ActionCardSkeleton()),
                    SizedBox(width: 16),
                    Expanded(child: _ActionCardSkeleton()),
                    SizedBox(width: 16),
                    Expanded(child: _ActionCardSkeleton()),
                  ],
                ),
                const SizedBox(height: 24),
                // Two-column section (prescriptions / appointments)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(child: _ListSectionSkeleton()),
                    SizedBox(width: 24),
                    Expanded(child: _ListSectionSkeleton()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCardSkeleton extends StatelessWidget {
  const _ActionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: const [
          ShimmerBox.circle(size: 48),
          SizedBox(height: 12),
          ShimmerBox(height: 12, width: 70),
        ],
      ),
    );
  }
}

class _ListSectionSkeleton extends StatelessWidget {
  const _ListSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ShimmerBox(height: 18, width: 160),
        SizedBox(height: 16),
        _RowCardSkeleton(),
        SizedBox(height: 12),
        _RowCardSkeleton(),
        SizedBox(height: 12),
        _RowCardSkeleton(),
      ],
    );
  }
}

class _RowCardSkeleton extends StatelessWidget {
  const _RowCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: const [
          ShimmerBox(width: 40, height: 40),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 13, width: 120),
                SizedBox(height: 8),
                ShimmerBox(height: 11, width: 180),
                SizedBox(height: 6),
                ShimmerBox(height: 10, width: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RightPanelSkeleton extends StatelessWidget {
  const _RightPanelSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(left: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile summary block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.bgInput,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  ShimmerBox.circle(size: 72),
                  SizedBox(height: 12),
                  ShimmerBox(height: 16, width: 120),
                  SizedBox(height: 8),
                  ShimmerBox(height: 12, width: 90),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: ShimmerBox(height: 16, width: 120),
            ),
            const SizedBox(height: 12),
            // Vitals rows
            const _VitalRowSkeleton(),
            const SizedBox(height: 8),
            const _VitalRowSkeleton(),
            const SizedBox(height: 8),
            const _VitalRowSkeleton(),
            const SizedBox(height: 8),
            const _VitalRowSkeleton(),
            const SizedBox(height: 24),
            // Blood donation card
            ShimmerBox(
              height: 150,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: ShimmerBox(height: 16, width: 140),
            ),
            const SizedBox(height: 12),
            const _VitalRowSkeleton(),
            const SizedBox(height: 8),
            const _VitalRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _VitalRowSkeleton extends StatelessWidget {
  const _VitalRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          ShimmerBox(width: 20, height: 20),
          SizedBox(width: 12),
          Expanded(child: ShimmerBox(height: 13)),
          SizedBox(width: 12),
          ShimmerBox(height: 13, width: 40),
        ],
      ),
    );
  }
}
