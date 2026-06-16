import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ClinicalWorkspacePage extends StatelessWidget {
  const ClinicalWorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('Clinical Workspace', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: Text('Patient: Rahim Islam', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Submit Treatment'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          // Split screen
          Expanded(
            child: Row(
              children: [
                // LEFT: Patient History
                Expanded(
                  flex: 5,
                  child: Container(
                    color: AppColors.background,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _patientSummaryCard(),
                          const SizedBox(height: 16),
                          _aiClinicalSummary(),
                          const SizedBox(height: 16),
                          _sectionTitle('Health Timeline'),
                          _miniTimeline(),
                          const SizedBox(height: 16),
                          _sectionTitle('Previous Prescriptions'),
                          _prevPrescription('Hypertension Mgmt', 'May 20, 2026', ['Amlodipine 5mg', 'Aspirin 75mg']),
                          const SizedBox(height: 8),
                          _prevPrescription('Diabetes Care', 'Apr 10, 2026', ['Metformin 500mg']),
                          const SizedBox(height: 16),
                          _sectionTitle('Lab Reports'),
                          _labReportMini('CBC', 'Jun 10', 'Normal', AppColors.success),
                          _labReportMini('Lipid Profile', 'Jun 8', 'LDL Elevated', AppColors.warning),
                          _labReportMini('HbA1c', 'Jun 5', '7.2% — Worsening', AppColors.danger),
                        ],
                      ),
                    ),
                  ),
                ),
                // Divider
                Container(width: 1, color: AppColors.divider),
                // RIGHT: Treatment Form
                Expanded(
                  flex: 5,
                  child: Container(
                    color: AppColors.surface,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _formSection('Symptoms', Icons.edit_note_rounded),
                          TextField(
                            maxLines: 3,
                            decoration: InputDecoration(hintText: 'Describe patient symptoms...', hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
                          ),
                          const SizedBox(height: 20),
                          _formSection('Clinical Notes', Icons.note_alt_rounded),
                          TextField(
                            maxLines: 3,
                            decoration: InputDecoration(hintText: 'Add clinical observations...', hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
                          ),
                          const SizedBox(height: 20),
                          _formSection('Diagnosis', Icons.medical_information_rounded),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search ICD codes or type diagnosis...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _diagnosisChip('Hypertension (I10)'),
                              _diagnosisChip('Type 2 Diabetes (E11)'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _formSection('Prescription', Icons.medication_rounded),
                          _medicineRow(),
                          const SizedBox(height: 8),
                          _medicineRow2(),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text('Add Medicine', style: GoogleFonts.inter(fontSize: 13)),
                          ),
                          const SizedBox(height: 20),
                          _formSection('Investigations', Icons.science_rounded),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _testCheckbox('Blood Glucose', true),
                              _testCheckbox('HbA1c', true),
                              _testCheckbox('ECG', false),
                              _testCheckbox('Lipid Profile', false),
                              _testCheckbox('Renal Function', false),
                              _testCheckbox('Chest X-Ray', false),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _formSection('Follow-up', Icons.event_rounded),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Select follow-up date...',
                              prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                              hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _formSection('Referral (Optional)', Icons.send_rounded),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search specialist for referral...',
                              prefixIcon: const Icon(Icons.person_search_rounded, size: 20),
                              hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // AI alerts
                          _aiAlert('⚠️ Drug Interaction', 'Aspirin may interact with Glimepiride — monitor blood sugar closely.', AppColors.warning),
                          const SizedBox(height: 8),
                          _aiAlert('🔴 Allergy Alert', 'Patient has recorded Penicillin allergy. Avoid Amoxicillin derivatives.', AppColors.danger),
                          const SizedBox(height: 8),
                          _aiAlert('ℹ️ Suggestion', 'Recent ECG not available. Consider ordering ECG before finalizing treatment.', AppColors.info),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rahim Islam', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('45 years • Male • O+ • ID: NUD-892-441-X7', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                child: Text('Moderate Risk', style: GoogleFonts.inter(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem('Conditions', 'Diabetes, HTN'),
                Container(width: 1, height: 24, color: Colors.white24),
                _summaryItem('Allergies', 'Penicillin'),
                Container(width: 1, height: 24, color: Colors.white24),
                _summaryItem('Meds', 'Metformin, Amlo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _aiClinicalSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Clinical Summary', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.accent)),
                const SizedBox(height: 4),
                Text(
                  'Patient under diabetes treatment for 5 years. Blood glucose increased 12% over last 3 visits. '
                  'Medication compliance appears inconsistent. One follow-up was missed.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _miniTimeline() {
    return Column(
      children: [
        _miniTimelineItem('Cardiology Consultation', 'Jun 15, 2026', AppColors.primary),
        _miniTimelineItem('CBC Test', 'Jun 10, 2026', AppColors.secondary),
        _miniTimelineItem('Lipid Profile', 'Jun 8, 2026', AppColors.warning),
        _miniTimelineItem('General Checkup', 'May 20, 2026', AppColors.primary),
      ],
    );
  }

  Widget _miniTimelineItem(String title, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))),
          Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _prevPrescription(String title, String date, List<String> meds) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Text(date, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 6, children: meds.map((m) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(4)),
            child: Text(m, style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary)),
          )).toList()),
        ],
      ),
    );
  }

  Widget _labReportMini(String name, String date, String result, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider.withOpacity(0.3))),
      child: Row(
        children: [
          const Icon(Icons.science_rounded, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(result, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _formSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _diagnosisChip(String label) {
    return Chip(
      label: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
      backgroundColor: AppColors.primaryLight,
      deleteIcon: const Icon(Icons.close_rounded, size: 14),
      onDeleted: () {},
      side: BorderSide.none,
    );
  }

  Widget _medicineRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(child: TextField(decoration: InputDecoration(hintText: 'Medicine name', hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: TextField(decoration: InputDecoration(hintText: 'Dosage', hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: TextField(decoration: InputDecoration(hintText: 'Frequency', hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: TextField(decoration: InputDecoration(hintText: 'Days', hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _medicineRow2() => _medicineRow();

  Widget _testCheckbox(String label, bool checked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: checked ? AppColors.primaryLight : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: checked ? AppColors.primary.withOpacity(0.3) : AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 18, color: checked ? AppColors.primary : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: checked ? AppColors.primary : AppColors.textSecondary, fontWeight: checked ? FontWeight.w500 : FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _aiAlert(String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
