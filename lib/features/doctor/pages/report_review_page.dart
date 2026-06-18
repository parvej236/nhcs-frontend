import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ReportReviewPage extends StatelessWidget {
  const ReportReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('Report Review', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                _filterChip('All', true),
                const SizedBox(width: 8),
                _filterChip('Pending', false),
                const SizedBox(width: 8),
                _filterChip('Reviewed', false),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pending Reports (3)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _reportCard('Rahim Islam', 'HbA1c', 'Blood', 'Jun 14, 2026', true, {'HbA1c': '7.8%', 'Previous': '7.2%', 'Change': '+8.3%', 'Trend': 'Worsening'}),
                  const SizedBox(height: 12),
                  _reportCard('Fatima Begum', 'Lipid Profile', 'Blood', 'Jun 14, 2026', true, {'LDL': '165 mg/dL', 'HDL': '42 mg/dL', 'Total': '240 mg/dL', 'Trend': 'Elevated'}),
                  const SizedBox(height: 12),
                  _reportCard('Ali Khan', 'Post-Op ECG', 'Cardiology', 'Jun 13, 2026', true, {'Rhythm': 'Sinus', 'Rate': '82 bpm', 'ST Segment': 'Normal', 'Trend': 'Stable'}),
                  const SizedBox(height: 32),
                  Text('Recently Reviewed', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _reportCard('Karim Uddin', 'Chest X-Ray', 'Radiology', 'Jun 10, 2026', false, {'Findings': 'Clear lungs', 'Heart Size': 'Normal', 'Trend': 'Normal'}),
                  const SizedBox(height: 12),
                  _reportCard('Nusrat Jahan', 'CBC', 'Blood', 'Jun 9, 2026', false, {'WBC': '7.2', 'RBC': '4.8', 'Hb': '13.5', 'Trend': 'Normal'}),
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
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.textSecondary)),
    );
  }

  Widget _reportCard(String patient, String testName, String category, String date, bool pending, Map<String, String> results) {
    Color trendColor = AppColors.success;
    if (results['Trend'] == 'Worsening') trendColor = AppColors.danger;
    if (results['Trend'] == 'Elevated') trendColor = AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pending ? AppColors.warning.withOpacity(0.3) : AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(patient[0], style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text('$testName • $category', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Text(date, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (pending ? AppColors.warning : AppColors.success).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(pending ? 'Pending' : 'Reviewed', style: GoogleFonts.inter(color: pending ? AppColors.warning : AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Results
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: results.entries.map((e) {
                if (e.key == 'Trend') {
                  return Expanded(
                    child: Column(
                      children: [
                        Text(e.key, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: trendColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(e.value, style: GoogleFonts.inter(color: trendColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                }
                return Expanded(
                  child: Column(
                    children: [
                      Text(e.key, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(e.value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (pending) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('View Full Report')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Mark as Reviewed')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
