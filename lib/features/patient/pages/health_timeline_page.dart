import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class HealthTimelinePage extends StatelessWidget {
  const HealthTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('Health Timeline', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                _filterChip('All', true),
                const SizedBox(width: 8),
                _filterChip('Consultations', false),
                const SizedBox(width: 8),
                _filterChip('Lab Tests', false),
                const SizedBox(width: 8),
                _filterChip('Imaging', false),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _yearLabel('2026'),
                  _timelineItem(
                    'Cardiology Consultation',
                    'Follow-up for hypertension management. Blood pressure elevated.',
                    'Jun 15, 2026',
                    'Dr. Ahmed • Dhaka Central Hospital',
                    Icons.medical_services_rounded,
                    AppColors.primary,
                    isFirst: true,
                  ),
                  _timelineItem(
                    'Complete Blood Count (CBC)',
                    'Routine blood work. All values within normal range.',
                    'Jun 10, 2026',
                    'Dhaka Central Hospital Lab',
                    Icons.science_rounded,
                    AppColors.secondary,
                  ),
                  _timelineItem(
                    'Lipid Profile Test',
                    'Cholesterol levels slightly elevated. LDL: 145 mg/dL.',
                    'Jun 8, 2026',
                    'Dhaka Central Hospital Lab',
                    Icons.science_rounded,
                    AppColors.warning,
                  ),
                  _timelineItem(
                    'ECG Test',
                    'Electrocardiogram performed. Normal sinus rhythm detected.',
                    'Jun 5, 2026',
                    'Cardiology Diagnostics',
                    Icons.monitor_heart_rounded,
                    AppColors.info,
                  ),
                  _timelineItem(
                    'General Checkup',
                    'Annual health checkup. Diabetes management reviewed.',
                    'May 20, 2026',
                    'Dr. Fatima • National Medical Center',
                    Icons.medical_services_rounded,
                    AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _yearLabel('2025'),
                  _timelineItem(
                    'Medication Adjustment',
                    'Metformin dosage increased from 250mg to 500mg.',
                    'Nov 12, 2025',
                    'Dr. Ahmed • Dhaka Central Hospital',
                    Icons.medication_rounded,
                    Colors.orange,
                  ),
                  _timelineItem(
                    'Eye Examination',
                    'Diabetic retinopathy screening. No abnormalities found.',
                    'Sep 5, 2025',
                    'Dr. Hassan • Eye Care Center',
                    Icons.visibility_rounded,
                    Colors.purple,
                  ),
                  _timelineItem(
                    'Diabetes Follow-up',
                    'HbA1c: 7.2%. Blood glucose trending upward.',
                    'Jul 18, 2025',
                    'Dr. Fatima • National Medical Center',
                    Icons.medical_services_rounded,
                    AppColors.danger,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _yearLabel(String year) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(year, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
    );
  }

  Widget _timelineItem(String title, String description, String date, String source, IconData icon, Color color, {bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst) Container(width: 2, height: 12, color: AppColors.divider),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: AppColors.divider)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15))),
                      Text(date, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(source, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
