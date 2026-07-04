import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'route_guards.dart';

import '../../features/public/pages/public_shell.dart';
import '../../features/public/pages/login_portal_page.dart';
import '../../features/auth/pages/search_doctors_page.dart';
import '../../features/patient/pages/patient_shell.dart';
import '../../features/doctor/pages/doctor_shell.dart';
import '../../features/hospital/pages/hospital_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(notifier.stream),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      return RouteGuards.guardRoute(context, state, authState);
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PublicShell(),
      ),
      GoRoute(
        path: '/search_doctors',
        builder: (context, state) => const SearchDoctorsPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPortalPage(),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => const PatientShell(),
      ),
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorShell(),
      ),
      GoRoute(
        path: '/authority',
        builder: (context, state) => const HospitalShell(),
      ),
    ],
  );
});

// Helper to convert StateNotifier stream to Listenable for GoRouter
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
