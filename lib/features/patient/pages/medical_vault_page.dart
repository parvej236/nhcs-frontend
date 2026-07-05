import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/widgets/app_primitives.dart';
import '../data/models/medical_record.dart';
import '../presentation/providers/patient_providers.dart';
import '../../../core/widgets/pdf_view_dialog.dart';

class MedicalVaultPage extends ConsumerWidget {
  const MedicalVaultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsState = ref.watch(patientPrescriptionsProvider);
    final labReportsState = ref.watch(patientLabReportsProvider);
    final imagingState = ref.watch(patientImagingReportsProvider);

    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);

    return DefaultTabController(
      length: 3,
      child: Container(
        color: t.bgMain,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: t.bgCard,
                border: Border(bottom: BorderSide(color: t.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tr('patient_medical_vault'),
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: t.textPrimary),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.refresh_rounded, color: t.brandPrimary),
                        tooltip: tr('patient_reload'),
                        onPressed: () {
                          ref.invalidate(patientPrescriptionsProvider);
                          ref.invalidate(patientLabReportsProvider);
                          ref.invalidate(patientImagingReportsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr('patient_reloaded')), duration: const Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('patient_vault_subtitle'),
                    style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    labelColor: t.brandPrimary,
                    unselectedLabelColor: t.textSecondary,
                    indicatorColor: t.brandPrimary,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                    tabs: [
                      Tab(text: tr('patient_tab_prescriptions')),
                      Tab(text: tr('patient_tab_lab_reports')),
                      Tab(text: tr('patient_tab_imaging')),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPrescriptionsTab(context, prescriptionsState, tr),
                  _buildLabReportsTab(context, labReportsState, tr),
                  _buildImagingTab(context, imagingState, tr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab(BuildContext context, AsyncValue<List<Prescription>> state, AppTranslations tr) {
    final t = AppColors.of(context);
    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
      error: (err, stack) => Center(
        child: Text('${tr('patient_err_loading_prescriptions')}: $err', style: TextStyle(color: t.textSecondary)),
      ),
      data: (prescriptions) {
        if (prescriptions.isEmpty) {
          return Center(
            child: Text(tr('patient_no_prescriptions_found'), style: GoogleFonts.inter(color: t.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: prescriptions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final prescription = prescriptions[index];
            final dateStr = "${prescription.date.day}/${prescription.date.month}/${prescription.date.year}";
            return _buildPrescriptionCard(context, prescription, dateStr, tr);
          },
        );
      },
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, Prescription p, String dateStr, AppTranslations tr) {
    final t = AppColors.of(context);
    final followUpText = p.followUpDate != null ? '${tr('patient_follow_up')}: ${p.followUpDate}' : tr('patient_no_follow_up');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_long_rounded, color: t.brandPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.diagnosis,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: t.textPrimary),
                    ),
                    Text(
                      '${p.doctorName} • ${p.doctorSpecialization}',
                      style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(dateStr, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.medicines.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: t.brandSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${m.name} ${m.dosage}',
                style: GoogleFonts.inter(color: t.brandSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.event_rounded, size: 14, color: t.warning),
              const SizedBox(width: 4),
              Text(
                followUpText,
                style: GoogleFonts.inter(color: t.warning, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              AppButton(
                label: tr('patient_view_details'),
                icon: Icons.visibility_rounded,
                variant: AppButtonVariant.outline,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                fontSize: 12,
                onPressed: () => _viewPrescriptionDetails(context, p),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabReportsTab(
    BuildContext context,
    AsyncValue<List<LabReport>> state,
    AppTranslations tr,
  ) {
    final t = AppColors.of(context);
    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
      error: (err, stack) => Center(
        child: Text('${tr('patient_err_loading_lab_reports')}: $err', style: TextStyle(color: t.textSecondary)),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Text(tr('patient_no_lab_reports_found'), style: GoogleFonts.inter(color: t.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
            return _buildLabReportCard(context, report, dateStr, tr);
          },
        );
      },
    );
  }

  Widget _buildLabReportCard(BuildContext context, LabReport report, String dateStr, AppTranslations tr) {
    final t = AppColors.of(context);
    final statusColor = report.status == 'Published' ? t.success : t.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: t.brandSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.science_rounded, color: t.brandSecondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.testName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary),
                ),
                Text(
                  '${tr('patient_category')}: ${report.category} • $dateStr',
                  style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(
              report.status,
              style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          if (report.status == 'Published') ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.visibility_rounded, size: 18, color: t.brandPrimary),
              onPressed: () => _viewLabReportDetails(context, report),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagingTab(BuildContext context, AsyncValue<List<ImagingReport>> state, AppTranslations tr) {
    final t = AppColors.of(context);
    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
      error: (err, stack) => Center(
        child: Text('${tr('patient_err_loading_imaging')}: $err', style: TextStyle(color: t.textSecondary)),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Text(tr('patient_no_imaging_found'), style: GoogleFonts.inter(color: t.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
            return _buildImagingReportCard(context, report, dateStr, tr);
          },
        );
      },
    );
  }

  Widget _buildImagingReportCard(BuildContext context, ImagingReport report, String dateStr, AppTranslations tr) {
    final t = AppColors.of(context);
    final iconData = report.type.contains('X-Ray') ? Icons.image_outlined : Icons.monitor_heart_rounded;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: t.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: t.brandPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.type,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary),
                ),
                Text('${report.hospitalName} • $dateStr', style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: t.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(
              tr('patient_reported'),
              style: GoogleFonts.inter(color: t.success, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.visibility_rounded, size: 18, color: t.brandPrimary),
            onPressed: () => _viewImagingReportDetails(context, report, tr),
          ),
        ],
      ),
    );
  }

  void _viewPrescriptionDetails(BuildContext context, Prescription p) {
    showDialog(
      context: context,
      builder: (context) => PdfViewDialog(
        title: 'Prescription_${p.id}.pdf',
        content: PrescriptionPdfView(prescription: p),
      ),
    );
  }

  void _viewLabReportDetails(BuildContext context, LabReport report) {
    showDialog(
      context: context,
      builder: (context) => PdfViewDialog(
        title: 'LabReport_${report.id}.pdf',
        content: LabReportPdfView(report: report),
      ),
    );
  }

  void _viewImagingReportDetails(BuildContext context, ImagingReport report, AppTranslations tr) {
    final t = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: t.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: t.border),
        ),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scan view panel
              Expanded(
                flex: 11,
                child: Container(
                  height: 480,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            report.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_outlined, color: t.textSecondary.withValues(alpha: 0.3), size: 56),
                                  const SizedBox(height: 12),
                                  Text(
                                    tr('patient_scan_placeholder'),
                                    style: GoogleFonts.inter(color: t.textSecondary.withValues(alpha: 0.4)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '${report.type} ${tr('patient_secure_mock')}',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Text reports details
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('patient_imaging_findings'),
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: t.textSecondary),
                        ),
                      ],
                    ),
                    Divider(color: t.border),
                    Text(
                      tr('patient_exam_details'),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text('${tr('patient_body_part')}: ${report.bodyPart}', style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    Text('${tr('patient_facility')}: ${report.hospitalName}', style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    Text('${tr('patient_referrer')}: ${report.doctorName}', style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    Text('${tr('patient_date')}: ${report.date.day}/${report.date.month}/${report.date.year}', style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    const SizedBox(height: 16),
                    Text(
                      tr('patient_findings'),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          report.findings,
                          style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: t.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('patient_impression'),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        report.impression,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: t.brandPrimary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          label: tr('patient_close'),
                          onPressed: () => Navigator.pop(context),
                          variant: AppButtonVariant.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
