import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/appointment.dart';
import '../models/dashboard_summary.dart';
import '../models/health_event.dart';
import '../models/medical_record.dart';
import '../models/patient_profile.dart';
import '../models/ai_suggestion.dart';
import '../models/copilot_models.dart';

abstract class PatientRepository {
  Future<DashboardSummary> getDashboardSummary(String healthId);
  Future<AiHealthSummary> getAiHealthSummary(String healthId);
  Future<PatientProfile> getPatientProfile(String healthId);
  Future<PatientProfile> updatePatientProfile(String healthId, PatientProfile profile);
  Future<List<HealthEvent>> getHealthEvents(String healthId);
  Future<List<DoctorSpecialist>> getAvailableDoctors();
  Future<List<TimeSlot>> getAvailableTimeSlots(String doctorId, DateTime date);
  Future<Appointment> bookAppointment({
    required String healthId,
    required DoctorSpecialist doctor,
    required DateTime date,
    required String timeSlot,
  });
  Future<List<Appointment>> getAppointments(String healthId);
  Future<List<Prescription>> getPrescriptions(String healthId);
  Future<List<LabReport>> getLabReports(String healthId);
  Future<List<ImagingReport>> getImagingReports(String healthId);
  Future<void> cancelAppointment(String appointmentId);
  Future<AiSuggestionResponse> getAiDoctorSuggestion(String healthId, String problemText);
  // AI Health Copilot
  Future<CopilotBriefing> getCopilotBriefing();
  Future<String> copilotChat(String message, List<ChatMessage> history);
  Future<MedicationCheck> getMedicationCheck({String? newMedicine});
  Future<RiskRadar> getRiskRadar();
  Future<ReportExplanation> explainReport({required String reportType, required String reportId});
  Future<Map<String, dynamic>> getBloodDonationStatus();
  Future<Map<String, dynamic>> toggleBloodDonorStatus();
  Future<void> acceptBloodRequest(String id);
  Future<void> declineBloodRequest(String id);
}

class PatientRepositoryImpl implements PatientRepository {
  final Dio dio;

  PatientRepositoryImpl(this.dio, [bool? isMock]);

  @override
  Future<DashboardSummary> getDashboardSummary(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientDashboardSummary);
    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AiHealthSummary> getAiHealthSummary(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientAiSummary);
    return AiHealthSummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PatientProfile> getPatientProfile(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientProfile);
    return PatientProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PatientProfile> updatePatientProfile(String healthId, PatientProfile profile) async {
    final response = await dio.put(
      ApiEndpoints.patientProfile,
      data: profile.toJson(),
    );
    return PatientProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<HealthEvent>> getHealthEvents(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientTimeline);
    final list = response.data as List<dynamic>;
    return list.map((e) => HealthEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DoctorSpecialist>> getAvailableDoctors() async {
    return [
      DoctorSpecialist(
        id: '1000',
        name: 'Dr. Tariq Ali',
        specialization: 'Gynaecology & Obstetrics',
        hospital: 'BIRDEM General Hospital',
        rating: 4.46,
        experienceYears: 27,
        consultationFee: 600,
        imageUrl: '',
      ),
      DoctorSpecialist(
        id: '1001',
        name: 'Dr. Simin Siddique',
        specialization: 'Urology',
        hospital: 'Kurmitola General Hospital',
        rating: 4.68,
        experienceYears: 8,
        consultationFee: 600,
        imageUrl: '',
      ),
      DoctorSpecialist(
        id: '1002',
        name: 'Dr. Keya Rahman',
        specialization: 'Urology',
        hospital: 'Anwer Khan Modern Medical College Hospital',
        rating: 4.43,
        experienceYears: 18,
        consultationFee: 600,
        imageUrl: '',
      ),
      DoctorSpecialist(
        id: '1003',
        name: 'Dr. Rahim Akter',
        specialization: 'General Surgery',
        hospital: 'Apollo Imperial Hospital',
        rating: 4.8,
        experienceYears: 6,
        consultationFee: 600,
        imageUrl: '',
      ),
      DoctorSpecialist(
        id: '1004',
        name: 'Dr. Selim Hasan',
        specialization: 'General Medicine',
        hospital: 'Anwer Khan Modern Medical College Hospital',
        rating: 4.86,
        experienceYears: 8,
        consultationFee: 500,
        imageUrl: '',
      ),
    ];
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await dio.get(
      ApiEndpoints.doctorSlots(doctorId),
      queryParameters: {'date': dateStr},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Appointment> bookAppointment({
    required String healthId,
    required DoctorSpecialist doctor,
    required DateTime date,
    required String timeSlot,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await dio.post(
      ApiEndpoints.patientAppointments,
      data: {
        'doctorId': doctor.id,
        'date': dateStr,
        'timeSlot': timeSlot,
      },
    );
    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Appointment>> getAppointments(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientAppointments);
    final list = response.data as List<dynamic>;
    return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Prescription>> getPrescriptions(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientPrescriptions);
    final list = response.data as List<dynamic>;
    return list.map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<LabReport>> getLabReports(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientLabReports);
    final list = response.data as List<dynamic>;
    return list.map((e) => LabReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ImagingReport>> getImagingReports(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientImagingReports);
    final list = response.data as List<dynamic>;
    return list.map((e) => ImagingReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await dio.post(ApiEndpoints.cancelAppointment(appointmentId));
  }

  @override
  Future<AiSuggestionResponse> getAiDoctorSuggestion(String healthId, String problemText) async {
    final response = await dio.post(
      '/patients/ai-suggest',
      data: {'problemText': problemText},
    );
    return AiSuggestionResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CopilotBriefing> getCopilotBriefing() async {
    final response = await dio.get(ApiEndpoints.copilotBriefing);
    return CopilotBriefing.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> copilotChat(String message, List<ChatMessage> history) async {
    final response = await dio.post(
      ApiEndpoints.copilotChat,
      data: {
        'message': message,
        'history': history.map((e) => e.toJson()).toList(),
      },
    );
    return (response.data as Map<String, dynamic>)['reply']?.toString() ?? '';
  }

  @override
  Future<MedicationCheck> getMedicationCheck({String? newMedicine}) async {
    final response = await dio.post(
      ApiEndpoints.copilotMedicationCheck,
      data: {if (newMedicine != null && newMedicine.isNotEmpty) 'newMedicine': newMedicine},
    );
    return MedicationCheck.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<RiskRadar> getRiskRadar() async {
    final response = await dio.get(ApiEndpoints.copilotRisk);
    return RiskRadar.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ReportExplanation> explainReport({required String reportType, required String reportId}) async {
    final response = await dio.post(
      ApiEndpoints.copilotExplainReport,
      data: {'reportType': reportType, 'reportId': reportId},
    );
    return ReportExplanation.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getBloodDonationStatus() async {
    final response = await dio.get(ApiEndpoints.bloodDonationStatus);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> toggleBloodDonorStatus() async {
    final response = await dio.post(ApiEndpoints.bloodDonationToggle);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> acceptBloodRequest(String id) async {
    await dio.post(ApiEndpoints.bloodDonationAccept(id));
  }

  @override
  Future<void> declineBloodRequest(String id) async {
    await dio.post(ApiEndpoints.bloodDonationDecline(id));
  }
}

