import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_primitives.dart';
import '../data/models/medical_record.dart';
import '../presentation/providers/patient_providers.dart';

class MedicalVaultPage extends ConsumerWidget {
  const MedicalVaultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsState = ref.watch(patientPrescriptionsProvider);
    final labReportsState = ref.watch(patientLabReportsProvider);
    final imagingState = ref.watch(patientImagingReportsProvider);
    final t = AppColors.of(context);

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
                  Text(
                    'Medical Vault',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: t.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All your medical records in one secure place',
                    style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    labelColor: t.brandPrimary,
                    unselectedLabelColor: t.textSecondary,
                    indicatorColor: t.brandPrimary,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Prescriptions'),
                      Tab(text: 'Lab Reports'),
                      Tab(text: 'Imaging'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPrescriptionsTab(context, prescriptionsState),
                  _buildLabReportsTab(context, labReportsState),
                  _buildImagingTab(context, imagingState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab(BuildContext context, AsyncValue<List<Prescription>> state) {
    final t = AppColors.of(context);
    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
      error: (err, stack) => Center(
        child: Text('Error loading prescriptions: $err', style: TextStyle(color: t.textSecondary)),
      ),
      data: (prescriptions) {
        if (prescriptions.isEmpty) {
          return Center(
            child: Text('No prescriptions found.', style: GoogleFonts.inter(color: t.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: prescriptions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final prescription = prescriptions[index];
            final dateStr = "${prescription.date.day}/${prescription.date.month}/${prescription.date.year}";
            return _buildPrescriptionCard(context, prescription, dateStr);
          },
        );
      },
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, Prescription p, String dateStr) {
    final t = AppColors.of(context);
    final followUpText = p.followUpDate != null ? 'Follow-up: ${p.followUpDate}' : 'No follow-up scheduled';

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
                label: 'View details',
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

  Widget _buildLabReportsTab(BuildContext context, AsyncValue<List<LabReport>> state) {
    final t = AppColors.of(context);
    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
      error: (err, stack) => Center(
        child: Text('Error loading lab reports: $err', style: TextStyle(color: t.textSecondary)),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Text('No lab reports found.', style: GoogleFonts.inter(color: t.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
            return _buildLabReportCard(context, report, dateStr);
          },
        );
      },
    );
  }

  Widget _buildLabReportCard(BuildContext context, LabReport report, String dateStr) {
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
                  'Category: ${report.category} • $dateStr',
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

  Widget _buildImagingTab(BuildContext context, AsyncValue<List<ImagingReport>> state) {
    final t = AppColors.of(context);
    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
      error: (err, stack) => Center(
        child: Text('Error loading imaging reports: $err', style: TextStyle(color: t.textSecondary)),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Text('No imaging reports found.', style: GoogleFonts.inter(color: t.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
            return _buildImagingReportCard(context, report, dateStr);
          },
        );
      },
    );
  }

  Widget _buildImagingReportCard(BuildContext context, ImagingReport report, String dateStr) {
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
              'Reported',
              style: GoogleFonts.inter(color: t.success, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.visibility_rounded, size: 18, color: t.brandPrimary),
            onPressed: () => _viewImagingReportDetails(context, report),
          ),
        ],
      ),
    );
  }

  void _viewPrescriptionDetails(BuildContext context, Prescription p) {
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
          width: 650,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prescription Details',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: t.textSecondary),
                  ),
                ],
              ),
              Divider(color: t.border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.doctorName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: t.brandPrimary),
                      ),
                      Text(p.doctorSpecialization, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13)),
                      Text(p.hospitalName, style: GoogleFonts.inter(color: t.textSecondary.withValues(alpha: 0.7), fontSize: 12)),
                    ],
                  ),
                  Text(
                    "${p.date.day}/${p.date.month}/${p.date.year}",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: t.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Diagnosis: ${p.diagnosis}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                'Medicines:',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textSecondary),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: p.medicines.length,
                  separatorBuilder: (context, index) => Divider(color: t.border),
                  itemBuilder: (context, index) {
                    final med = p.medicines[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: t.brandSecondary),
                              const SizedBox(width: 8),
                              Text(
                                '${med.name} (${med.dosage})',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: t.textPrimary),
                              ),
                              const Spacer(),
                              Text(
                                med.duration,
                                style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              med.instruction,
                              style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (p.clinicalNotes.isNotEmpty) ...[
                Text(
                  'Clinical Notes:',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  p.clinicalNotes,
                  style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary, height: 1.5),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Prescription PDF download initiated.'),
                          backgroundColor: t.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.brandPrimary,
                      side: BorderSide(color: t.brandPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'Close',
                    onPressed: () => Navigator.pop(context),
                    variant: AppButtonVariant.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewLabReportDetails(BuildContext context, LabReport report) {
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
          width: 750,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lab Report Result',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: t.textSecondary),
                  ),
                ],
              ),
              Divider(color: t.border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.testName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: t.brandSecondary),
                      ),
                      Text(
                        'Prescribed by: ${report.doctorName}',
                        style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
                      ),
                      Text(
                        'Facility: ${report.hospitalName}',
                        style: GoogleFonts.inter(color: t.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    "${report.date.day}/${report.date.month}/${report.date.year}",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: t.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (report.aiInterpretation.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: t.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: t.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Clinical Insight',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.warning),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              report.aiInterpretation,
                              style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Container(
                color: t.bgInput,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Parameter', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.textPrimary))),
                    Expanded(child: Text('Value', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.textPrimary))),
                    Expanded(child: Text('Unit', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.textPrimary))),
                    Expanded(flex: 2, child: Text('Ref. Range', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.textPrimary))),
                  ],
                ),
              ),
              Divider(height: 1, color: t.border),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: report.results.length,
                  itemBuilder: (context, index) {
                    final res = report.results[index];
                    final isAbnormal = res.status != 'Normal';
                    final valColor = isAbnormal ? t.danger : t.textPrimary;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(res.parameter, style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary))),
                          Expanded(
                            child: Text(
                              res.value,
                              style: GoogleFonts.inter(
                                fontSize: 13, 
                                fontWeight: isAbnormal ? FontWeight.bold : FontWeight.normal,
                                color: valColor,
                              ),
                            ),
                          ),
                          Expanded(child: Text(res.unit, style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary))),
                          Expanded(
                            flex: 2, 
                            child: Row(
                              children: [
                                Text(res.referenceRange, style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                                if (isAbnormal) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      'High',
                                      style: GoogleFonts.inter(color: t.danger, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('Report data exported to CSV.'), backgroundColor: t.success),
                      );
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share/Export'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.brandPrimary,
                      side: BorderSide(color: t.brandPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'Close',
                    onPressed: () => Navigator.pop(context),
                    variant: AppButtonVariant.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewImagingReportDetails(BuildContext context, ImagingReport report) {
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
                                    'Scan Image Placeholder',
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
                            '${report.type} (SECURE MOCK)',
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
                          'Imaging Findings',
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
                      'Exam Details:',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: t.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text('Body Part: ${report.bodyPart}', style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    Text('Facility: ${report.hospitalName}', style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    Text('Referrer: ${report.doctorName}', style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    Text('Date: ${report.date.day}/${report.date.month}/${report.date.year}', style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    const SizedBox(height: 16),
                    Text(
                      'Findings:',
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
                      'Impression:',
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
                          label: 'Close',
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
