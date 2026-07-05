import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/sidebar.dart';
import '../presentation/providers/patient_providers.dart';
import 'patient_dashboard_page.dart';
import 'health_timeline_page.dart';
import 'appointments_page.dart';
import 'medical_vault_page.dart';
import 'patient_profile_page.dart';
import 'health_copilot_page.dart';
import 'blood_donation_page.dart';

class PatientShell extends ConsumerWidget {
  const PatientShell({super.key});

  static final List<Widget> _pages = [
    const PatientDashboardPage(),
    const HealthTimelinePage(),
    const AppointmentsPage(),
    const MedicalVaultPage(),
    const PatientProfilePage(),
    const HealthCopilotPage(),
    const BloodDonationPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(patientNavigationProvider);

    return Scaffold(
      body: Row(
        children: [
          PatientSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (i) => ref.read(patientNavigationProvider.notifier).state = i,
          ),
          Expanded(child: _pages[selectedIndex]),
        ],
      ),
    );
  }
}
