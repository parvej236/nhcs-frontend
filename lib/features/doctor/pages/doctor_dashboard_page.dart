import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Morning, Dr. Ahmed', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Cardiology Department • Dhaka Central Hospital', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                _headerIcon(Icons.notifications_none_rounded, badge: '5'),
                const SizedBox(width: 8),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.secondary, Color(0xFF0EA5E9)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _statCard('Today\'s Patients', '32', Icons.people_rounded, AppColors.primary, '+4 from yesterday'),
                      const SizedBox(width: 16),
                      _statCard('Follow-ups', '7', Icons.replay_rounded, AppColors.secondary, '2 overdue'),
                      const SizedBox(width: 16),
                      _statCard('Emergency', '2', Icons.emergency_rounded, AppColors.danger, '1 critical'),
                      const SizedBox(width: 16),
                      _statCard('Pending Reports', '12', Icons.science_rounded, AppColors.warning, '3 new today'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // AI Briefing
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentLight, AppColors.accentLight.withOpacity(0.3)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Daily Briefing', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.accent)),
                              const SizedBox(height: 6),
                              Text(
                                'Today you have 32 patients scheduled. Key highlights: 7 diabetes cases requiring glucose review, '
                                '5 hypertension follow-ups, 2 high-risk cardiac patients (Rahim Islam — elevated BP trend, Ali Khan — post-surgery). '
                                '1 emergency review pending from last night.',
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Patient Queue
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Patient Queue — Today', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
                        child: Text('6 waiting • 2 in progress', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _queueCard('Rahim Islam', '45', 'Male', '08:00 AM', 'Follow-up', ['Diabetes', 'Hypertension'], 'Moderate', 'IN_CONSULTATION', AppColors.info),
                  const SizedBox(height: 12),
                  _queueCard('Karim Uddin', '38', 'Male', '08:15 AM', 'New Visit', ['Asthma'], 'Low', 'WAITING', AppColors.warning),
                  const SizedBox(height: 12),
                  _queueCard('Fatima Begum', '52', 'Female', '08:30 AM', 'Follow-up', ['Cardiac', 'Diabetes'], 'High', 'WAITING', AppColors.warning),
                  const SizedBox(height: 12),
                  _queueCard('Ali Khan', '60', 'Male', '08:45 AM', 'Post-Surgery', ['Coronary Bypass'], 'Critical', 'WAITING', AppColors.warning),
                  const SizedBox(height: 12),
                  _queueCard('Nusrat Jahan', '28', 'Female', '09:00 AM', 'New Visit', ['Chest Pain'], 'Moderate', 'SCHEDULED', AppColors.textMuted),
                  const SizedBox(height: 12),
                  _queueCard('Hasan Ali', '35', 'Male', '09:15 AM', 'Follow-up', ['Hypertension'], 'Low', 'SCHEDULED', AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon, {String? badge}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        if (badge != null)
          Positioned(
            right: 4, top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
              child: Text(badge, style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, String sub) {
    return Expanded(
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(sub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _queueCard(String name, String age, String gender, String time, String visitType, List<String> conditions, String risk, String status, Color statusColor) {
    Color riskColor = risk == 'Critical' ? AppColors.danger : risk == 'High' ? Colors.orange : risk == 'Moderate' ? AppColors.warning : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: status == 'IN_CONSULTATION' ? AppColors.primary.withOpacity(0.3) : AppColors.divider.withOpacity(0.5)),
        boxShadow: status == 'IN_CONSULTATION' ? [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8)] : null,
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 70,
            child: Text(time, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(name[0], style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(width: 8),
                    Text('$age$gender[0]', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: conditions.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(4)),
                    child: Text(c, style: GoogleFonts.inter(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
              ],
            ),
          ),
          // Visit type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
            child: Text(visitType, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          // Risk
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(risk, style: GoogleFonts.inter(color: riskColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(status.replaceAll('_', ' '), style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          // Action
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: Text(status == 'IN_CONSULTATION' ? 'Continue' : 'Start'),
          ),
        ],
      ),
    );
  }
}
