import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uhcs/features/patient/data/models/appointment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../presentation/providers/hospital_providers.dart';

/// Standalone hospital section for verifying and approving citizen appointment
/// requests. Previously an in-page sub-tab of the Command Center; now its own
/// sidebar destination.
class AppointmentApprovalsPage extends ConsumerWidget {
  const AppointmentApprovalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingState = ref.watch(pendingAppointmentsProvider);
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          Expanded(
            child: pendingState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, stack) => Center(
                child: Text(
                  '${tr('hospital_appr_error_loading')} $err',
                  style: GoogleFonts.inter(color: t.danger),
                ),
              ),
              data: (appointments) {
                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.done_all_rounded, size: 64, color: t.success.withValues(alpha: 0.6)),
                        const SizedBox(height: 16),
                        Text(
                          tr('hospital_appr_all_caught_up'),
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('hospital_appr_no_pending'),
                          style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 450,
                      mainAxisExtent: 220,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      return _buildApprovalCard(context, ref, appointments[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);
    final pendingCount = ref.watch(pendingAppointmentsProvider).maybeWhen(
          data: (list) => list.length,
          orElse: () => 0,
        );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                tr('hospital_appr_title'),
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pendingCount ${tr('hospital_appr_pending_count')}',
                  style: GoogleFonts.inter(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tr('hospital_appr_subtitle'),
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, WidgetRef ref, Appointment app) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: t.brandPrimary.withValues(alpha: 0.1),
                child: Icon(Icons.person_rounded, color: t.brandPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.patientName, // Real requester from the booking
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: t.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tr('hospital_appr_health_id')} ${app.patientHealthId}',
                      style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: t.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tr('hospital_appr_pending_badge'),
                  style: GoogleFonts.inter(color: t.warning, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.medical_services_outlined, size: 16, color: t.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${app.doctor.name} (${app.doctor.specialization})',
                  style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: t.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${app.date.year}-${app.date.month.toString().padLeft(2, '0')}-${app.date.day.toString().padLeft(2, '0')} • ${app.timeSlot}',
                style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final success = await ref.read(pendingAppointmentsProvider.notifier).rejectAppointment(app.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${tr('hospital_appr_appointment')} ${app.id} ${tr('hospital_appr_rejected')}'), backgroundColor: t.danger),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.danger,
                    side: BorderSide(color: t.danger.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(tr('hospital_appr_reject'), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await ref.read(pendingAppointmentsProvider.notifier).approveAppointment(app.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${tr('hospital_appr_appointment')} ${app.id} ${tr('hospital_appr_approved')}'), backgroundColor: t.success),
                      );
                      ref.read(hospitalDashboardStatsProvider.notifier).refresh();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(tr('hospital_appr_verify_approve'), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
