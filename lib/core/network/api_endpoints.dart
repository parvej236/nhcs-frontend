class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';

  // Public
  static const String publicStats = '/public/stats';
  static const String publicDoctors = '/public/doctors';
  static const String publicVitalsAnalyze = '/public/vitals-analyze';

  // Patient
  static const String patientProfile = '/patients/me';
  static const String patientDashboardSummary = '/patients/dashboard/summary';
  static const String patientAiSummary = '/patients/dashboard/ai-summary';
  static const String patientTimeline = '/patients/me/timeline';
  static const String patientAppointments = '/patients/me/appointments';
  static const String patientPrescriptions = '/patients/me/prescriptions';
  static const String patientLabReports = '/patients/me/lab-reports';
  static const String patientImagingReports = '/patients/me/imaging-reports';
  static String cancelAppointment(String id) => '/patients/me/appointments/$id/cancel';
  
  // Blood Donation
  static const String bloodDonationStatus = '/blood-donations/status';
  static const String bloodDonationToggle = '/blood-donations/toggle-donor';
  static String bloodDonationAccept(String id) => '/blood-donations/requests/$id/accept';
  static String bloodDonationDecline(String id) => '/blood-donations/requests/$id/decline';

  // Doctor
  static const String doctorProfile = '/doctors/me';
  static const String doctorDashboardSummary = '/doctor/dashboard/summary';
  static const String doctorQueue = '/doctor/queue';
  static const String doctorsList = '/doctors';
  static String doctorSlots(String doctorId) => '/doctors/$doctorId/slots';

  // Hospital
  static const String hospitalDashboardOverview = '/hospitals/dashboard/overview';
  static const String hospitalPendingAppointments = '/hospitals/appointments/pending';
  static String hospitalApproveAppointment(String id) => '/hospitals/appointments/$id/approve';
  static String hospitalRejectAppointment(String id) => '/hospitals/appointments/$id/reject';
  static String hospitalCheckInAppointment(String id) => '/hospitals/appointments/$id/check-in';
  static String hospitalSearchAppointments(String query) => '/hospitals/appointments/search?query=$query';

  // Applications
  static const String applyRole = '/applications';
  static const String pendingApplications = '/applications/pending';
  static String approveApplication(int id) => '/applications/$id/approve';
  static String rejectApplication(int id) => '/applications/$id/reject';

  // Public Blood Donation
  static const String publicHospitals = '/public/hospitals';
  static const String publicBloodRequests = '/public/blood-requests';

  // Hospital Blood Donation management
  static const String hospitalBloodRequests = '/hospitals/blood-requests';
  static String hospitalBloodMatches(String id) => '/hospitals/blood-requests/$id/matches';
  static String hospitalBloodNotify(String id) => '/hospitals/blood-requests/$id/notify';
}
