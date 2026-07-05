import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/widgets/ai_insight_panel.dart';
import '../../../core/widgets/notification_dropdown.dart';
import '../../../core/providers/notifications_provider.dart';
import '../data/models/appointment.dart';
import '../data/models/dashboard_summary.dart';
import '../data/models/medical_record.dart';
import '../data/models/patient_profile.dart';
import '../presentation/providers/patient_providers.dart';
import 'patient_dashboard_skeleton.dart';
import '../../../core/widgets/shimmer.dart';

class PatientDashboardPage extends ConsumerWidget {
  const PatientDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(patientProfileProvider);
    final aiSummaryState = ref.watch(patientAiHealthSummaryProvider);
    final appointmentsState = ref.watch(patientAppointmentsProvider);
    final prescriptionsState = ref.watch(patientPrescriptionsProvider);
    final labReportsState = ref.watch(patientLabReportsProvider);
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: t.bgMain,
      body: profileState.when(
        loading: () => const PatientDashboardSkeleton(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: t.danger, size: 48),
              const SizedBox(height: 16),
              Text('${tr('patient_err_loading_dashboard')}: $err', style: GoogleFonts.inter(color: t.textPrimary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(patientProfileProvider);
                  ref.invalidate(patientDashboardSummaryProvider);
                  ref.invalidate(patientAiHealthSummaryProvider);
                  ref.invalidate(patientAppointmentsProvider);
                  ref.invalidate(patientPrescriptionsProvider);
                  ref.invalidate(patientLabReportsProvider);
                },
                child: Text(tr('patient_retry')),
              ),
            ],
          ),
        ),
        data: (profile) {
          return Row(
            children: [
              // Main content
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(context, ref, tr),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHealthCard(context, profile, tr),
                            const SizedBox(height: 24),
                            aiSummaryState.when(
                              loading: () => LinearProgressIndicator(color: t.warning),
                              error: (e, s) => const SizedBox.shrink(),
                              data: (aiSummary) => _buildAISummary(aiSummary, tr),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              tr('patient_quick_services'),
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: t.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildQuickActions(context, ref, tr),
                            const SizedBox(height: 24),
                            _buildSectionRow(context, prescriptionsState, appointmentsState, tr),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right panel
              _buildRightPanel(context, ref, profile, labReportsState, tr),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AppTranslations tr) {
    final t = AppColors.of(context);
    final notifications = ref.watch(patientNotificationsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: t.bgInput,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: t.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: tr('patient_search_placeholder'),
                        hintStyle: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: t.brandPrimary),
            tooltip: tr('patient_reload'),
            onPressed: () {
              ref.invalidate(patientProfileProvider);
              ref.invalidate(patientAiHealthSummaryProvider);
              ref.invalidate(patientAppointmentsProvider);
              ref.invalidate(patientPrescriptionsProvider);
              ref.invalidate(patientLabReportsProvider);
              ref.invalidate(patientNotificationsProvider);
              ref.invalidate(bloodDonationProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr('patient_reloaded')), duration: const Duration(seconds: 1)),
              );
            },
          ),
          const SizedBox(width: 8),
          NotificationDropdown(
            notifications: notifications,
            onMarkRead: (id) => ref.read(patientNotificationsProvider.notifier).markAsRead(id),
            onMarkAllRead: () => ref.read(patientNotificationsProvider.notifier).markAllAsRead(),
            onNavigate: (tabIndex) {
              ref.read(patientNavigationProvider.notifier).state = tabIndex;
            },
          ),
          const SizedBox(width: 8),
          _headerIcon(context, Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _headerIcon(BuildContext context, IconData icon, {String? badge}) {
    final t = AppColors.of(context);
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: t.textSecondary, size: 20),
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: t.danger, shape: BoxShape.circle),
              child: Text(
                badge,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHealthCard(BuildContext context, PatientProfile profile, AppTranslations tr) {
    final t = AppColors.of(context);
    final age = DateTime.now().year - profile.dateOfBirth.year;
    final allergiesStr = profile.allergies.isEmpty
        ? tr('patient_none')
        : profile.allergies.map((e) => e.allergen).join(', ');
    final chronicStr = profile.chronicDiseases.isEmpty
        ? tr('patient_none')
        : profile.chronicDiseases.map((e) => e.diseaseName).join(', ');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [t.brandPrimary, t.brandSecondary.withValues(alpha: 0.85), t.brandPrimary.withValues(alpha: 0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: t.brandPrimary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('patient_digital_health_card'),
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      profile.healthId,
                      style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cardStat(tr('patient_blood_group'), profile.bloodGroup),
                _cardStatDivider(),
                _cardStat(tr('patient_age'), age.toString()),
                _cardStatDivider(),
                _cardStat(tr('patient_allergies'), allergiesStr),
                _cardStatDivider(),
                _cardStat(tr('patient_chronic'), chronicStr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.54), fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _cardStatDivider() {
    return Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.15));
  }

  Widget _buildAISummary(AiHealthSummary summary, AppTranslations tr) {
    return AiInsightPanel(
      title: tr('patient_ai_health_assessment'),
      description: summary.summaryText,
      type: 'warning',
      recommendations: [
        tr('patient_ai_rec_1'),
        tr('patient_ai_rec_2'),
        tr('patient_ai_rec_3'),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, AppTranslations tr) {
    final t = AppColors.of(context);
    return Row(
      children: [
        _actionCard(
          context,
          Icons.calendar_month_rounded,
          tr('patient_action_book_appointment'),
          t.brandPrimary,
          onTap: () => ref.read(patientNavigationProvider.notifier).state = 2,
        ),
        const SizedBox(width: 16),
        _actionCard(
          context,
          Icons.timeline_rounded,
          tr('patient_health_timeline'),
          t.brandSecondary,
          onTap: () => ref.read(patientNavigationProvider.notifier).state = 1,
        ),
        const SizedBox(width: 16),
        _actionCard(
          context,
          Icons.folder_shared_rounded,
          tr('patient_medical_vault'),
          t.warning,
          onTap: () => ref.read(patientNavigationProvider.notifier).state = 3,
        ),
        const SizedBox(width: 16),
        _actionCard(
          context,
          Icons.auto_awesome_rounded,
          tr('patient_healthcare_ai'),
          t.success,
          onTap: () => ref.read(patientNavigationProvider.notifier).state = 5,
        ),
      ],
    );
  }

  Widget _actionCard(BuildContext context, IconData icon, String label, Color color, {required VoidCallback onTap}) {
    final t = AppColors.of(context);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionRow(
    BuildContext context,
    AsyncValue<List<Prescription>> prescriptionsState,
    AsyncValue<List<Appointment>> appointmentsState,
    AppTranslations tr,
  ) {
    final t = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Prescriptions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('patient_active_prescriptions'),
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: t.textPrimary),
              ),
              const SizedBox(height: 16),
              prescriptionsState.when(
                loading: () => Shimmer(
                  child: Column(
                    children: [
                      for (int i = 0; i < 2; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            height: 70,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: t.bgCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: t.border),
                            ),
                            child: Row(
                              children: [
                                const ShimmerBox(width: 32, height: 32, borderRadius: BorderRadius.all(Radius.circular(8))),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      ShimmerBox(width: 100, height: 14),
                                      SizedBox(height: 6),
                                      ShimmerBox(width: 160, height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                error: (err, stack) => Text('${tr('patient_err_loading_prescriptions')}: $err', style: TextStyle(color: t.textSecondary)),
                data: (prescriptions) {
                  if (prescriptions.isEmpty) {
                    return Text(tr('patient_no_active_prescriptions'), style: GoogleFonts.inter(color: t.textSecondary));
                  }
                  final activeMeds = prescriptions.expand((p) => p.medicines).take(3).toList();
                  if (activeMeds.isEmpty) {
                    return Text(tr('patient_no_active_medications'), style: GoogleFonts.inter(color: t.textSecondary));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeMeds.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final med = activeMeds[index];
                      return _prescriptionCard(context, med.name, med.instruction, med.duration, t.success, tr);
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Upcoming Appointments
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('patient_upcoming_appointments'),
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: t.textPrimary),
              ),
              const SizedBox(height: 16),
              appointmentsState.when(
                loading: () => Shimmer(
                  child: Column(
                    children: [
                      for (int i = 0; i < 2; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            height: 70,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: t.bgCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: t.border),
                            ),
                            child: Row(
                              children: [
                                const ShimmerBox(width: 32, height: 32, borderRadius: BorderRadius.all(Radius.circular(8))),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      ShimmerBox(width: 120, height: 14),
                                      SizedBox(height: 6),
                                      ShimmerBox(width: 140, height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                error: (err, stack) => Text('${tr('patient_err_loading_appointments')}: $err', style: TextStyle(color: t.textSecondary)),
                data: (appointments) {
                  final upcoming = appointments.where((a) => a.status == 'Upcoming').toList();
                  if (upcoming.isEmpty) {
                    return Text(tr('patient_no_upcoming_appointments'), style: GoogleFonts.inter(color: t.textSecondary));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcoming.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = upcoming[index];
                      final dateStr = "${app.date.day}/${app.date.month}/${app.date.year}";
                      return _appointmentCard(context, app.doctor.name, app.doctor.specialization, "$dateStr, ${app.timeSlot}", app.hospital);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _prescriptionCard(BuildContext context, String medicine, String instruction, String duration, Color color, AppTranslations tr) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.medication_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary)),
                const SizedBox(height: 2),
                Text(instruction, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text('${tr('patient_duration')}: $duration', style: GoogleFonts.inter(color: t.textSecondary.withValues(alpha: 0.7), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard(BuildContext context, String doctor, String specialty, String time, String hospital) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: t.brandPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.event_rounded, color: t.brandPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary)),
                Text(specialty, style: GoogleFonts.inter(color: t.brandSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: t.textSecondary),
                    const SizedBox(width: 4),
                    Text(time, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: t.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hospital,
                        style: GoogleFonts.inter(color: t.textSecondary.withValues(alpha: 0.7), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context, WidgetRef ref, PatientProfile profile, AsyncValue<List<LabReport>> labReportsState, AppTranslations tr) {
    final t = AppColors.of(context);
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(left: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.bgInput,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [t.brandPrimary, t.brandSecondary]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: t.textPrimary)),
                  Text(profile.healthId, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Vitals
            Text(tr('patient_health_vitals'), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary)),
            const SizedBox(height: 12),
            _vitalCard(context, tr('patient_blood_pressure'), '${profile.vitals.bpSystolic}/${profile.vitals.bpDiastolic} mmHg', Icons.favorite_rounded, t.brandPrimary),
            const SizedBox(height: 8),
            _vitalCard(context, tr('patient_blood_glucose'), '${profile.vitals.bloodGlucose} mg/dL', Icons.bloodtype_rounded, t.warning),
            const SizedBox(height: 8),
            _vitalCard(context, tr('patient_heart_rate'), '${profile.vitals.heartRate} bpm', Icons.monitor_heart_rounded, t.success),
            const SizedBox(height: 8),
            _vitalCard(context, tr('patient_weight'), '${profile.vitals.weight} kg', Icons.scale_rounded, t.brandSecondary),
            const SizedBox(height: 24),

            // Blood Donation Portal Quick View
            _buildBloodDonationRightCard(context, ref, tr),
            const SizedBox(height: 24),

            // Recent reports
            Text(tr('patient_recent_test_reports'), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary)),
            const SizedBox(height: 12),
            labReportsState.when(
              loading: () => Shimmer(
                child: Column(
                  children: [
                    for (int i = 0; i < 2; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: t.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: t.border),
                          ),
                          child: Row(
                            children: [
                              const ShimmerBox(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(6))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    ShimmerBox(width: 110, height: 12),
                                    SizedBox(height: 4),
                                    ShimmerBox(width: 130, height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              error: (err, stack) => Text(tr('patient_err_loading_reports'), style: TextStyle(color: t.textSecondary)),
              data: (reports) {
                if (reports.isEmpty) {
                  return Text(tr('patient_no_test_reports'), style: GoogleFonts.inter(color: t.textSecondary));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
                    return _reportItem(context, report.testName, dateStr, report.status);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodDonationRightCard(BuildContext context, WidgetRef ref, AppTranslations tr) {
    final t = AppColors.of(context);
    final donationState = ref.watch(bloodDonationProvider);

    return donationState.when(
      loading: () => Shimmer(
        child: Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.border),
          ),
          child: Row(
            children: [
              const ShimmerBox(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(6))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ShimmerBox(width: 130, height: 12),
                    SizedBox(height: 6),
                    ShimmerBox(width: 90, height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final active = data['active'] as bool? ?? false;
        final requests = data['requests'] as List<dynamic>? ?? [];
        final pendingCount = requests.where((r) => r['status'] == 'Pending').length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: active 
                  ? [t.danger.withValues(alpha: 0.12), t.danger.withValues(alpha: 0.05)]
                  : [t.border.withValues(alpha: 0.25), t.border.withValues(alpha: 0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? t.danger.withValues(alpha: 0.25) : t.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    active ? Icons.bloodtype_rounded : Icons.bloodtype_outlined,
                    color: active ? t.danger : t.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr('patient_blood_donation_portal'),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: t.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('patient_donor_registration'),
                    style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? t.success.withValues(alpha: 0.15) : t.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      active ? tr('patient_registered') : tr('patient_inactive'),
                      style: GoogleFonts.inter(
                        color: active ? t.success : t.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (active) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('patient_matched_requests'),
                      style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: pendingCount > 0 ? t.danger : t.bgInput,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingCount',
                        style: GoogleFonts.inter(
                          color: pendingCount > 0 ? Colors.white : t.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Update navigation selection to Blood Donation (6)
                    ref.read(patientNavigationProvider.notifier).state = 6;
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: active ? t.danger.withValues(alpha: 0.1) : t.bgInput,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    tr('patient_manage_portal'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: active ? t.danger : t.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _vitalCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary))),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _reportItem(BuildContext context, String name, String date, String status) {
    final t = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.bgInput,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 18, color: t.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: t.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(date, style: GoogleFonts.inter(fontSize: 11, color: t.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: t.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(
              status,
              style: GoogleFonts.inter(color: t.success, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
