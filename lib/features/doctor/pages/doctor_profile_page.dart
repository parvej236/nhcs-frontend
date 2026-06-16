import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Professional Profile', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.secondary, Color(0xFF0EA5E9)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 50),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Dr. Ahmed Rahman', style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Verified', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('MBBS, MD (Cardiology), FCPS', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('BMDC Reg: A-12345 • 15 years experience', style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                    label: Text('Edit', style: GoogleFonts.inter(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.3))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    children: [
                      _section('Professional Information', [
                        _infoRow('Full Name', 'Dr. Ahmed Rahman'),
                        _infoRow('Specialization', 'Cardiology'),
                        _infoRow('Sub-Specialization', 'Interventional Cardiology'),
                        _infoRow('BMDC Registration', 'A-12345'),
                        _infoRow('License Status', 'Active (Valid until Dec 2028)'),
                        _infoRow('Experience', '15 years'),
                        _infoRow('Languages', 'Bengali, English, Hindi'),
                      ]),
                      const SizedBox(height: 20),
                      _section('Education & Degrees', [
                        _degreeRow('MBBS', 'Dhaka Medical College', '2008'),
                        _degreeRow('MD (Cardiology)', 'BSMMU', '2013'),
                        _degreeRow('FCPS', 'BCPS', '2016'),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right column
                Expanded(
                  child: Column(
                    children: [
                      _section('Hospital Affiliations', [
                        _affiliationRow('Dhaka Central Hospital', 'Senior Consultant', 'Cardiology Dept', 'Active'),
                        _affiliationRow('National Heart Foundation', 'Visiting Consultant', 'Interventional', 'Active'),
                      ]),
                      const SizedBox(height: 20),
                      _section('Performance Summary', [
                        _statRow('Total Patients Treated', '12,450'),
                        _statRow('This Month', '248'),
                        _statRow('Follow-up Compliance', '87%'),
                        _statRow('Average Rating', '4.8 / 5.0'),
                      ]),
                      const SizedBox(height: 20),
                      _section('Certifications', [
                        _certRow('Advanced Cardiac Life Support', 'AHA', 'Valid'),
                        _certRow('Echocardiography', 'ASE', 'Valid'),
                        _certRow('Interventional Cardiology Fellowship', 'ACC', 'Completed'),
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

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _degreeRow(String degree, String institution, String year) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.school_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(degree, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(institution, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
          ])),
          Text(year, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _affiliationRow(String hospital, String role, String dept, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.local_hospital_rounded, size: 18, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(hospital, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            Text('$role • $dept', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: GoogleFonts.inter(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _certRow(String name, String org, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13)),
            Text(org, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: GoogleFonts.inter(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
