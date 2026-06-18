import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class MedicalVaultPage extends StatelessWidget {
  const MedicalVaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medical Vault', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('All your medical records in one secure place', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 20),
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textMuted,
                    indicatorColor: AppColors.primary,
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
                  _prescriptionsTab(),
                  _labReportsTab(),
                  _imagingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prescriptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _prescriptionItem('Hypertension Management', 'Dr. Ahmed • Cardiology', 'Jun 15, 2026', ['Amlodipine 5mg', 'Aspirin 75mg'], 'Follow-up: Jul 1'),
          const SizedBox(height: 12),
          _prescriptionItem('Diabetes Care Plan', 'Dr. Fatima • Endocrinology', 'May 20, 2026', ['Metformin 500mg', 'Glimepiride 2mg'], 'Follow-up: Jun 22'),
          const SizedBox(height: 12),
          _prescriptionItem('General Checkup', 'Dr. Ahmed • Cardiology', 'Apr 10, 2026', ['Omeprazole 20mg'], 'Follow-up: May 10'),
        ],
      ),
    );
  }

  Widget _prescriptionItem(String diagnosis, String doctor, String date, List<String> medicines, String followUp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(diagnosis, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(doctor, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Text(date, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: medicines.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(8)),
              child: Text(m, style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(followUp, style: GoogleFonts.inter(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('PDF'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), textStyle: GoogleFonts.inter(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _labReportItem('Complete Blood Count (CBC)', 'Blood', 'Jun 10, 2026', 'Published', AppColors.success),
          const SizedBox(height: 12),
          _labReportItem('Lipid Profile', 'Blood', 'Jun 8, 2026', 'Published', AppColors.success),
          const SizedBox(height: 12),
          _labReportItem('HbA1c', 'Blood', 'Jun 5, 2026', 'Published', AppColors.success),
          const SizedBox(height: 12),
          _labReportItem('Liver Function Test', 'Blood', 'Jun 15, 2026', 'Processing', AppColors.warning),
          const SizedBox(height: 12),
          _labReportItem('Kidney Function Test', 'Blood', 'Jun 15, 2026', 'Ordered', AppColors.info),
        ],
      ),
    );
  }

  Widget _labReportItem(String name, String category, String date, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.science_rounded, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Category: $category • $date', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          if (status == 'Published') ...[
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.visibility_rounded, size: 18, color: AppColors.primary), onPressed: () {}),
          ],
        ],
      ),
    );
  }

  Widget _imagingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _imagingItem('ECG', 'Cardiology Diagnostics', 'Jun 5, 2026', 'Reported', Icons.monitor_heart_rounded),
          const SizedBox(height: 12),
          _imagingItem('Chest X-Ray', 'Radiology Dept', 'May 15, 2026', 'Reported', Icons.image_rounded),
          const SizedBox(height: 12),
          _imagingItem('Abdominal Ultrasound', 'Radiology Dept', 'Apr 20, 2026', 'Reported', Icons.image_rounded),
        ],
      ),
    );
  }

  Widget _imagingItem(String name, String source, String date, String status, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('$source • $date', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: GoogleFonts.inter(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.visibility_rounded, size: 18, color: AppColors.primary), onPressed: () {}),
        ],
      ),
    );
  }
}
