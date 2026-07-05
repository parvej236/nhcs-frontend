import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/sidebar.dart';
import '../presentation/providers/hospital_providers.dart';
import 'command_center_page.dart';
import 'laboratory_page.dart';
import 'blood_donation_management_page.dart';
import 'appointment_approvals_page.dart';

class HospitalShell extends ConsumerWidget {
  const HospitalShell({super.key});

  static const List<Widget> _pages = [
    CommandCenterPage(),
    LaboratoryPage(),
    BloodDonationManagementPage(),
    AppointmentApprovalsPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(hospitalNavigationProvider);

    return Scaffold(
      body: Row(
        children: [
          HospitalSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (i) => ref.read(hospitalNavigationProvider.notifier).state = i,
          ),
          Expanded(child: _pages[selectedIndex]),
        ],
      ),
    );
  }
}
