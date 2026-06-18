import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

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
                Text('Appointments', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Book New'),
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
                  // Tab bar
                  Row(
                    children: [
                      _tab('Upcoming', true),
                      const SizedBox(width: 8),
                      _tab('Past', false),
                      const SizedBox(width: 8),
                      _tab('Cancelled', false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _appointmentCard('Dr. Ahmed', 'Cardiology', 'Tomorrow, 10:30 AM', 'Dhaka Central Hospital', 'SCHEDULED', AppColors.info, 'Queue: #4'),
                  const SizedBox(height: 16),
                  _appointmentCard('Dr. Fatima', 'Endocrinology', 'Jun 22, 2:00 PM', 'National Medical Center', 'SCHEDULED', AppColors.info, 'Queue: #2'),
                  const SizedBox(height: 16),
                  _appointmentCard('Dr. Hasan', 'Ophthalmology', 'Jun 28, 11:00 AM', 'Eye Care Center', 'SCHEDULED', AppColors.info, 'Queue: #7'),
                  const SizedBox(height: 32),
                  // Doctor search section
                  Text('Find a Doctor', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by doctor name or specialization...',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: 'All Specializations',
                              items: ['All Specializations', 'Cardiology', 'Endocrinology', 'Neurology', 'Orthopedics']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 14))))
                                  .toList(),
                              onChanged: (_) {},
                              isExpanded: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Doctor results
                  _doctorCard('Dr. Ahmed Rahman', 'Cardiology', '15 years exp.', '৳800', 4.8),
                  const SizedBox(height: 12),
                  _doctorCard('Dr. Fatima Begum', 'Endocrinology', '12 years exp.', '৳600', 4.7),
                  const SizedBox(height: 12),
                  _doctorCard('Dr. Karim Uddin', 'Neurology', '20 years exp.', '৳1000', 4.9),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? AppColors.primary : AppColors.divider),
      ),
      child: Text(label, style: GoogleFonts.inter(color: active ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 14)),
    );
  }

  Widget _appointmentCard(String doctor, String specialty, String time, String hospital, String status, Color statusColor, String queue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                Text(specialty, style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(time, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(hospital, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Text(queue, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextButton(onPressed: () {}, child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorCard(String name, String specialty, String exp, String fee, double rating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.secondary, Color(0xFF0EA5E9)]), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(specialty, style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(exp, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    Text(' $rating', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fee, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: GoogleFonts.inter(fontSize: 13)), child: const Text('Book')),
            ],
          ),
        ],
      ),
    );
  }
}
