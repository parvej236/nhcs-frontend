import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_primitives.dart';
import '../../../core/providers/public_providers.dart';
import '../../../core/providers/language_provider.dart';

// Horizontal page gutter used across the marketing site.
const double _gutter = 40;

/// Constrains content to a comfortable desktop width and centres it, while
/// keeping full-width backgrounds possible for band sections.
class _MaxWidth extends StatelessWidget {
  final Widget child;
  const _MaxWidth({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: child,
      ),
    );
  }
}

/// Lays [children] out in [columns] equal-width cells, collapsing to a single
/// column on narrow viewports.
class _ResponsiveGrid extends StatelessWidget {
  final int columns;
  final double spacing;
  final List<Widget> children;
  const _ResponsiveGrid({
    required this.columns,
    required this.children,
    this.spacing = 24,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth < 760 ? 1 : columns;
        final itemWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

Widget _sectionTitle(BuildContext context, String text, {bool center = true}) {
  final t = AppColors.of(context);
  return Text(
    text,
    textAlign: center ? TextAlign.center : TextAlign.start,
    style: GoogleFonts.outfit(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: t.textPrimary,
    ),
  );
}

// ---------------------------------------------------------------------------
// 1. Web Hero
// ---------------------------------------------------------------------------
class WebHero extends ConsumerWidget {
  final VoidCallback onRunVitals;
  final VoidCallback onSearchDoctor;
  const WebHero({super.key, required this.onRunVitals, required this.onSearchDoctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);
    final statsAsync = ref.watch(publicStatsProvider);

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: t.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            tr('hero_badge'),
            style: GoogleFonts.inter(
              color: t.brandPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: GoogleFonts.outfit(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: t.textPrimary,
            ),
            children: [
              TextSpan(text: '${tr('hero_title_line1')}\n'),
              TextSpan(
                text: tr('hero_title_highlight'),
                style: TextStyle(color: t.brandPrimary),
              ),
              TextSpan(text: tr('hero_title_tail')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          tr('hero_subtitle'),
          style: GoogleFonts.inter(
            fontSize: 17,
            height: 1.6,
            color: t.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            AppButton(label: tr('hero_btn_vitals'), onPressed: onRunVitals),
            AppButton(
              label: tr('hero_btn_search'),
              onPressed: onSearchDoctor,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ],
    );

    final tracker = AppCard(
      borderColor: t.brandPrimary.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: t.brandPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                tr('tracker_title'),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: t.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => Column(
              children: [
                _trackerRow(context, tr('tracker_registries'), '${stats['patients'] ?? 0} ${tr('tracker_patients')}'),
                const SizedBox(height: 14),
                _trackerRow(context, tr('tracker_hospitals'), '${stats['hospitals'] ?? 0} ${tr('tracker_centres')}'),
                const SizedBox(height: 14),
                _trackerRow(context, tr('tracker_specialists'), '${stats['doctors'] ?? 0} ${tr('tracker_doctors')}'),
              ],
            ),
            loading: () => Column(
              children: [
                _trackerRow(context, tr('tracker_registries'), '...'),
                const SizedBox(height: 14),
                _trackerRow(context, tr('tracker_hospitals'), '...'),
                const SizedBox(height: 14),
                _trackerRow(context, tr('tracker_specialists'), '...'),
              ],
            ),
            error: (err, stack) => Column(
              children: [
                _trackerRow(context, tr('tracker_registries'), 'Error'),
                const SizedBox(height: 14),
                _trackerRow(context, tr('tracker_hospitals'), 'Error'),
                const SizedBox(height: 14),
                _trackerRow(context, tr('tracker_specialists'), 'Error'),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 30, _gutter, 20),
      child: _MaxWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.3,
              colors: t.isDark
                  ? [const Color(0xFFB91C1C).withValues(alpha: 0.22), t.bgCard]
                  : [const Color(0xFFFEE2E2).withValues(alpha: 0.8), t.bgCard],
              stops: const [0.0, 0.8],
            ),
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: t.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [copy, const SizedBox(height: 32), tracker],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: copy),
                  const SizedBox(width: 40),
                  SizedBox(width: 380, child: tracker),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _trackerRow(BuildContext context, String label, String value) {
    final t = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: t.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Stat Row
// ---------------------------------------------------------------------------
class StatRow extends ConsumerWidget {
  const StatRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(publicStatsProvider);
    final tr = ref.watch(translationsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
      child: _MaxWidth(
        child: statsAsync.when(
          data: (stats) => _ResponsiveGrid(
            columns: 3,
            children: [
              _StatCard(value: '${stats['patients'] ?? 0}', label: tr('stat_patients')),
              _StatCard(value: '${stats['doctors'] ?? 0}', label: tr('stat_specialists')),
              _StatCard(value: '${stats['hospitals'] ?? 0}', label: tr('stat_facilities')),
            ],
          ),
          loading: () => _ResponsiveGrid(
            columns: 3,
            children: [
              _StatCard(value: '...', label: tr('stat_patients')),
              _StatCard(value: '...', label: tr('stat_specialists')),
              _StatCard(value: '...', label: tr('stat_facilities')),
            ],
          ),
          error: (err, stack) => _ResponsiveGrid(
            columns: 3,
            children: [
              _StatCard(value: 'Error', label: tr('stat_patients')),
              _StatCard(value: 'Error', label: tr('stat_specialists')),
              _StatCard(value: 'Error', label: tr('stat_facilities')),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    return AppCard(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: t.brandPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: t.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Vitals Checker
// ---------------------------------------------------------------------------
int? _parseSystolic(String text) {
  final reg = RegExp(r'(\d{2,3})\s*/\s*(\d{2,3})');
  final match = reg.firstMatch(text);
  if (match != null) {
    return int.tryParse(match.group(1) ?? '');
  }
  return null;
}

int? _parseDiastolic(String text) {
  final reg = RegExp(r'(\d{2,3})\s*/\s*(\d{2,3})');
  final match = reg.firstMatch(text);
  if (match != null) {
    return int.tryParse(match.group(2) ?? '');
  }
  return null;
}

double? _parseGlucose(String text) {
  final reg = RegExp(r'(?:glucose|sugar|index shows|is)\s*(?:is|shows)?\s*(\d{2,3})', caseSensitive: false);
  final match = reg.firstMatch(text);
  if (match != null) {
    return double.tryParse(match.group(1) ?? '');
  }
  if (text.toLowerCase().contains('glucose') || text.toLowerCase().contains('sugar') || text.toLowerCase().contains('diabetes')) {
    final digitReg = RegExp(r'\b(\d{2,3})\b');
    final matches = digitReg.allMatches(text);
    for (final m in matches) {
      final val = double.tryParse(m.group(1) ?? '');
      if (val != null && val > 40) return val;
    }
  }
  return null;
}

AppChipStatus _mapSeverity(String? severity) {
  if (severity == 'danger') return AppChipStatus.danger;
  if (severity == 'warning') return AppChipStatus.warning;
  if (severity == 'success') return AppChipStatus.success;
  return AppChipStatus.normal;
}

class VitalsChecker extends ConsumerStatefulWidget {
  const VitalsChecker({super.key});

  @override
  ConsumerState<VitalsChecker> createState() => _VitalsCheckerState();
}

class _VitalsCheckerState extends ConsumerState<VitalsChecker> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = 'গত কয়েক ঘণ্টা ধরে বুকের মাঝখানে তীব্র চাপ ও ভারী ভাব অনুভব করছি, যা আস্তে আস্তে বাম হাত এবং ঘাড়ে ছড়িয়ে যাচ্ছে। প্রচণ্ড ঘাম হচ্ছে এবং শ্বাস নিতে খুব কষ্ট হচ্ছে। সেই সাথে প্রচণ্ড মাথা ঘোরা এবং বমি বমি ভাব আছে। পালস রেট অনেক বেশি (Pulse 110 bpm), রক্তচাপ BP 165/100 এবং শরীরে অক্সিজেনের মাত্রা SpO2 92% দেখাচ্ছে।';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final analysisState = ref.watch(vitalsAnalysisProvider);

    final input = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptom & Vitals Input',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: t.brandPrimary),
              const SizedBox(width: 6),
              Text(
                'Judge Check Scenario Pre-filled',
                style: GoogleFonts.inter(fontSize: 12, color: t.brandPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: _controller,
            maxLines: 6,
            hint:
                'Type symptoms or clinical records here (e.g. Feeling dizzy, BP 140/90, Glucose 110)...',
          ),
          const SizedBox(height: 16),
          AppButton(
            label: analysisState.isLoading ? 'Analyzing...' : 'Analyze Vitals',
            onPressed: analysisState.isLoading
                ? null
                : () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      ref.read(vitalsAnalysisProvider.notifier).analyze(
                        symptomsText: text,
                        bpSystolic: _parseSystolic(text),
                        bpDiastolic: _parseDiastolic(text),
                        glucose: _parseGlucose(text),
                      );
                    }
                  },
            expand: true,
          ),
        ],
      ),
    );

    final resultCard = AppCard(
      child: analysisState.isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          : analysisState.error != null
              ? _errorResult(context, analysisState.error!)
              : analysisState.result == null
                  ? _emptyResult(context)
                  : _filledResult(context, analysisState.result!),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
      child: _MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, ref.watch(translationsProvider)('section_vitals_analyzer'), center: false),
            const SizedBox(height: 24),
            _ResponsiveGrid(columns: 2, spacing: 30, children: [input, resultCard]),
          ],
        ),
      ),
    );
  }

  Widget _errorResult(BuildContext context, String message) {
    final t = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: t.brandPrimary),
          const SizedBox(height: 16),
          Text(
            'Analysis Error',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: t.brandPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _emptyResult(BuildContext context) {
    final t = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.monitor_heart_outlined, size: 48, color: t.brandPrimary),
          const SizedBox(height: 16),
          Text(
            'Awaiting Input Parameters',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select one of the simulation triggers on the left to see dynamic AI '
            'health screening in action.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _filledResult(BuildContext context, Map<String, dynamic> r) {
    final t = AppColors.of(context);
    final recList = r['recommendations'] != null 
        ? List<String>.from(r['recommendations'] as List) 
        : const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'AI Health Assessment',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: t.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AppChip(
              label: r['category'] ?? 'General',
              status: _mapSeverity(r['severity'] as String?),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          children: [
            _kv(context, 'BP', r['bpVal'] ?? 'Not provided'),
            _kv(context, 'Glucose', r['glucoseVal'] ?? 'Not provided'),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.bgInput,
            borderRadius: BorderRadius.circular(AppColors.innerRadius),
          ),
          child: Text(
            r['summary'] ?? '',
            style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: t.textPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Clinical Recommendations:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        for (final rec in recList)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: TextStyle(color: t.textSecondary)),
                Expanded(
                  child: Text(
                    rec,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.6,
                      color: t.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Divider(color: t.border),
        const SizedBox(height: 8),
        Text(
          'Disclaimer: AI predictions are for screening only. Do not replace '
          'clinical doctor diagnoses.',
          style: GoogleFonts.inter(fontSize: 11, color: t.textSecondary),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    final t = AppColors.of(context);
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Doctor Queue Tracker
// ---------------------------------------------------------------------------
class DoctorQueueTracker extends ConsumerStatefulWidget {
  final VoidCallback onJoinQueue;
  const DoctorQueueTracker({super.key, required this.onJoinQueue});

  @override
  ConsumerState<DoctorQueueTracker> createState() => _DoctorQueueTrackerState();
}

class _DoctorQueueTrackerState extends ConsumerState<DoctorQueueTracker> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);

    // Track vitals AI result to extract specialty recommendation
    final vitalsState = ref.watch(vitalsAnalysisProvider);
    final aiResult = vitalsState.result;
    String? recommendedSpecialty;
    if (aiResult != null && aiResult['category'] != null) {
      final category = aiResult['category'].toString().toLowerCase();
      if (category.contains('cardiology') || category.contains('heart')) {
        recommendedSpecialty = 'Cardiology';
      } else if (category.contains('endocrinology') || category.contains('diabetes') || category.contains('diabetology')) {
        recommendedSpecialty = 'Endocrinology & Diabetology';
      } else if (category.contains('gynaecology') || category.contains('obstetrics') || category.contains('gynae')) {
        recommendedSpecialty = 'Gynaecology & Obstetrics';
      } else if (category.contains('urology')) {
        recommendedSpecialty = 'Urology';
      } else if (category.contains('ent')) {
        recommendedSpecialty = 'ENT';
      } else if (category.contains('orthopedic') || category.contains('orthopedics')) {
        recommendedSpecialty = 'Orthopedics';
      } else if (category.contains('pediatric') || category.contains('pediatrics')) {
        recommendedSpecialty = 'Pediatrics';
      } else if (category.contains('general')) {
        recommendedSpecialty = 'General Medicine';
      }
    }

    final showPreview = _search.isEmpty && recommendedSpecialty == null;
    final doctorsAsync = ref.watch(publicDoctorsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
      child: _MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _sectionTitle(context, 'Search Specialists & Queue Status', center: false),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 320,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: 'Search doctors or specialties...',
                      prefixIcon: Icon(Icons.search, color: t.textSecondary, size: 20),
                      fillColor: t.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: t.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: t.border),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (showPreview) ...[
              SizedBox(
                height: 360,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10000,
                  itemBuilder: (context, index) {
                    final doc = mockPreviewDoctors[index % mockPreviewDoctors.length];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 340,
                        child: _DoctorCard(
                          doc: doc,
                          onJoin: widget.onJoinQueue,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              if (recommendedSpecialty != null && _search.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: t.brandPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.brandPrimary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.psychology, color: t.brandPrimary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Recommended Specialty: $recommendedSpecialty',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: t.brandPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Showing the best matching specialists for your vitals risk profile.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: t.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(vitalsAnalysisProvider.notifier).reset();
                        },
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        label: Text(
                          'Clear Recommendation',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: t.brandPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              doctorsAsync.when(
                data: (doctors) {
                  List<dynamic> filtered = [];
                  if (_search.isNotEmpty) {
                    final query = _search.toLowerCase();
                    filtered = doctors.where((doc) {
                      final name = (doc['name'] ?? '').toString().toLowerCase();
                      final specialty = (doc['specialization'] ?? '').toString().toLowerCase();
                      return name.contains(query) || specialty.contains(query);
                    }).toList();
                  } else if (recommendedSpecialty != null) {
                    final rec = recommendedSpecialty.toLowerCase();
                    filtered = doctors.where((doc) {
                      final specialty = (doc['specialization'] ?? '').toString().toLowerCase();
                      return specialty.contains(rec) || rec.contains(specialty);
                    }).toList();
                    // Sort by rating to get the best match
                    filtered.sort((a, b) {
                      final aVal = (a['rating'] ?? 0.0) as num;
                      final bVal = (b['rating'] ?? 0.0) as num;
                      return bVal.compareTo(aVal);
                    });
                    // Only keep top 1 or 2 doctors
                    if (filtered.length > 2) {
                      filtered = filtered.sublist(0, 2);
                    }
                  }

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No specialists found in the database matching your criteria.',
                          style: GoogleFonts.inter(color: t.textSecondary),
                        ),
                      ),
                    );
                  }

                  return _ResponsiveGrid(
                    columns: 3,
                    children: [
                      for (final doc in filtered)
                        _DoctorCard(
                          doc: doc,
                          onJoin: widget.onJoinQueue,
                        ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Failed to load specialists directory.',
                      style: GoogleFonts.inter(color: t.brandPrimary),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final dynamic doc;
  final VoidCallback onJoin;
  const _DoctorCard({required this.doc, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final String name = doc['name'] ?? 'Doctor';
    final String specialization = doc['specialization'] ?? 'General Medicine';
    final String hospital = doc['hospital'] ?? 'Dhaka Central Hospital';
    final String fee = '${doc['fee'] ?? 800} BDT';
    final String experience = '${doc['experience'] ?? 5} Years';
    final int queue = doc['queueCount'] ?? 0;
    final double rating = (doc['rating'] as num?)?.toDouble() ?? 4.5;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: t.textPrimary,
                      ),
                    ),
                    Text(
                      specialization,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: t.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⭐ $rating',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: t.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row(context, 'Affiliation:', hospital),
          const SizedBox(height: 8),
          _row(context, 'Consultation Fee:', fee),
          const SizedBox(height: 8),
          _row(context, 'Experience:', experience),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.bgInput,
              borderRadius: BorderRadius.circular(AppColors.innerRadius),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Queue Traffic:',
                      style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary),
                    ),
                    Text(
                      '$queue Patients Waiting',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: t.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppProgress(
                  value: queue.toDouble(),
                  max: 10,
                  color: queue > 4 ? t.warning : t.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Join Queue Slot', onPressed: onJoin, expand: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final t = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: t.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Emergency Blood Request
// ---------------------------------------------------------------------------
class EmergencyBloodRequest extends StatelessWidget {
  final VoidCallback onRequest;
  final VoidCallback onRegisterDonor;
  const EmergencyBloodRequest({
    super.key,
    required this.onRequest,
    required this.onRegisterDonor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
      child: _MaxWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
            ),
            borderRadius: BorderRadius.circular(AppColors.radius),
          ),
          child: Column(
            children: [
              Text(
                'Emergency Blood Request',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Need blood urgently? Our AI-powered system instantly connects you '
                'with compatible donors in nearby hospital zones.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC2626),
                    ),
                    child: const Text('Request Blood Now'),
                  ),
                  OutlinedButton(
                    onPressed: onRegisterDonor,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    child: const Text('Register as Donor'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Live Donor Availability
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// 6. Live Donor Availability
// ---------------------------------------------------------------------------
class LiveDonorAvailability extends ConsumerWidget {
  const LiveDonorAvailability({super.key});

  void _showDonorDetails(BuildContext context, String hubName) {
    final List<Map<String, String>> donors;
    if (hubName.contains('Dhaka')) {
      donors = [
        {
          'name': 'Faisal Ahmed',
          'group': 'AB-',
          'phone': '+880 1748-043201',
          'location': 'House 35, Road 20, Dhanmondi, Dhaka',
          'status': 'Eligible & Active',
          'lastDonation': '2026-03-10',
        },
        {
          'name': 'Shilpi Rahman',
          'group': 'O+',
          'phone': '+880 1787-919944',
          'location': 'House 62, Road 20, Dhanmondi, Dhaka',
          'status': 'Eligible & Active',
          'lastDonation': '2026-04-12',
        },
        {
          'name': 'Sonia Siddique',
          'group': 'A-',
          'phone': '+880 1749-250541',
          'location': 'House 78, Road 12, Dhanmondi, Dhaka',
          'status': 'Eligible & Active',
          'lastDonation': '2026-02-28',
        },
      ];
    } else if (hubName.contains('Chittagong') || hubName.contains('Chattogram')) {
      donors = [
        {
          'name': 'Masud Rana',
          'group': 'O+',
          'phone': '+880 1812-445566',
          'location': 'CUET campus, Raojan, Chittagong',
          'status': 'Eligible & Active',
          'lastDonation': '2026-05-01',
        },
        {
          'name': 'Ruma Talukder',
          'group': 'O+',
          'phone': '+880 1770-903347',
          'location': 'Chittagong Main Road, Chittagong',
          'status': 'Eligible & Active',
          'lastDonation': '2026-04-20',
        },
      ];
    } else {
      donors = [
        {
          'name': 'Sowkot Bhuiyan',
          'group': 'B+',
          'phone': '+880 1912-887766',
          'location': 'Zindabazar, Sylhet',
          'status': 'Eligible & Active',
          'lastDonation': '2026-03-25',
        },
        {
          'name': 'Tasnim Ali',
          'group': 'B-',
          'phone': '+880 1756-615331',
          'location': 'Ambarkhana, Sylhet',
          'status': 'Eligible & Active',
          'lastDonation': '2026-04-05',
        },
      ];
    }

    showDialog(
      context: context,
      builder: (context) {
        final t = AppColors.of(context);
        return Dialog(
          backgroundColor: t.bgCard,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 550),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Donors: $hubName',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: t.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: t.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Matches retrieved from active NHCS registry records',
                  style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: donors.length,
                    separatorBuilder: (c, i) => Divider(color: t.border, height: 24),
                    itemBuilder: (context, idx) {
                      final d = donors[idx];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              d['group']!,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d['name']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: t.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📍 ${d['location']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: t.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📞 Contact: ${d['phone']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: t.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: t.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        d['status']!,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: t.success,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last Donated: ${d['lastDonation']}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: t.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      label: 'Close',
                      onPressed: () => Navigator.pop(context),
                      variant: AppButtonVariant.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);
    final hubs = [
      ('Dhaka Central Hub', '92%', 'Awaiting product configuration & matching', t.success),
      ('Chittagong Zone', '68%', 'Collection status & verification active', t.warning),
      ('Sylhet Division', '85%', 'Efficiency optimization active', t.success),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
      child: _MaxWidth(
        child: Column(
          children: [
            _sectionTitle(context, tr('section_donor_availability')),
            const SizedBox(height: 6),
            Text(
              tr('donor_subtitle'),
              style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary),
            ),
            const SizedBox(height: 24),
            _ResponsiveGrid(
              columns: 3,
              children: [
                for (final hub in hubs)
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          hub.$1,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: t.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hub.$2,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: hub.$4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hub.$3,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: tr('view_details'),
                          onPressed: () => _showDonorDetails(context, hub.$1),
                          variant: AppButtonVariant.outline,
                          expand: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Our Solutions
// ---------------------------------------------------------------------------
class OurSolutions extends ConsumerWidget {
  const OurSolutions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);
    final solutions = [
      (
        Icons.monitor_heart_outlined,
        tr('sol1_title'),
        tr('sol1_desc'),
      ),
      (
        Icons.favorite_border,
        tr('sol2_title'),
        tr('sol2_desc'),
      ),
      (
        Icons.person_outline,
        tr('sol3_title'),
        tr('sol3_desc'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
      child: _MaxWidth(
        child: Column(
          children: [
            _sectionTitle(context, tr('section_solutions')),
            const SizedBox(height: 32),
            _ResponsiveGrid(
              columns: 3,
              children: [
                for (final sol in solutions)
                  AppCard(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: t.brandPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(sol.$1, color: t.brandPrimary, size: 26),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          sol.$2,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: t.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sol.$3,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.6,
                            color: t.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          tr('learn_more'),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: t.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Success Stories
// ---------------------------------------------------------------------------
class SuccessStories extends ConsumerWidget {
  const SuccessStories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);
    final stories = [
      (
        Icons.bloodtype_outlined,
        tr('story1_title'),
        tr('story1_body'),
      ),
      (
        Icons.check_circle_outline,
        tr('story2_title'),
        tr('story2_body'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
      child: _MaxWidth(
        child: Column(
          children: [
            _sectionTitle(context, tr('section_success')),
            const SizedBox(height: 32),
            _ResponsiveGrid(
              columns: 2,
              children: [
                for (final story in stories)
                  AppCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(story.$1, color: t.brandPrimary, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story.$2,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: t.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                story.$3,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                  color: t.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 9. Health Blog Hub
// ---------------------------------------------------------------------------
class HealthBlogHub extends ConsumerWidget {
  final VoidCallback onReadArticle;
  const HealthBlogHub({super.key, required this.onReadArticle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
      child: _MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, tr('section_blog'), center: false),
            const SizedBox(height: 24),
            _ResponsiveGrid(
              columns: 2,
              spacing: 30,
              children: [
                _blogCard(
                  context,
                  tag: 'GENETIC AWARENESS',
                  tagColor: t.brandPrimary,
                  title: 'Understanding Thalassemia Carriers',
                  body:
                      'Being a carrier (Thalassemia trait) means you carry one mutated '
                      'gene, but usually show no symptoms. Screening before marriage is '
                      'vital. If both parents carry the trait, there is a 25% chance '
                      'their child will have Thalassemia Major.',
                ),
                _blogCard(
                  context,
                  tag: 'CLINICAL CARDIO',
                  tagColor: t.success,
                  title: 'Cardiovascular Health & BP Guidelines',
                  body:
                      'Maintaining target blood pressure (below 120/80 mmHg) is critical '
                      'for preventing renal stress and stroke risks. Monitor daily, reduce '
                      'sodium intake, and understand your systolic ranges.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _blogCard(
    BuildContext context, {
    required String tag,
    required Color tagColor,
    required String title,
    required String body,
  }) {
    final t = AppColors.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: tagColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: t.textSecondary),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleReadingPage(
                    title: title,
                    tag: tag,
                    tagColor: tagColor,
                  ),
                ),
              );
            },
            child: Text(
              'Read Article  ➔',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 10. Footer
// ---------------------------------------------------------------------------
class PublicFooter extends StatelessWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final footerBg = t.isDark ? const Color(0xFF090F1E) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      color: footerBg,
      padding: const EdgeInsets.fromLTRB(80, 40, 80, 20),
      child: _MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 40,
              runSpacing: 24,
              alignment: WrapAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, color: t.brandPrimary, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'NHCS AI',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: t.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Universal digital healthcare system bridging patients, '
                        'doctors, and clinical facilities securely.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.6,
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _footerCol(context, 'Emergency Support', [
                  'Medical Hotline: 16263',
                  'Virtual Counseling: 01833-311199',
                ]),
                _footerCol(context, 'Affiliates', [
                  'BSMMU Hospital',
                  'Bangladesh National Health Registry',
                ]),
              ],
            ),
            const SizedBox(height: 32),
            Divider(color: t.border),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8,
              children: [
                Text(
                  '© 2026 NHCS AI. All rights reserved.',
                  style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary),
                ),
                Text(
                  'Secured using HIPAA Compliant Standards',
                  style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerCol(BuildContext context, String title, List<String> lines) {
    final t = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Article Reading Page
// ---------------------------------------------------------------------------
class ArticleReadingPage extends StatelessWidget {
  final String title;
  final String tag;
  final Color tagColor;

  const ArticleReadingPage({
    super.key,
    required this.title,
    required this.tag,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final isThalassemia = title.contains('Thalassemia');

    return Scaffold(
      backgroundColor: t.bgMain,
      appBar: AppBar(
        backgroundColor: t.bgCard,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: t.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NHCS Health Insights',
          style: GoogleFonts.inter(
            color: t.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tagColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Meta Info
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=100&auto=format&fit=crop',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NHCS Medical Editorial Team',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: t.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Published July 5, 2026 • 6 min read',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Featured Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    isThalassemia
                        ? 'https://images.unsplash.com/photo-1579684389782-64d84b5e901d?q=80&w=1000&auto=format&fit=crop'
                        : 'https://images.unsplash.com/photo-1559757175-5700dde675bc?q=80&w=1000&auto=format&fit=crop',
                    height: 380,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                // Body Content
                if (isThalassemia) ...[
                  _paragraph(t,
                      'Thalassemia is a genetic blood disorder characterized by abnormal hemoglobin production. Hemoglobin is the protein in red blood cells that carries oxygen throughout the body. When hemoglobin production is impaired, it leads to anemia, fatigue, and other clinical complications.'),
                  const SizedBox(height: 20),
                  _sectionHeader(t, 'Understanding Thalassemia Carrier Status (Trait)'),
                  _paragraph(t,
                      'A person who carries only one mutated copy of the beta-globin gene is called a beta-thalassemia carrier, or is said to have thalassemia minor. Carriers generally live a completely normal, healthy life with mild or no anemia at all. However, carrier status is of immense clinical significance when planning a family.'),
                  const SizedBox(height: 24),
                  // Visual Diagram: Punnett Square
                  _punnettSquareDiagram(context, t),
                  const SizedBox(height: 24),
                  _sectionHeader(t, 'Key Inheritance Statistics'),
                  _bulletPoint(t, 'If only one parent is a carrier, children have a 50% chance of being carriers but 0% chance of having Thalassemia Major.'),
                  _bulletPoint(t, 'If both parents are carriers, there is a 25% chance of the child having Thalassemia Major (severe disease), 50% chance of carrier status, and 25% chance of being completely unaffected.'),
                  _bulletPoint(t, 'Premarital screening (Hemoglobin Electrophoresis) is a highly effective preventive measure to eradicate Thalassemia Major births.'),
                ] else ...[
                  _paragraph(t,
                      'Cardiovascular health is central to systemic longevity. Blood pressure (BP) measures the force of blood pushing against the walls of the arteries as the heart pumps. Hypertension, or chronic high blood pressure, is frequently referred to as the "silent killer" because it can cause major arterial damage without presenting any noticeable symptoms.'),
                  const SizedBox(height: 20),
                  _sectionHeader(t, 'Standard Clinical Blood Pressure Zones'),
                  _paragraph(t,
                      'Blood pressure is recorded as two numbers: Systolic pressure (when the heart beats) and Diastolic pressure (when the heart rests between beats). Standard medical guidelines categorize blood pressure into distinct actionable zones.'),
                  const SizedBox(height: 24),
                  // Visual Zone Chart
                  _bpZoneChart(context, t),
                  const SizedBox(height: 24),
                  _sectionHeader(t, 'Actionable Steps to Regulate Blood Pressure'),
                  _bulletPoint(t, 'Reduce Sodium Intake: Limit processed foods and aim for under 2,000 mg of sodium daily.'),
                  _bulletPoint(t, 'Regular Aerobic Exercise: Strive for at least 150 minutes of moderate-intensity exercise weekly.'),
                  _bulletPoint(t, 'Routine Vitals Tracking: Use the NHCS patient dashboard daily to monitor readings and catch hypertension spikes before they cause renal or cardiac strain.'),
                ],
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                // Footer Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: t.brandPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: t.brandPrimary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: t.brandPrimary, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NHCS AI Public Health Warning',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: t.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This content is verified by the National Health Commission of Bangladesh. Consult a licensed practitioner for personalized clinical diagnostics.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: t.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paragraph(AppColorTokens t, String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        height: 1.7,
        color: t.textPrimary,
      ),
    );
  }

  Widget _sectionHeader(AppColorTokens t, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: t.textPrimary,
        ),
      ),
    );
  }

  Widget _bulletPoint(AppColorTokens t, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 18, color: t.brandPrimary, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: t.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _punnettSquareDiagram(BuildContext context, AppColorTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inheritance Probability Diagram (Carrier Cross-Matching)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 80),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: t.brandPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Father Carrier (T t)',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: t.brandPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 120,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: t.brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'Mother Carrier (T t)',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: t.brandPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.0,
                      children: [
                        _gridItem(t, 'TT', '25% Normal', t.success),
                        _gridItem(t, 'Tt', '25% Carrier', Colors.orange),
                        _gridItem(t, 'Tt', '25% Carrier', Colors.orange),
                        _gridItem(t, 'tt', '25% Affected', Colors.redAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gridItem(AppColorTokens t, String alleles, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            alleles,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: t.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _bpZoneChart(BuildContext context, AppColorTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinical Blood Pressure Classification Zones',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.border),
          ),
          child: Column(
            children: [
              _bpZoneRow(t, 'Normal', '< 120 / < 80 mmHg', t.success),
              const Divider(),
              _bpZoneRow(t, 'Elevated', '120-129 / < 80 mmHg', Colors.amber),
              const Divider(),
              _bpZoneRow(t, 'Hypertension Stage 1', '130-139 / 80-89 mmHg', Colors.orange),
              const Divider(),
              _bpZoneRow(t, 'Hypertension Stage 2', '>= 140 / >= 90 mmHg', Colors.redAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bpZoneRow(AppColorTokens t, String zoneName, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                zoneName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: t.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            range,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: t.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
