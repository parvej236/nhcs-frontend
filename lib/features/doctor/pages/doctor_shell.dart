import 'package:flutter/material.dart';
import '../../../core/widgets/sidebar.dart';
import 'doctor_dashboard_page.dart';
import 'clinical_workspace_page.dart';
import 'report_review_page.dart';
import 'doctor_schedule_page.dart';
import 'doctor_profile_page.dart';

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DoctorDashboardPage(),
    ClinicalWorkspacePage(),
    ReportReviewPage(),
    DoctorSchedulePage(),
    DoctorProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          DoctorSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
