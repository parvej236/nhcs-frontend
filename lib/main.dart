import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/pages/role_selection_page.dart';
import 'features/auth/pages/login_page.dart';
import 'features/patient/pages/patient_shell.dart';
import 'features/doctor/pages/doctor_shell.dart';
import 'features/hospital/pages/hospital_shell.dart';

void main() {
  runApp(const NudhebApp());
}

class NudhebApp extends StatelessWidget {
  const NudhebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUDHEB - Healthcare Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionPage(),
        '/login': (context) => const LoginPage(),
        '/user': (context) => const PatientShell(),
        '/doctor': (context) => const DoctorShell(),
        '/authority': (context) => const HospitalShell(),
      },
    );
  }
}
