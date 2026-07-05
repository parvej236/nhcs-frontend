import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pdf_view_dialog.dart';
import '../../patient/data/models/medical_record.dart';
import '../data/models/lab_test_order.dart';
import '../presentation/providers/hospital_providers.dart';

/// ─────────────────────────────────────────────────────────────────────────
///  LABORATORY · Requested Lab Reports
/// ─────────────────────────────────────────────────────────────────────────
///
///  A single, clean page. It lists the lab reports requested by doctors
///  (the pending orders in [labOrdersProvider]). Tapping a request expands it
///  in place:
///
///    1. A line progress indicator runs for ~3s under "Scanning the Lab
///       report..." → "Scanning completed".
///    2. The generated report is shown using the existing [LabReportPdfView].
///    3. "Submit Report" publishes it — it flows simultaneously into the
///       requesting doctor's Report Review queue and the patient's Medical
///       Vault.
class LaboratoryPage extends ConsumerWidget {
  const LaboratoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    // Real pending lab requests raised by doctors (backend: /hospitals/lab-orders).
    final requests = ref
        .watch(laboratoryQueueProvider)
        .where((o) => o.status != 'Published')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, tr, requests.length),
          Expanded(
            child: requests.isEmpty
                ? _buildEmptyState(tr)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    itemCount: requests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final order = requests[index];
                      return _RequestedReportCard(
                        key: ValueKey(order.id),
                        order: order,
                        onSubmit: (results) => _submit(context, ref, tr, order, results),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    AppTranslations tr,
    LabTestOrder order,
    List<LabTestResult> results,
  ) async {
    // Structured result rows the backend persists against the lab report.
    final payload = results
        .map((r) => {
              'parameter': r.parameter,
              'value': r.value,
              'unit': r.unit,
              'referenceRange': r.referenceRange,
              'status': r.status,
            })
        .toList();

    try {
      // Publishes to the backend → status 'Published' + results attached, so it
      // surfaces in the patient's Medical Vault (/patients/me/lab-reports) and,
      // because the report carries the requesting doctor's name, in that
      // doctor's Report Review queue (/doctors/reports/pending).
      await ref.read(laboratoryQueueProvider.notifier).publishOrder(order.id, payload);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tr('hospital_lab_report_word')} ${order.id} ${tr('hospital_lab_snackbar_published_mid')} ${order.patient}${tr('hospital_lab_snackbar_vault_and')} ${order.doctor}${tr('hospital_lab_snackbar_queue_end')}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('hospital_lab_publish_failed')}: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AppTranslations tr, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                tr('hospital_lab_requested_lab_reports'),
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count ${tr('hospital_lab_pending')}',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                tooltip: tr('hospital_lab_reload_requests'),
                onPressed: () => ref.read(laboratoryQueueProvider.notifier).loadOrders(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tr('hospital_lab_header_subtitle'),
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppTranslations tr) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 56, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            tr('hospital_lab_no_pending_requests'),
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr('hospital_lab_empty_hint'),
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// The three visual phases of an expanded request card.
enum _CardPhase { collapsed, scanning, ready }

class _RequestedReportCard extends ConsumerStatefulWidget {
  const _RequestedReportCard({
    super.key,
    required this.order,
    required this.onSubmit,
  });

  final LabTestOrder order;
  final ValueChanged<List<LabTestResult>> onSubmit;

  @override
  ConsumerState<_RequestedReportCard> createState() => _RequestedReportCardState();
}

class _RequestedReportCardState extends ConsumerState<_RequestedReportCard>
    with SingleTickerProviderStateMixin {
  _CardPhase _phase = _CardPhase.collapsed;
  bool _submitted = false;
  late final AnimationController _scanController;
  late final List<LabTestResult> _results;

  @override
  void initState() {
    super.initState();
    _results = _generateResults(widget.order);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _phase = _CardPhase.ready);
        }
      });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_phase == _CardPhase.collapsed) {
      setState(() => _phase = _CardPhase.scanning);
      _scanController.forward(from: 0);
    } else {
      // Collapse and reset.
      _scanController.stop();
      setState(() => _phase = _CardPhase.collapsed);
    }
  }

  LabReport get _report => LabReport(
        id: widget.order.id,
        testName: widget.order.test,
        category: 'Diagnostics',
        date: DateTime.now(),
        hospitalName: 'Dhaka Central Hospital',
        doctorName: widget.order.doctor,
        status: 'Published',
        results: _results,
        aiInterpretation: ref.read(translationsProvider)('hospital_lab_ai_interpretation'),
      );

  @override
  Widget build(BuildContext context) {
    final expanded = _phase != _CardPhase.collapsed;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expanded ? AppColors.primary.withOpacity(0.5) : AppColors.divider,
        ),
        boxShadow: expanded
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(expanded),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: _phase == _CardPhase.scanning
                        ? _buildScanning()
                        : _buildReport(),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(bool expanded) {
    final tr = ref.watch(translationsProvider);
    final o = widget.order;
    return InkWell(
      onTap: _submitted ? null : _toggle,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _submitted ? Icons.check_circle_rounded : Icons.biotech_rounded,
                color: _submitted ? AppColors.success : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.test,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${o.patient}  ·  ${o.healthId}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${tr('hospital_lab_requested_by')} ${o.doctor}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (_submitted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tr('hospital_lab_submitted'),
                  style: GoogleFonts.inter(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Row(
                children: [
                  Text(
                    o.id,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanning() {
    final tr = ref.watch(translationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: AnimatedBuilder(
            animation: _scanController,
            builder: (context, _) => LinearProgressIndicator(
              value: _scanController.value,
              minHeight: 6,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              tr('hospital_lab_scanning'),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReport() {
    final tr = ref.watch(translationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text(
              tr('hospital_lab_scanning_completed'),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // The reused lab-report layout, rendered on a white "page" like the
        // existing PDF viewer canvas.
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: LabReportPdfView(report: _report),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submitted ? null : _onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(
              tr('hospital_lab_submit_report'),
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    widget.onSubmit(_results);
    setState(() {
      _submitted = true;
      _phase = _CardPhase.collapsed;
    });
  }
}

/// Produces plausible result rows for the scanned report based on the test
/// name, so the reused [LabReportPdfView] renders a realistic report.
List<LabTestResult> _generateResults(LabTestOrder order) {
  if (order.results.isNotEmpty) {
    return order.results.entries
        .map((e) => LabTestResult(
              parameter: e.key,
              value: e.value,
              unit: '',
              referenceRange: '',
              status: 'Normal',
            ))
        .toList();
  }

  final t = order.test.toLowerCase();
  if (t.contains('cbc') || t.contains('blood count')) {
    return [
      LabTestResult(parameter: 'Haemoglobin', value: '13.8', unit: 'g/dL', referenceRange: '13.0 – 17.0', status: 'Normal'),
      LabTestResult(parameter: 'WBC Count', value: '7.2', unit: '10³/µL', referenceRange: '4.0 – 11.0', status: 'Normal'),
      LabTestResult(parameter: 'Platelets', value: '250', unit: '10³/µL', referenceRange: '150 – 400', status: 'Normal'),
    ];
  }
  if (t.contains('glucose')) {
    return [
      LabTestResult(parameter: 'Glucose (Fasting)', value: '6.4', unit: 'mmol/L', referenceRange: '< 5.6', status: 'High'),
    ];
  }
  if (t.contains('lipid')) {
    return [
      LabTestResult(parameter: 'Total Cholesterol', value: '210', unit: 'mg/dL', referenceRange: '< 200', status: 'High'),
      LabTestResult(parameter: 'HDL', value: '48', unit: 'mg/dL', referenceRange: '> 40', status: 'Normal'),
      LabTestResult(parameter: 'LDL', value: '132', unit: 'mg/dL', referenceRange: '< 130', status: 'High'),
      LabTestResult(parameter: 'Triglycerides', value: '150', unit: 'mg/dL', referenceRange: '< 150', status: 'Normal'),
    ];
  }
  if (t.contains('creatinine')) {
    return [
      LabTestResult(parameter: 'Serum Creatinine', value: '1.0', unit: 'mg/dL', referenceRange: '0.7 – 1.3', status: 'Normal'),
    ];
  }
  if (t.contains('ecg') || t.contains('electrocardiogram')) {
    return [
      LabTestResult(parameter: 'Rhythm', value: 'Normal Sinus Rhythm', unit: '', referenceRange: 'Regular', status: 'Normal'),
      LabTestResult(parameter: 'Heart Rate', value: '76', unit: 'bpm', referenceRange: '60 – 100', status: 'Normal'),
    ];
  }
  // Generic fallback.
  return [
    LabTestResult(parameter: order.test, value: 'Within range', unit: '', referenceRange: 'Normal', status: 'Normal'),
  ];
}
