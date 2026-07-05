import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/widgets/ai_insight_panel.dart';
import '../../../core/widgets/notification_dropdown.dart';
import '../../../core/providers/notifications_provider.dart';
import '../../../core/providers/doctor_queue_provider.dart';
import '../presentation/providers/doctor_providers.dart';
import '../presentation/providers/clinical_workspace_provider.dart';
import '../data/models/patient_queue_item.dart';
import '../../../core/widgets/shimmer.dart';

class DoctorDashboardPage extends ConsumerWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final dashboardAsync = ref.watch(doctorDashboardProvider);
    final queue = ref.watch(doctorQueueProvider);
    final notifications = ref.watch(doctorNotificationsProvider);
    final profileAsync = ref.watch(doctorProfileProvider);
    final queueAsync = ref.watch(patientQueueProvider);

    // Sync database appointments queue to doctorQueueProvider
    ref.listen<AsyncValue<List<PatientQueueItem>>>(patientQueueProvider, (prev, next) {
      if (next.hasValue) {
        ref.read(doctorQueueProvider.notifier).setQueue(next.value!);
      }
    });

    // Handle initial load sync if already resolved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (queueAsync.hasValue && ref.read(doctorQueueProvider).isEmpty) {
        ref.read(doctorQueueProvider.notifier).setQueue(queueAsync.value!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
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
                    profileAsync.when(
                      data: (profile) => Text('${profile['fullName'] ?? 'Dr. Rahim Chowdhury'}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                      loading: () => Text(tr('doctor_dashboard_title'), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                      error: (_, __) => Text('Dr. Rahim Chowdhury', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    profileAsync.when(
                      data: (profile) => Text('${profile['specialization'] ?? 'Cardiology'} Department • ${profile['hospitalAffiliation'] ?? 'Dhaka Medical College Hospital'}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                      loading: () => Text(tr('doctor_loading_department'), style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                      error: (_, __) => Text('Cardiology Department • Dhaka Medical College Hospital', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  tooltip: tr('doctor_reload_dashboard'),
                  onPressed: () {
                    ref.invalidate(doctorDashboardProvider);
                    ref.invalidate(doctorNotificationsProvider);
                    ref.invalidate(doctorProfileProvider);
                    ref.invalidate(patientQueueProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('doctor_dashboard_reloaded')), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                NotificationDropdown(
                  notifications: notifications,
                  onMarkRead: (id) => ref.read(doctorNotificationsProvider.notifier).markAsRead(id),
                  onMarkAllRead: () => ref.read(doctorNotificationsProvider.notifier).markAllAsRead(),
                  onNavigate: (tabIndex) {
                    ref.read(doctorNavigationProvider.notifier).state = tabIndex;
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.primaryDark]),
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
                  // Dashboard summary & AI briefing
                  dashboardAsync.when(
                    data: (summary) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Row
                        Row(
                          children: [
                            _statCard(tr('doctor_stat_todays_patients'), summary.totalAppointments.toString(), Icons.people_rounded, AppColors.primary, tr('doctor_stat_todays_patients_sub')),
                            const SizedBox(width: 16),
                            _statCard(tr('doctor_stat_followups'), summary.totalFollowUps.toString(), Icons.replay_rounded, AppColors.secondary, tr('doctor_stat_followups_sub')),
                            const SizedBox(width: 16),
                            _statCard(tr('doctor_stat_emergency'), summary.emergencyCases.toString(), Icons.emergency_rounded, AppColors.danger, tr('doctor_stat_emergency_sub')),
                            const SizedBox(width: 16),
                            _statCard(tr('doctor_stat_pending_reports'), summary.pendingReports.toString(), Icons.science_rounded, AppColors.warning, tr('doctor_stat_pending_reports_sub')),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AiInsightPanel(
                          title: tr('doctor_ai_daily_briefing_title'),
                          description: summary.aiBriefing,
                          type: 'success',
                          recommendations: [
                            tr('doctor_ai_briefing_rec1'),
                            tr('doctor_ai_briefing_rec2'),
                            tr('doctor_ai_briefing_rec3'),
                          ],
                        ),
                      ],
                    ),
                    loading: () => Shimmer(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider.withOpacity(0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const ShimmerBox.circle(size: 32),
                                const SizedBox(width: 12),
                                const ShimmerBox(width: 180, height: 18),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const ShimmerBox(width: double.infinity, height: 14),
                            const SizedBox(height: 8),
                            const ShimmerBox(width: double.infinity, height: 14),
                            const SizedBox(height: 8),
                            const ShimmerBox(width: 250, height: 14),
                          ],
                        ),
                      ),
                    ),
                    error: (err, _) => Text('${tr('doctor_error_loading_summary')} $err'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Patient Queue Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr('doctor_patient_queue_today'), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600)),
                      if (queue.isNotEmpty)
                        Builder(builder: (context) {
                          final waitingCount = queue.where((p) => p.visitType != 'Emergency').length;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
                            child: Text('$waitingCount ${tr('doctor_waiting_count_suffix')}', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Patient Queue List
                  if (queue.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.event_available_rounded, size: 40, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(tr('doctor_queue_empty_title'), style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(tr('doctor_queue_empty_desc'), textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: queue.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = queue[index];
                        return _queueCard(context, ref, item, index == 0);
                      },
                    ),
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
            right: 4,
            top: 4,
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

  Widget _queueCard(BuildContext context, WidgetRef ref, PatientQueueItem item, bool isActive) {
    final tr = ref.watch(translationsProvider);
    final Color statusColor = isActive ? AppColors.info : AppColors.warning;
    final String statusText = isActive ? tr('doctor_status_in_consultation') : tr('doctor_status_waiting');

    Color riskColor = item.riskIndicator == 'Emergency' 
        ? AppColors.danger 
        : item.riskIndicator == 'High' 
            ? Colors.orange 
            : item.riskIndicator == 'Moderate' 
                ? AppColors.warning 
                : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? AppColors.primary.withOpacity(0.5) : AppColors.divider.withOpacity(0.5)),
        boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))] : null,
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 80,
            child: Text(item.time, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.name[0],
                style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(width: 8),
                    Text('${item.age} ${item.gender[0]}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.existingDiseases.map((c) => Container(
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
            child: Text(item.visitType, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          // Risk
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(item.riskIndicator, style: GoogleFonts.inter(color: riskColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(statusText, style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),
          // Action Button
          ElevatedButton(
            onPressed: () {
              // Initialize Workspace Provider with this patient's details
              ref.read(clinicalWorkspaceProvider.notifier).initializePatient(item.id, item.healthId, item.name);
              // Switch tab to Clinical Workspace (Index 1)
              ref.read(doctorNavigationProvider.notifier).state = 1;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.primary : Colors.grey.shade200,
              foregroundColor: isActive ? Colors.white : AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isActive ? tr('doctor_btn_continue') : tr('doctor_btn_start'), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
