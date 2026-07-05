import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/dev/judge_dummy_data.dart';
import '../../../core/providers/doctor_queue_provider.dart';
import '../../../core/widgets/judge_dummy_field.dart';
import '../../../core/widgets/ai_insight_panel.dart';
import '../../patient/data/models/patient_profile.dart';
import '../presentation/providers/doctor_providers.dart';
import '../presentation/providers/clinical_workspace_provider.dart';

class ClinicalWorkspacePage extends ConsumerStatefulWidget {
  const ClinicalWorkspacePage({super.key});

  @override
  ConsumerState<ClinicalWorkspacePage> createState() =>
      _ClinicalWorkspacePageState();
}

class _ClinicalWorkspacePageState extends ConsumerState<ClinicalWorkspacePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _diseaseNotesController = TextEditingController();

  final TextEditingController _medNameController = TextEditingController();
  final TextEditingController _medDosageController = TextEditingController();
  final TextEditingController _medDurationController = TextEditingController();
  final TextEditingController _medInstructionsController =
      TextEditingController();

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController(
    text: 'In 2 weeks',
  );
  final TextEditingController _referralController = TextEditingController();

  String _diagnosisStatus = 'Provisional';

  @override
  void dispose() {
    _searchController.dispose();
    _symptomController.dispose();
    _diseaseController.dispose();
    _diseaseNotesController.dispose();
    _medNameController.dispose();
    _medDosageController.dispose();
    _medDurationController.dispose();
    _medInstructionsController.dispose();
    _notesController.dispose();
    _followUpController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final workspaceState = ref.watch(clinicalWorkspaceProvider);
    final patientId = workspaceState.patientId;

    // Watch patient profile if selected
    final patientProfileAsync = ref.watch(patientSearchProvider(patientId));

    // Listen for submission success to reset and navigate back
    ref.listen<ClinicalWorkspaceState>(clinicalWorkspaceProvider, (prev, next) {
      if (next.isSuccess) {
        // Show success alert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('doctor_treatment_submitted'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh dashboard and queue
        ref.invalidate(doctorDashboardProvider);
        ref.read(doctorQueueProvider.notifier).removeByHealthId(next.patientId);
        // Reset workspace
        ref.read(clinicalWorkspaceProvider.notifier).reset();
        // Go back to dashboard
        ref.read(doctorNavigationProvider.notifier).state = 0;
      } else if (next.error != null && next.error != prev?.error) {
        // Show error alert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: AppColors.surface,
            child: Row(
              children: [
                Text(
                  tr('doctor_clinical_workspace_title'),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  tooltip: tr('doctor_reload_workspace'),
                  onPressed: () {
                    final patientId = workspaceState.patientId;
                    if (patientId.isNotEmpty) {
                      ref.invalidate(patientSearchProvider(patientId));
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('doctor_workspace_reloaded')), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
                const SizedBox(width: 16),
                if (workspaceState.patientName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${tr('doctor_active_patient_prefix')} ${workspaceState.patientName}',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(
                    tr('doctor_select_patient_hint'),
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                const Spacer(),
                if (patientId.isNotEmpty) ...[
                  TextButton(
                    onPressed: () {
                      ref.read(clinicalWorkspaceProvider.notifier).reset();
                      _notesController.clear();
                      _followUpController.text = 'In 2 weeks';
                      _referralController.clear();
                    },
                    child: Text(
                      tr('doctor_cancel'),
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: workspaceState.isSubmitting
                        ? null
                        : () {
                            final notifier =
                                ref.read(clinicalWorkspaceProvider.notifier);

                            // Flush any typed-but-not-yet-"Added" inputs so
                            // nothing the doctor entered is silently dropped on
                            // submit. Without this, a medicine/diagnosis/symptom
                            // left in its text field (never added to the list)
                            // would be lost and the prescription would arrive
                            // empty in the patient's Medical Vault.
                            if (_symptomController.text.trim().isNotEmpty) {
                              notifier.addSymptom(_symptomController.text.trim());
                              _symptomController.clear();
                            }
                            if (_diseaseController.text.trim().isNotEmpty) {
                              notifier.addDiagnosis(
                                _diseaseController.text.trim(),
                                _diagnosisStatus,
                                _diseaseNotesController.text.trim(),
                              );
                              _diseaseController.clear();
                              _diseaseNotesController.clear();
                            }
                            if (_medNameController.text.trim().isNotEmpty) {
                              notifier.addMedicine(
                                _medNameController.text.trim(),
                                _medDosageController.text.trim(),
                                _medDurationController.text.trim(),
                                _medInstructionsController.text.trim(),
                              );
                              _medNameController.clear();
                              _medDosageController.clear();
                              _medDurationController.clear();
                              _medInstructionsController.clear();
                            }

                            notifier.updateClinicalNotes(_notesController.text);
                            notifier.updateFollowUp(_followUpController.text);
                            notifier.updateReferral(
                              _referralController.text.isEmpty
                                  ? null
                                  : _referralController.text,
                            );
                            notifier.submit();
                          },
                    icon: workspaceState.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded, size: 18),
                    label: Text(
                      workspaceState.isSubmitting
                          ? tr('doctor_submitting')
                          : tr('doctor_submit_treatment'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT: Patient History
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(
                        right: BorderSide(
                          color: AppColors.divider.withOpacity(0.5),
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar to lookup patients by ID
                          _buildPatientSearchBar(),
                          const SizedBox(height: 20),

                          if (patientId.isEmpty)
                            _buildNoPatientPlaceholder()
                          else
                            patientProfileAsync.when(
                              data: (profile) {
                                if (profile == null) {
                                  return Text(
                                    tr('doctor_patient_profile_not_found'),
                                  );
                                }
                                return _buildPatientHistoryContent(
                                  profile,
                                  workspaceState,
                                );
                              },
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (err, _) =>
                                  Text('${tr('doctor_error_loading_profile')} $err'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // RIGHT: Treatment Form
                Expanded(
                  flex: 5,
                  child: Container(
                    color: AppColors.surface,
                    child: patientId.isEmpty
                        ? Center(
                            child: Text(
                              tr('doctor_select_patient_open_form'),
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Symptoms Section
                                _buildSymptomsSection(workspaceState),
                                const SizedBox(height: 24),

                                // Diagnosis Section
                                _buildDiagnosisSection(workspaceState),
                                const SizedBox(height: 24),

                                // Prescription Section
                                _buildPrescriptionSection(workspaceState),
                                const SizedBox(height: 24),

                                // Investigations Section
                                _buildInvestigationsSection(workspaceState),
                                const SizedBox(height: 24),

                                // Notes Section
                                _buildNotesSection(),
                                const SizedBox(height: 24),

                                // Follow-up & Referral Section
                                _buildFollowUpReferralSection(),
                                const SizedBox(height: 24),

                                // AI Alerts and Decision Support (Interactive Warnings!)
                                _buildAiAlertsPanel(
                                  workspaceState,
                                  patientProfileAsync.value,
                                ),
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

  Widget _buildPatientSearchBar() {
    final tr = ref.read(translationsProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: JudgeDummyField(
        controller: _searchController,
        dummyValue:
            JudgeDummyData.doctor_clinicalWorkspace_textField_patientSearchId,
        decoration: InputDecoration(
          hintText: tr('doctor_health_id_search_hint'),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              final id = _searchController.text.trim();
              if (id.isNotEmpty) {
                ref
                    .read(clinicalWorkspaceProvider.notifier)
                    .initializePatient('', id, 'Patient Profile');
                // Dynamically fetch patient details from datasource
                ref
                    .read(doctorRepositoryProvider)
                    .getPatientProfileByHealthId(id)
                    .then((p) {
                      if (p != null) {
                        ref
                            .read(clinicalWorkspaceProvider.notifier)
                            .initializePatient('', id, p.name);
                      }
                    });
              }
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: (value) {
          final id = value.trim();
          if (id.isNotEmpty) {
            ref
                .read(clinicalWorkspaceProvider.notifier)
                .initializePatient('', id, 'Patient Profile');
            ref
                .read(doctorRepositoryProvider)
                .getPatientProfileByHealthId(id)
                .then((p) {
                  if (p != null) {
                    ref
                        .read(clinicalWorkspaceProvider.notifier)
                        .initializePatient('', id, p.name);
                  }
                });
          }
        },
      ),
    );
  }

  Widget _buildNoPatientPlaceholder() {
    final tr = ref.read(translationsProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_ind_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr('doctor_no_active_consultation'),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('doctor_no_consultation_desc'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHistoryContent(
    PatientProfile profile,
    ClinicalWorkspaceState workspaceState,
  ) {
    final tr = ref.read(translationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tr('doctor_dob_prefix')} ${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year} (${2026 - profile.dateOfBirth.year} ${tr('doctor_years_short')}) • ${profile.gender}',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: profile.bloodGroup == 'O+'
                          ? AppColors.warning.withOpacity(0.3)
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${tr('doctor_blood_prefix')} ${profile.bloodGroup}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem(
                      tr('doctor_allergies'),
                      profile.allergies.isEmpty
                          ? tr('doctor_none')
                          : profile.allergies.map((e) => e.allergen).join(', '),
                    ),
                    Container(width: 1, height: 24, color: Colors.white24),
                    _summaryItem(
                      tr('doctor_chronic_diseases'),
                      profile.chronicDiseases.isEmpty
                          ? tr('doctor_none')
                          : profile.chronicDiseases
                                .map((e) => e.diseaseName)
                                .join(', '),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text(
                  '${tr('doctor_unified_id_prefix')} ${profile.healthId}',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // AI Clinical Overview Summary & Gemini Briefing Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('doctor_ai_clinical_overview'),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${tr('doctor_profile_loaded_for')} ${profile.name}${tr('doctor_profile_loaded_tail')}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              if (workspaceState.aiBriefingText == null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('doctor_ai_medical_history_briefing'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: workspaceState.isGeneratingBriefing
                          ? null
                          : () {
                              ref
                                  .read(clinicalWorkspaceProvider.notifier)
                                  .generateBriefing();
                            },
                      icon: workspaceState.isGeneratingBriefing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 1.5,
                              ),
                            )
                          : const Icon(Icons.psychology_rounded, size: 16),
                      label: Text(
                        workspaceState.isGeneratingBriefing
                            ? tr('doctor_analyzing')
                            : tr('doctor_generate_briefing'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(
                      Icons.fact_check_rounded,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr('doctor_ai_briefing_generated'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      onPressed: () {
                        ref
                            .read(clinicalWorkspaceProvider.notifier)
                            .generateBriefing();
                      },
                      tooltip: tr('doctor_regenerate_briefing'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    workspaceState.aiBriefingText!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Vitals
        _sectionTitle(tr('doctor_latest_vital_signs')),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _vitalGridItem(
                tr('doctor_blood_pressure'),
                '${profile.vitals.bpSystolic}/${profile.vitals.bpDiastolic}',
                'mmHg',
                Icons.favorite_rounded,
                Colors.red,
              ),
              _vitalGridItem(
                tr('doctor_blood_glucose'),
                profile.vitals.bloodGlucose,
                'mg/dL',
                Icons.bloodtype_rounded,
                Colors.orange,
              ),
              _vitalGridItem(
                tr('doctor_heart_rate'),
                profile.vitals.heartRate,
                'bpm',
                Icons.favorite,
                Colors.pink,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Chronic Diseases Details
        _sectionTitle(tr('doctor_chronic_disease_log')),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: profile.chronicDiseases.length,
          itemBuilder: (context, index) {
            final cd = profile.chronicDiseases[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.healing_rounded,
                    color: Colors.orange,
                    size: 18,
                  ),
                ),
                title: Text(
                  cd.diseaseName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  '${tr('doctor_diagnosed_prefix')} ${cd.diagnosedDate.year} • ${tr('doctor_status_prefix')} ${cd.status}',
                  style: GoogleFonts.inter(fontSize: 11),
                ),
                dense: true,
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Past Lab Results / Prescriptions
        _sectionTitle(tr('doctor_historic_records')),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              const Icon(Icons.folder_open_rounded, size: 32, color: AppColors.textMuted),
              const SizedBox(height: 10),
              Text(
                tr('doctor_no_historic_records'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr('doctor_records_appear_here'),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vitalGridItem(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // Right Pane UI Widgets
  Widget _formHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection(ClinicalWorkspaceState state) {
    final tr = ref.read(translationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader(
          tr('doctor_symptoms_complaints'),
          Icons.edit_note_rounded,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: JudgeDummyField(
                controller: _symptomController,
                dummyValue:
                    JudgeDummyData.doctor_clinicalWorkspace_textField_symptoms,
                decoration: InputDecoration(
                  hintText: tr('doctor_symptom_hint'),
                  isDense: true,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref
                        .read(clinicalWorkspaceProvider.notifier)
                        .addSymptom(value.trim());
                    _symptomController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final txt = _symptomController.text.trim();
                if (txt.isNotEmpty) {
                  ref.read(clinicalWorkspaceProvider.notifier).addSymptom(txt);
                  _symptomController.clear();
                }
              },
              style: ElevatedButton.styleFrom(elevation: 0),
              child: Text(tr('doctor_add')),
            ),
          ],
        ),
        if (state.symptoms.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: state.symptoms.map((sym) {
              return Chip(
                label: Text(sym, style: GoogleFonts.inter(fontSize: 12)),
                backgroundColor: AppColors.background,
                onDeleted: () => ref
                    .read(clinicalWorkspaceProvider.notifier)
                    .removeSymptom(sym),
                deleteIconColor: AppColors.danger,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDiagnosisSection(ClinicalWorkspaceState state) {
    final tr = ref.read(translationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader(tr('doctor_diagnosis'), Icons.medical_information_rounded),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: JudgeDummyField(
                controller: _diseaseController,
                dummyValue:
                    JudgeDummyData.doctor_clinicalWorkspace_textField_diagnosis,
                decoration: InputDecoration(
                  hintText: tr('doctor_diagnosis_hint'),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _diagnosisStatus,
                items: ['Provisional', 'Confirmed'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, style: GoogleFonts.inter(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _diagnosisStatus = val;
                    });
                  }
                },
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final disease = _diseaseController.text.trim();
                if (disease.isNotEmpty) {
                  ref
                      .read(clinicalWorkspaceProvider.notifier)
                      .addDiagnosis(
                        disease,
                        _diagnosisStatus,
                        _diseaseNotesController.text.trim(),
                      );
                  _diseaseController.clear();
                  _diseaseNotesController.clear();
                }
              },
              style: ElevatedButton.styleFrom(elevation: 0),
              child: Text(tr('doctor_add')),
            ),
          ],
        ),
        if (state.diagnoses.isNotEmpty) ...[
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.diagnoses.length,
            itemBuilder: (context, index) {
              final diag = state.diagnoses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: ListTile(
                  title: Text(
                    diag.diseaseName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    '${tr('doctor_status_prefix')} ${diag.status}',
                    style: GoogleFonts.inter(fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      size: 18,
                    ),
                    onPressed: () => ref
                        .read(clinicalWorkspaceProvider.notifier)
                        .removeDiagnosis(index),
                  ),
                  dense: true,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPrescriptionSection(ClinicalWorkspaceState state) {
    final tr = ref.read(translationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader(tr('doctor_prescribe_medication'), Icons.medication_rounded),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              JudgeDummyField(
                controller: _medNameController,
                dummyValue: JudgeDummyData
                    .doctor_clinicalWorkspace_textField_medicationName,
                decoration: InputDecoration(
                  hintText: tr('doctor_medicine_name_hint'),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: JudgeDummyField(
                      controller: _medDosageController,
                      dummyValue: JudgeDummyData
                          .doctor_clinicalWorkspace_textField_medicationDosage,
                      decoration: InputDecoration(
                        hintText: tr('doctor_dosage_hint'),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: JudgeDummyField(
                      controller: _medDurationController,
                      dummyValue: JudgeDummyData
                          .doctor_clinicalWorkspace_textField_medicationDuration,
                      decoration: InputDecoration(
                        hintText: tr('doctor_duration_hint'),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: JudgeDummyField(
                      controller: _medInstructionsController,
                      dummyValue: JudgeDummyData
                          .doctor_clinicalWorkspace_textField_medicationInstructions,
                      decoration: InputDecoration(
                        hintText: tr('doctor_instructions_hint'),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    final name = _medNameController.text.trim();
                    final dosage = _medDosageController.text.trim();
                    final duration = _medDurationController.text.trim();
                    final inst = _medInstructionsController.text.trim();

                    if (name.isNotEmpty) {
                      ref
                          .read(clinicalWorkspaceProvider.notifier)
                          .addMedicine(name, dosage, duration, inst);
                      _medNameController.clear();
                      _medDosageController.clear();
                      _medDurationController.clear();
                      _medInstructionsController.clear();
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(tr('doctor_add_medicine')),
                ),
              ),
            ],
          ),
        ),

        if (state.medicines.isNotEmpty) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.medicines.length,
            itemBuilder: (context, index) {
              final med = state.medicines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: ListTile(
                  title: Text(
                    med.medicineName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: Text(
                    '${tr('doctor_dosage_prefix')} ${med.dosage} • ${tr('doctor_duration_prefix')} ${med.duration} • ${med.instructions}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      size: 18,
                    ),
                    onPressed: () => ref
                        .read(clinicalWorkspaceProvider.notifier)
                        .removeMedicine(index),
                  ),
                  dense: true,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInvestigationsSection(ClinicalWorkspaceState state) {
    final availableTests = [
      'Blood Glucose',
      'HbA1c',
      'ECG',
      'Lipid Profile',
      'Renal Function',
      'Chest X-Ray',
    ];

    final tr = ref.read(translationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader(tr('doctor_investigations_diagnostics'), Icons.science_rounded),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTests.map((test) {
            final checked = state.investigations.contains(test);
            return InkWell(
              onTap: () => ref
                  .read(clinicalWorkspaceProvider.notifier)
                  .toggleInvestigation(test),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: checked
                      ? AppColors.primaryLight
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: checked
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.divider.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      checked
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: checked ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      test,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: checked
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    final tr = ref.read(translationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader(tr('doctor_clinical_notes'), Icons.note_alt_rounded),
        const SizedBox(height: 10),
        JudgeDummyField(
          controller: _notesController,
          dummyValue:
              JudgeDummyData.doctor_clinicalWorkspace_textField_clinicalNotes,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: tr('doctor_clinical_notes_hint'),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowUpReferralSection() {
    final tr = ref.read(translationsProvider);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formHeader(tr('doctor_followup'), Icons.event_rounded),
              const SizedBox(height: 10),
              JudgeDummyField(
                controller: _followUpController,
                dummyValue:
                    JudgeDummyData.doctor_clinicalWorkspace_textField_followUp,
                decoration: InputDecoration(
                  hintText: tr('doctor_followup_hint'),
                  prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formHeader(tr('doctor_referral_optional'), Icons.send_rounded),
              const SizedBox(height: 10),
              JudgeDummyField(
                controller: _referralController,
                dummyValue:
                    JudgeDummyData.doctor_clinicalWorkspace_textField_referral,
                decoration: InputDecoration(
                  hintText: tr('doctor_referral_hint'),
                  prefixIcon: const Icon(Icons.person_search_rounded, size: 18),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiAlertsPanel(
    ClinicalWorkspaceState state,
    PatientProfile? profile,
  ) {
    final tr = ref.read(translationsProvider);
    final List<Widget> alerts = [];

    // 1. Allergy Alert logic
    final bool hasPenicillinAllergy =
        profile?.allergies.any(
          (a) => a.allergen.toLowerCase().contains('penicillin'),
        ) ??
        false;
    final bool hasPrescribedPenicillin = state.medicines.any((m) {
      final name = m.medicineName.toLowerCase();
      return name.contains('penicillin') ||
          name.contains('amoxicillin') ||
          name.contains('ampicillin') ||
          name.contains('cloxacillin') ||
          name.contains('augmentin');
    });

    if (hasPenicillinAllergy && hasPrescribedPenicillin) {
      alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AiInsightPanel(
            title: tr('doctor_allergy_warning_title'),
            description: tr('doctor_allergy_warning_desc'),
            type: 'danger',
            recommendations: [
              tr('doctor_allergy_warning_rec1'),
              tr('doctor_allergy_warning_rec2'),
            ],
          ),
        ),
      );
    }

    // 2. Drug Interaction logic (e.g. Aspirin and Glimepiride)
    final hasAspirin = state.medicines.any(
      (m) => m.medicineName.toLowerCase().contains('aspirin'),
    );
    final hasGlimepiride = state.medicines.any(
      (m) => m.medicineName.toLowerCase().contains('glimepiride'),
    );
    if (hasAspirin && hasGlimepiride) {
      alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AiInsightPanel(
            title: tr('doctor_drug_interaction_title'),
            description: tr('doctor_drug_interaction_desc'),
            type: 'warning',
            recommendations: [
              tr('doctor_drug_interaction_rec1'),
              tr('doctor_drug_interaction_rec2'),
            ],
          ),
        ),
      );
    }

    // 3. Clinical Recommendation logic (suggest ECG for cardiac patients if not ordered)
    final hasCardiacComplaint = state.symptoms.any(
      (s) =>
          s.toLowerCase().contains('chest pain') ||
          s.toLowerCase().contains('breathless') ||
          s.toLowerCase().contains('palpitations'),
    );
    final hasOrderedEcg = state.investigations.contains('ECG');
    if (hasCardiacComplaint && !hasOrderedEcg) {
      alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AiInsightPanel(
            title: tr('doctor_diagnostics_support_title'),
            description: tr('doctor_diagnostics_support_desc'),
            type: 'info',
            recommendations: [
              tr('doctor_diagnostics_support_rec1'),
              tr('doctor_diagnostics_support_rec2'),
            ],
          ),
        ),
      );
    }

    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              tr('doctor_ai_safety_check_ok'),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(children: alerts);
  }
}
