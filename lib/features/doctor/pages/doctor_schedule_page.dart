import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DoctorSchedulePage extends StatelessWidget {
  const DoctorSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dates = ['15', '16', '17', '18', '19', '20', '21'];

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('My Schedule', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () {}),
                Text('June 2026', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () {}),
              ],
            ),
          ),
          // Week strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: AppColors.surface,
            child: Row(
              children: List.generate(7, (i) {
                final isToday = i == 1;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(days[i], style: GoogleFonts.inter(fontSize: 12, color: isToday ? Colors.white70 : AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(dates[i], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isToday ? Colors.white : AppColors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monday, June 16', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _timeSlotGroup('Morning (8:00 AM — 12:00 PM)', [
                    _scheduleItem('08:00', '08:15', 'Rahim Islam', 'Follow-up', 'Cardiology'),
                    _scheduleItem('08:15', '08:30', 'Karim Uddin', 'New Visit', 'Cardiology'),
                    _scheduleItem('08:30', '08:45', 'Fatima Begum', 'Follow-up', 'Cardiology'),
                    _scheduleItem('08:45', '09:00', 'Ali Khan', 'Post-Surgery', 'Cardiology'),
                    _scheduleItem('09:00', '09:15', 'Nusrat Jahan', 'New Visit', 'Cardiology'),
                    _scheduleItem('09:15', '09:30', 'Hasan Ali', 'Follow-up', 'Cardiology'),
                  ]),
                  const SizedBox(height: 24),
                  _timeSlotGroup('Afternoon (2:00 PM — 5:00 PM)', [
                    _scheduleItem('14:00', '14:15', 'Jamal Hossain', 'New Visit', 'Cardiology'),
                    _scheduleItem('14:15', '14:30', 'Sabina Akter', 'Follow-up', 'Cardiology'),
                    _scheduleItem('14:30', '14:45', 'Available Slot', '', '', isEmpty: true),
                    _scheduleItem('14:45', '15:00', 'Available Slot', '', '', isEmpty: true),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeSlotGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _scheduleItem(String start, String end, String patient, String type, String dept, {bool isEmpty = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isEmpty ? AppColors.background : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isEmpty ? AppColors.divider : AppColors.divider.withOpacity(0.5)),
        boxShadow: isEmpty ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text('$start — $end', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          if (!isEmpty) ...[
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(patient[0], style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(type, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(6)),
              child: Text(dept, style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
          ] else ...[
            const Icon(Icons.event_available_rounded, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(patient, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14, fontStyle: FontStyle.italic))),
          ],
        ],
      ),
    );
  }
}
