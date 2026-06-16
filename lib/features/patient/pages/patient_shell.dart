import 'package:flutter/material.dart';
import '../../../core/widgets/sidebar.dart';
import 'patient_dashboard_page.dart';
import 'health_timeline_page.dart';
import 'appointments_page.dart';
import 'medical_vault_page.dart';
import 'patient_profile_page.dart';

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    PatientDashboardPage(),
    HealthTimelinePage(),
    AppointmentsPage(),
    MedicalVaultPage(),
    PatientProfilePage(),
    Center(child: Text('AI Assistant — Coming Soon')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          PatientSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
