import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../presentation/providers/doctor_providers.dart';

class DoctorProfilePage extends ConsumerStatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  ConsumerState<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends ConsumerState<DoctorProfilePage> {
  bool _isEditing = false;
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _hospitalController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initControllers(Map<String, dynamic> data) {
    _nameController.text = data['fullName']?.toString() ?? '';
    _specializationController.text = data['specialization']?.toString() ?? '';
    _hospitalController.text = data['hospitalAffiliation']?.toString() ?? '';
    _licenseController.text = data['licenseNumber']?.toString() ?? '';
    _experienceController.text = data['experienceYears']?.toString() ?? '3';
    _feeController.text = data['consultationFee']?.toString() ?? '600';
    _phoneController.text = data['contactNumber']?.toString() ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(doctorRepositoryProvider);
      final payload = {
        'fullName': _nameController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'hospitalAffiliation': _hospitalController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        'experienceYears': int.tryParse(_experienceController.text) ?? 3,
        'consultationFee': int.tryParse(_feeController.text) ?? 600,
        'contactNumber': _phoneController.text.trim(),
      };
      
      await repo.updateDoctorProfile(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(translationsProvider)('doctor_profile_updated')),
          backgroundColor: AppColors.success,
        ),
      );

      // Invalidate state to trigger rebuild across dashboard & header
      ref.invalidate(doctorProfileProvider);
      ref.invalidate(doctorDashboardProvider);

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ref.read(translationsProvider)('doctor_profile_update_failed')} $e'),
          backgroundColor: AppColors.danger,
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final profileAsync = ref.watch(doctorProfileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, _) => Center(child: Text('${tr('doctor_error_loading_profile')} $err', style: const TextStyle(color: AppColors.danger))),
      data: (profile) {
        // Initialize controllers on first load or when not editing
        if (!_isEditing && !_isSaving) {
          _initControllers(profile);
        }

        return Container(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(tr('doctor_professional_profile'), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                          tooltip: tr('doctor_reload_profile'),
                          onPressed: () {
                            ref.invalidate(doctorProfileProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(tr('doctor_profile_reloaded')), duration: const Duration(seconds: 1)),
                            );
                          },
                        ),
                      ],
                    ),
                    if (_isEditing)
                      Row(
                        children: [
                          TextButton(
                            onPressed: _isSaving
                                ? null
                                : () => setState(() => _isEditing = false),
                            child: Text(tr('doctor_cancel'), style: GoogleFonts.inter(color: AppColors.textSecondary)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.save_rounded, size: 16),
                            label: Text(_isSaving ? tr('doctor_saving') : tr('doctor_save_changes')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: Text(tr('doctor_edit_profile')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Profile header banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.primaryDark]),
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
                                Expanded(
                                  child: _isEditing
                                      ? TextField(
                                          controller: _nameController,
                                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            hintText: tr('doctor_doctor_name_hint'),
                                            hintStyle: const TextStyle(color: Colors.white70),
                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
                                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                          ),
                                        )
                                      : Text(profile['fullName'] ?? 'Dr. Rahim Chowdhury', style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(tr('doctor_verified'), style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            _isEditing
                                ? TextField(
                                    controller: _specializationController,
                                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: tr('doctor_specialization_hint'),
                                      hintStyle: const TextStyle(color: Colors.white60),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                                    ),
                                  )
                                : Text(profile['specialization'] ?? 'Cardiology', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('${tr('doctor_license_prefix')} ${profile['licenseNumber'] ?? 'MBBS-25442'} • ${profile['experienceYears'] ?? '3'} ${tr('doctor_years_experience_suffix')}', style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
                          ],
                        ),
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
                          _section(tr('doctor_professional_information'), [
                            _editInfoRow(tr('doctor_full_name'), _nameController, _isEditing, profile['fullName']?.toString() ?? ''),
                            _editInfoRow(tr('doctor_specialization'), _specializationController, _isEditing, profile['specialization']?.toString() ?? ''),
                            _editInfoRow(tr('doctor_hospital_affiliation'), _hospitalController, _isEditing, profile['hospitalAffiliation']?.toString() ?? ''),
                            _editInfoRow(tr('doctor_bmdc_registration'), _licenseController, _isEditing, profile['licenseNumber']?.toString() ?? ''),
                            _editInfoRow(tr('doctor_experience_years'), _experienceController, _isEditing, profile['experienceYears']?.toString() ?? '', isNumeric: true),
                            _editInfoRow(tr('doctor_consultation_fee'), _feeController, _isEditing, profile['consultationFee']?.toString() ?? '', isNumeric: true),
                            _editInfoRow(tr('doctor_contact_number'), _phoneController, _isEditing, profile['contactNumber']?.toString() ?? ''),
                          ]),
                          const SizedBox(height: 20),
                          _section(tr('doctor_education_degrees'), [
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
                          _section(tr('doctor_hospital_affiliations'), [
                            _affiliationRow(profile['hospitalAffiliation'] ?? 'Dhaka Medical College Hospital', tr('doctor_senior_consultant'), tr('doctor_cardiology_dept'), tr('doctor_status_active')),
                            _affiliationRow('National Heart Foundation', tr('doctor_visiting_consultant'), tr('doctor_interventional'), tr('doctor_status_active')),
                          ]),
                          const SizedBox(height: 20),
                          _section(tr('doctor_performance_summary'), [
                            _statRow(tr('doctor_total_patients_treated'), '12,450'),
                            _statRow(tr('doctor_this_month'), '248'),
                            _statRow(tr('doctor_followup_compliance'), '87%'),
                            _statRow(tr('doctor_average_rating'), '4.8 / 5.0'),
                          ]),
                          const SizedBox(height: 20),
                          _section(tr('doctor_certifications'), [
                            _certRow(tr('doctor_cert_acls'), 'AHA', tr('doctor_status_valid')),
                            _certRow(tr('doctor_cert_echo'), 'ASE', tr('doctor_status_valid')),
                            _certRow(tr('doctor_cert_interventional_fellowship'), 'ACC', tr('doctor_status_completed')),
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
      },
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
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

  Widget _editInfoRow(String label, TextEditingController controller, bool editing, String displayVal, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 160, child: Text(label, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13))),
          Expanded(
            child: editing
                ? TextField(
                    controller: controller,
                    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  )
                : Text(displayVal, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(degree, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(institution, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('$role • $dept', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13)),
                Text(org, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
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
