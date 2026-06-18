import 'package:flutter/material.dart';
import '../../../core/widgets/sidebar.dart';
import 'command_center_page.dart';
import 'reception_queue_page.dart';
import 'staff_management_page.dart';
import 'laboratory_page.dart';
import 'bed_management_page.dart';
import 'pharmacy_page.dart';

class HospitalShell extends StatefulWidget {
  const HospitalShell({super.key});

  @override
  State<HospitalShell> createState() => _HospitalShellState();
}

class _HospitalShellState extends State<HospitalShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CommandCenterPage(),
    ReceptionQueuePage(),
    StaffManagementPage(),
    LaboratoryPage(),
    BedManagementPage(),
    PharmacyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          HospitalSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
