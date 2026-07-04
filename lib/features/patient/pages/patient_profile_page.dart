import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_primitives.dart';
import '../data/models/patient_profile.dart';
import '../presentation/providers/patient_providers.dart';

class PatientProfilePage extends ConsumerStatefulWidget {
  const PatientProfilePage({super.key});

  @override
  ConsumerState<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends ConsumerState<PatientProfilePage> {
  bool _isEditing = false;
  int _currentStep = 0;
  String _bloodEligibilitySim = 'safe';
  
  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _occupationController;
  late TextEditingController _maritalStatusController;
  late TextEditingController _presentAddressController;
  late TextEditingController _permanentAddressController;
  
  // Emergency Contact editing controllers
  late TextEditingController _iceNameController;
  late TextEditingController _iceRelationController;
  late TextEditingController _icePhoneController;

  // New controllers for full editable properties
  late TextEditingController _genderController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _nationalIdController;
  late TextEditingController _bpSystolicController;
  late TextEditingController _bpDiastolicController;
  late TextEditingController _bloodGlucoseController;
  late TextEditingController _heartRateController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _occupationController = TextEditingController();
    _maritalStatusController = TextEditingController();
    _presentAddressController = TextEditingController();
    _permanentAddressController = TextEditingController();
    _iceNameController = TextEditingController();
    _iceRelationController = TextEditingController();
    _icePhoneController = TextEditingController();

    _genderController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _nationalIdController = TextEditingController();
    _bpSystolicController = TextEditingController();
    _bpDiastolicController = TextEditingController();
    _bloodGlucoseController = TextEditingController();
    _heartRateController = TextEditingController();
    _weightController = TextEditingController();

  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _maritalStatusController.dispose();
    _presentAddressController.dispose();
    _permanentAddressController.dispose();
    _iceNameController.dispose();
    _iceRelationController.dispose();
    _icePhoneController.dispose();

    _genderController.dispose();
    _bloodGroupController.dispose();
    _nationalIdController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _bloodGlucoseController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _initFields(PatientProfile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _occupationController.text = profile.occupation;
    _maritalStatusController.text = profile.maritalStatus;
    _presentAddressController.text = profile.presentAddress;
    _permanentAddressController.text = profile.permanentAddress;
    _genderController.text = profile.gender;
    _bloodGroupController.text = profile.bloodGroup;
    _nationalIdController.text = profile.nationalId;
    _bpSystolicController.text = profile.vitals.bpSystolic;
    _bpDiastolicController.text = profile.vitals.bpDiastolic;
    _bloodGlucoseController.text = profile.vitals.bloodGlucose;
    _heartRateController.text = profile.vitals.heartRate;
    _weightController.text = profile.vitals.weight;

    if (profile.emergencyContacts.isNotEmpty) {
      _iceNameController.text = profile.emergencyContacts[0].name;
      _iceRelationController.text = profile.emergencyContacts[0].relationship;
      _icePhoneController.text = profile.emergencyContacts[0].phone;
    } else {
      _iceNameController.clear();
      _iceRelationController.clear();
      _icePhoneController.clear();
    }
  }

  void _startEditing(PatientProfile profile) {
    _initFields(profile);
    setState(() {
      _isEditing = true;
      _currentStep = 0;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveProfile(PatientProfile profile) async {
    final t = AppColors.of(context);
    final updatedICE = [
      EmergencyContact(
        name: _iceNameController.text.trim(),
        relationship: _iceRelationController.text.trim(),
        phone: _icePhoneController.text.trim(),
      )
    ];

    final updatedProfile = profile.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      occupation: _occupationController.text.trim(),
      maritalStatus: _maritalStatusController.text.trim(),
      presentAddress: _presentAddressController.text.trim(),
      permanentAddress: _permanentAddressController.text.trim(),
      gender: _genderController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      emergencyContacts: updatedICE,
      vitals: VitalSign(
        bpSystolic: _bpSystolicController.text.trim(),
        bpDiastolic: _bpDiastolicController.text.trim(),
        bloodGlucose: _bloodGlucoseController.text.trim(),
        heartRate: _heartRateController.text.trim(),
        weight: _weightController.text.trim(),
        lastUpdated: DateTime.now(),
      ),
    );

    final success = await ref.read(patientProfileProvider.notifier).updateProfile(updatedProfile);
    if (success) {
      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Profile updated successfully!'), backgroundColor: t.success),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Failed to update profile. Please try again.'), backgroundColor: t.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(patientProfileProvider);
    final t = AppColors.of(context);

    return Scaffold(
      backgroundColor: t.bgMain,
      body: profileState.when(
        loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
        error: (err, stack) => Center(
          child: Text('Error loading profile: $err', style: TextStyle(color: t.textSecondary)),
        ),
        data: (profile) {
          if (_isEditing) {
            return _buildEditWizard(profile);
          }
          return _buildProfileView(profile);
        },
      ),
    );
  }

  Widget _buildProfileView(PatientProfile profile) {
    final t = AppColors.of(context);
    final dobStr = "${profile.dateOfBirth.day} ${_getMonthName(profile.dateOfBirth.month)} ${profile.dateOfBirth.year}";
    final age = DateTime.now().year - profile.dateOfBirth.year;
    final activeTab = ref.watch(patientProfileTabProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'My Health Profile',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: t.textPrimary),
              ),
              const Spacer(),
              // Custom tab selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.border),
                ),
                child: Row(
                  children: [
                    _tabButton(0, 'General Profile'),
                    _tabButton(1, 'Blood Donation'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          activeTab == 0
              ? _buildGeneralProfileTab(profile, dobStr, age)
              : _buildBloodDonationTab(profile),
        ],
      ),
    );
  }

  Widget _tabButton(int index, String label) {
    final t = AppColors.of(context);
    final activeTab = ref.watch(patientProfileTabProvider);
    final active = activeTab == index;
    return InkWell(
      onTap: () => ref.read(patientProfileTabProvider.notifier).state = index,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? t.bgCard : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: t.isDark ? 0.2 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? t.brandPrimary : t.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralProfileTab(PatientProfile profile, String dobStr, int age) {
    final t = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _profileHeader(profile),
              const SizedBox(height: 20),
              _infoSection(context, 'Personal Information', [
                _infoRow(context, 'Full Name', profile.name),
                _infoRow(context, 'Date of Birth', dobStr),
                _infoRow(context, 'Age', '$age years'),
                _infoRow(context, 'Gender', profile.gender),
                _infoRow(context, 'Blood Group', profile.bloodGroup),
                _infoRow(context, 'National ID (NID)', profile.nationalId),
                _infoRow(context, 'Phone Number', profile.phone),
                _infoRow(context, 'Occupation', profile.occupation),
                _infoRow(context, 'Marital Status', profile.maritalStatus),
              ]),
              const SizedBox(height: 20),
              _infoSection(context, 'Addresses', [
                _infoRow(context, 'Present Address', profile.presentAddress),
                _infoRow(context, 'Permanent Address', profile.permanentAddress),
              ]),
              const SizedBox(height: 20),
              _infoSection(context, 'Emergency Contacts', [
                if (profile.emergencyContacts.isEmpty)
                  Text('No emergency contacts defined.', style: GoogleFonts.inter(color: t.textSecondary))
                else
                  ...profile.emergencyContacts.map((c) => _contactRow(context, c.name, c.relationship, c.phone)),
              ]),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Column
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _medicalSection(context, 'Allergies & Reactions', [
                if (profile.allergies.isEmpty)
                  Text('No known allergies.', style: GoogleFonts.inter(color: t.textSecondary))
                else
                  ...profile.allergies.map((a) => _allergyChip(context, a.allergen, a.severity, _getAllergyColor(context, a.severity))),
              ]),
              const SizedBox(height: 20),
              _medicalSection(context, 'Chronic Diseases', [
                if (profile.chronicDiseases.isEmpty)
                  Text('No registered chronic conditions.', style: GoogleFonts.inter(color: t.textSecondary))
                else
                  ...profile.chronicDiseases.map((d) {
                    final diagnosedStr = "Diagnosed ${d.diagnosedDate.year}";
                    return _diseaseRow(context, d.diseaseName, diagnosedStr, d.status);
                  }),
              ]),
              const SizedBox(height: 20),
              _medicalSection(context, 'Current Vitals', [
                _vitalRow(context, 'Blood Pressure', '${profile.vitals.bpSystolic}/${profile.vitals.bpDiastolic} mmHg', Icons.favorite_rounded, t.brandPrimary),
                _vitalRow(context, 'Blood Glucose', '${profile.vitals.bloodGlucose} mg/dL', Icons.bloodtype_rounded, t.warning),
                _vitalRow(context, 'Heart Rate', '${profile.vitals.heartRate} bpm', Icons.monitor_heart_rounded, t.success),
                _vitalRow(context, 'Body Weight', '${profile.vitals.weight} kg', Icons.scale_rounded, t.brandSecondary),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBloodDonationTab(PatientProfile profile) {
    final t = AppColors.of(context);
    final donationState = ref.watch(bloodDonationProvider);

    return donationState.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
      error: (err, stack) => Center(
        child: Text('Error loading blood donation status: $err', style: TextStyle(color: t.textSecondary)),
      ),
      data: (data) {
        final active = data['active'] as bool? ?? false;
        final bloodGroup = data['bloodGroup'] as String? ?? 'O+';
        final eligibilitySimBackend = data['eligibilitySim'] as String? ?? 'safe';
        final requests = data['requests'] as List<dynamic>? ?? [];

        // Check if simulation dropdown overrides the backend eligibility
        final displayEligibility = _bloodEligibilitySim == 'safe' 
            ? eligibilitySimBackend 
            : _bloodEligibilitySim;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Registration Title and Switch Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blood Donor Registration & Status',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Register as an active blood donor and track match requests',
                      style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Donor Status: ',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: t.textSecondary),
                    ),
                    Text(
                      active ? 'ACTIVE' : 'INACTIVE',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: active ? t.success : t.danger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: active,
                      onChanged: (val) => ref.read(bloodDonationProvider.notifier).toggleDonor(),
                      activeThumbColor: Colors.white,
                      activeTrackColor: t.success,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: t.border,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Eligibility Analyzer Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AI Donation Eligibility Analyzer',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary),
                      ),
                      Row(
                        children: [
                          Text(
                            'Simulate Vitals State: ',
                            style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            dropdownColor: t.bgCard,
                            value: _bloodEligibilitySim,
                            style: GoogleFonts.inter(color: t.textPrimary, fontSize: 13),
                            underline: const SizedBox.shrink(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _bloodEligibilitySim = val);
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'safe', child: Text('Healthy Baseline (Safe)')),
                              DropdownMenuItem(value: 'asthma', child: Text('Active Asthma Flare-up (Unsafe)')),
                              DropdownMenuItem(value: 'recent', child: Text('Donated 3 Weeks Ago (Unsafe)')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (displayEligibility == 'safe')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: t.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppColors.innerRadius),
                        border: Border.all(color: t.success.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: t.success, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'AI Insights: Blood Donation is Safe',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: t.success, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your blood group is $bloodGroup. As a universal red blood donor, you can safely donate to: '
                            'O+, A+, B+, AB+ recipients. Your logged blood pressure (${profile.vitals.bpSystolic}/${profile.vitals.bpDiastolic} mmHg) and pulse parameters are stable.',
                            style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: t.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else if (displayEligibility == 'asthma')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: t.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppColors.innerRadius),
                        border: Border.all(color: t.danger.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_rounded, color: t.danger, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'AI Warning: Blood Donation Deferred',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: t.danger, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You have active chronic Bronchial Asthma and were recently prescribed Albuterol bronchodilators in your workspace profile. For donor safety, donation is deferred.',
                            style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: t.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else if (displayEligibility == 'recent')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: t.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppColors.innerRadius),
                        border: Border.all(color: t.danger.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_rounded, color: t.danger, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'AI Warning: Donation Frequency Deferral',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: t.danger, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You last donated blood on June 10, 2026 (3 weeks ago). The minimum required safety interval between full blood donations is 3 months. Eligible again on: September 10, 2026.',
                            style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: t.textSecondary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Match Requests List
            Text(
              'Active Match Blood Requests',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary),
            ),
            const SizedBox(height: 16),
            requests.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No active matching blood requests.', style: GoogleFonts.inter(color: t.textSecondary)),
                  )
                : Column(
                    children: [
                      for (final req in requests)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${req['patientName']} (Required: ${req['bloodGroup']})',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: t.textPrimary),
                                        ),
                                        const SizedBox(width: 10),
                                        AppChip(
                                          label: '${req['urgency']} Urgency',
                                          status: req['urgency'] == 'High' ? AppChipStatus.danger : AppChipStatus.warning,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Hospital: ${req['hospital']}',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: t.brandPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Location: ${req['location']} | Timeline: ${req['timeline']}',
                                      style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary),
                                    ),
                                  ],
                                ),
                                if (req['status'] == 'Pending')
                                  Row(
                                    children: [
                                      AppButton(
                                        label: 'Accept',
                                        onPressed: () => _realAcceptRequest(req['id'].toString()),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      const SizedBox(width: 8),
                                      AppButton(
                                        label: 'Decline',
                                        onPressed: () => _realDeclineRequest(req['id'].toString()),
                                        variant: AppButtonVariant.outline,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                    ],
                                  )
                                else
                                  AppChip(
                                    label: req['status'] == 'Accepted' ? 'Accepted' : 'Declined',
                                    status: req['status'] == 'Accepted' ? AppChipStatus.success : AppChipStatus.danger,
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ],
        );
      },
    );
  }

  void _realAcceptRequest(String id) async {
    await ref.read(bloodDonationProvider.notifier).acceptRequest(id);
    final t = AppColors.of(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you! You have accepted the donation request. Matching details sent to the hospital.'),
          backgroundColor: t.success,
        ),
      );
    }
  }

  void _realDeclineRequest(String id) async {
    await ref.read(bloodDonationProvider.notifier).declineRequest(id);
    final t = AppColors.of(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Donation request declined.'),
          backgroundColor: t.danger,
        ),
      );
    }
  }

  Widget _buildEditWizard(PatientProfile profile) {
    final t = AppColors.of(context);
    return Container(
      color: t.bgMain,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 655),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: t.isDark ? 0.25 : 0.04), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Profile Wizard',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary),
                  ),
                  IconButton(
                    onPressed: _cancelEditing,
                    icon: Icon(Icons.close_rounded, color: t.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildProgressIndicator(context),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(context),
                ),
              ),
              const SizedBox(height: 24),
              _buildWizardNavigation(context, profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Row(
      children: [
        _progressStep(context, 0, 'Personal'),
        _progressLine(context, 0),
        _progressStep(context, 1, 'Addresses'),
        _progressLine(context, 1),
        _progressStep(context, 2, 'Emergency'),
        _progressLine(context, 2),
        _progressStep(context, 3, 'Vitals'),
      ],
    );
  }

  Widget _progressStep(BuildContext context, int stepIndex, String label) {
    final t = AppColors.of(context);
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;
    final color = isActive ? t.brandPrimary : (isDone ? t.brandSecondary : t.textSecondary);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? t.brandPrimary : (isDone ? t.brandSecondary : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text(
                  '${stepIndex + 1}',
                  style: GoogleFonts.inter(
                    color: isActive ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? t.textPrimary : t.textSecondary,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _progressLine(BuildContext context, int stepIndex) {
    final t = AppColors.of(context);
    final isDone = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: 2,
        color: isDone ? t.brandSecondary : t.border,
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    final t = AppColors.of(context);
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wizardTextField(context, 'Full Name', _nameController, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Phone Number', _phoneController, Icons.phone_android_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Occupation', _occupationController, Icons.work_outline_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Marital Status', _maritalStatusController, Icons.people_outline_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Gender', _genderController, Icons.transgender_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Blood Group', _bloodGroupController, Icons.bloodtype_outlined),
            const SizedBox(height: 16),
            _wizardTextField(context, 'National ID (NID)', _nationalIdController, Icons.badge_outlined),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wizardTextField(context, 'Present Address', _presentAddressController, Icons.home_outlined, maxLines: 2),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Permanent Address', _permanentAddressController, Icons.location_on_outlined, maxLines: 2),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _permanentAddressController.text = _presentAddressController.text;
                });
              },
              icon: Icon(Icons.copy_rounded, size: 16, color: t.brandPrimary),
              label: Text('Copy Present to Permanent Address', style: TextStyle(color: t.brandPrimary)),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Primary Emergency Contact (ICE)',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textSecondary),
            ),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Contact Name', _iceNameController, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Relationship', _iceRelationController, Icons.family_restroom_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Contact Phone', _icePhoneController, Icons.phone_rounded),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Vitals', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textSecondary)),
            const SizedBox(height: 16),
            _wizardTextField(context, 'BP Systolic (mmHg)', _bpSystolicController, Icons.favorite_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'BP Diastolic (mmHg)', _bpDiastolicController, Icons.favorite_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Blood Glucose (mg/dL)', _bloodGlucoseController, Icons.bloodtype_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Heart Rate (bpm)', _heartRateController, Icons.monitor_heart_rounded),
            const SizedBox(height: 16),
            _wizardTextField(context, 'Body Weight (kg)', _weightController, Icons.scale_rounded),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _wizardTextField(BuildContext context, String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    final t = AppColors.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: t.textSecondary),
        prefixIcon: Icon(icon, color: t.textSecondary),
        filled: true,
        fillColor: t.bgInput,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.brandPrimary, width: 1.5)),
      ),
    );
  }

  Widget _buildWizardNavigation(BuildContext context, PatientProfile profile) {
    final t = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          AppButton(
            onPressed: () => setState(() => _currentStep--),
            label: 'Back',
            variant: AppButtonVariant.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            TextButton(
              onPressed: _cancelEditing,
              child: Text('Cancel', style: TextStyle(color: t.textSecondary)),
            ),
            const SizedBox(width: 12),
            if (_currentStep < 3)
              AppButton(
                onPressed: () => setState(() => _currentStep++),
                label: 'Next',
                variant: AppButtonVariant.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              )
            else
              AppButton(
                onPressed: () => _saveProfile(profile),
                label: 'Save Changes',
                variant: AppButtonVariant.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
          ],
        ),
      ],
    );
  }

  Widget _profileHeader(PatientProfile profile) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [t.brandPrimary, t.brandSecondary]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 4),
                Text('Health ID: ${profile.healthId}', style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: t.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    'Organ Donor ❤️',
                    style: GoogleFonts.inter(color: t.success, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            onPressed: () => _startEditing(profile),
            icon: Icons.edit_rounded,
            label: 'Edit Profile',
            variant: AppButtonVariant.outline,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _infoSection(BuildContext context, String title, List<Widget> children) {
    final t = AppColors.of(context);
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
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final t = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: t.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(BuildContext context, String name, String relation, String phone) {
    final t = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.emergency_rounded, size: 18, color: t.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$name ($relation)',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: t.textPrimary),
            ),
          ),
          Text(phone, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _medicalSection(BuildContext context, String title, List<Widget> children) {
    final t = AppColors.of(context);
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
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _allergyChip(BuildContext context, String name, String severity, Color color) {
    final t = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
            child: Text(severity, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _diseaseRow(BuildContext context, String name, String diagnosed, String status) {
    final t = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.monitor_heart_rounded, size: 18, color: t.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary)),
                Text(diagnosed, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: GoogleFonts.inter(color: t.danger, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _vitalRow(BuildContext context, String label, String value, IconData icon, Color color) {
    final t = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary)),
          ),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Color _getAllergyColor(BuildContext context, String severity) {
    final t = AppColors.of(context);
    switch (severity.toLowerCase()) {
      case 'severe':
        return t.danger;
      case 'moderate':
        return t.warning;
      default:
        return t.success;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
