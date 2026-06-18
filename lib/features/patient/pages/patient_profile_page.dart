import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Profile', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _profileHeader(),
                      const SizedBox(height: 20),
                      _infoSection('Personal Information', [
                        _infoRow('Full Name', 'Rahim Islam'),
                        _infoRow('Date of Birth', '15 March 1984'),
                        _infoRow('Gender', 'Male'),
                        _infoRow('Blood Group', 'O+'),
                        _infoRow('National ID', '199084XXXXXXXX'),
                        _infoRow('Marital Status', 'Married'),
                        _infoRow('Occupation', 'Business'),
                        _infoRow('Religion', 'Islam'),
                      ]),
                      const SizedBox(height: 20),
                      _infoSection('Address', [
                        _infoRow('Present', 'House 12, Road 5, Dhanmondi, Dhaka'),
                        _infoRow('Permanent', 'Village Kashipur, Upazila Savar, District Dhaka'),
                      ]),
                      const SizedBox(height: 20),
                      _infoSection('Emergency Contacts', [
                        _contactRow('Salma Islam', 'Wife', '+880 17XX-XXXXXX'),
                        _contactRow('Karim Islam', 'Brother', '+880 19XX-XXXXXX'),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _medicalSection('Allergies', [
                        _allergyChip('Penicillin', 'Severe', AppColors.danger),
                        _allergyChip('Sulfa Drugs', 'Moderate', AppColors.warning),
                      ]),
                      const SizedBox(height: 20),
                      _medicalSection('Chronic Diseases', [
                        _diseaseRow('Type 2 Diabetes', 'Diagnosed 2021', 'Active'),
                        _diseaseRow('Hypertension', 'Diagnosed 2022', 'Active'),
                      ]),
                      const SizedBox(height: 20),
                      _medicalSection('Current Medications', [
                        _medRow('Metformin 500mg', 'Twice daily', 'Dr. Fatima'),
                        _medRow('Amlodipine 5mg', 'Once daily', 'Dr. Ahmed'),
                        _medRow('Aspirin 75mg', 'Once daily', 'Dr. Ahmed'),
                      ]),
                      const SizedBox(height: 20),
                      _medicalSection('Vaccination History', [
                        _vaccineRow('COVID-19 (Pfizer)', 'Dose 3', 'Mar 2022'),
                        _vaccineRow('Hepatitis B', 'Complete', 'Jan 2020'),
                        _vaccineRow('Influenza', 'Annual', 'Oct 2025'),
                      ]),
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

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rahim Islam', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Health ID: NUD-892-441-X7', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                  child: Text('Organ Donor ❤️', style: GoogleFonts.inter(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit_rounded, size: 16), label: const Text('Edit Profile')),
        ],
      ),
    );
  }

  Widget _infoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _contactRow(String name, String relation, String phone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.emergency_rounded, size: 18, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(child: Text('$name ($relation)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500))),
          Text(phone, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _medicalSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _allergyChip(String name, String severity, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: color, size: 18),
        const SizedBox(width: 10),
        Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
          child: Text(severity, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _diseaseRow(String name, String diagnosed, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.monitor_heart_rounded, size: 18, color: AppColors.danger),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(diagnosed, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(4)),
          child: Text(status, style: GoogleFonts.inter(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _medRow(String name, String freq, String doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.medication_rounded, size: 18, color: AppColors.secondary),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
          Text('$freq • $doctor', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _vaccineRow(String name, String dose, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.vaccines_rounded, size: 18, color: AppColors.success),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
          Text('$dose • $date', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
        ])),
      ]),
    );
  }
}
