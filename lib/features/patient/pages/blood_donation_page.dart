import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_primitives.dart';
import '../data/models/patient_profile.dart';
import '../presentation/providers/patient_providers.dart';

class BloodDonationPage extends ConsumerStatefulWidget {
  const BloodDonationPage({super.key});

  @override
  ConsumerState<BloodDonationPage> createState() => _BloodDonationPageState();
}

class _BloodDonationPageState extends ConsumerState<BloodDonationPage> {
  String _bloodEligibilitySim = 'safe';

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final profileState = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: t.bgMain,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Blood Donation Portal',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: t.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: t.brandPrimary),
                  tooltip: 'Reload',
                  onPressed: () {
                    ref.invalidate(patientProfileProvider);
                    ref.invalidate(bloodDonationProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reloaded.'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            profileState.when(
              loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
              error: (err, stack) => Center(
                child: Text('Error loading profile: $err', style: TextStyle(color: t.textSecondary)),
              ),
              data: (profile) => _buildDonationContent(profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationContent(PatientProfile profile) {
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
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Register as an active blood donor',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: t.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Receive real-time match requests from hospitals nearby when patients need matching blood.',
                            style: GoogleFonts.inter(fontSize: 12.5, color: t.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
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
              ),
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
    final t = AppColors.of(context);
    await ref.read(bloodDonationProvider.notifier).acceptRequest(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thank you! You have accepted the donation request. Matching details sent to the hospital.'),
        backgroundColor: t.success,
      ),
    );
  }

  void _realDeclineRequest(String id) async {
    final t = AppColors.of(context);
    await ref.read(bloodDonationProvider.notifier).declineRequest(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Donation request declined.'),
        backgroundColor: t.danger,
      ),
    );
  }
}
