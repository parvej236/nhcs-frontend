import 'package:dio/dio.dart';
import '../../../patient/data/models/patient_profile.dart';
import '../datasources/doctor_mock_datasource.dart';
import '../models/doctor_dashboard_summary.dart';
import '../models/patient_queue_item.dart';
import '../models/report_review_item.dart';
import '../models/clinical_case.dart';
import '../models/schedule_slot.dart';

abstract class DoctorRepository {
  Future<DoctorDashboardSummary> getDashboardSummary();
  Future<List<PatientQueueItem>> getPatientQueue();
  Future<List<ReportReviewItem>> getPendingReports();
  Future<List<ScheduleSlot>> getScheduleSlots(String day);
  Future<void> submitTreatmentPlan(TreatmentPlan plan);
  Future<PatientProfile?> getPatientProfileByHealthId(String healthId);
  Future<void> reviewReport(String reportId);
  Future<String> getAiBriefing(String appointmentId);
  Future<Map<String, dynamic>> updateDoctorProfile(Map<String, dynamic> data);
}

class DoctorRepositoryImpl implements DoctorRepository {
  final Dio dio;
  final DoctorMockDatasource _datasource = DoctorMockDatasource();

  DoctorRepositoryImpl(this.dio);

  @override
  Future<DoctorDashboardSummary> getDashboardSummary() async {
    try {
      final queue = await getPatientQueue();
      final reports = await getPendingReports();
      
      final total = queue.length;
      final followups = queue.where((p) => p.visitType == 'Follow-up').length;
      final emergencies = queue.where((p) => p.riskIndicator == 'Emergency').length;
      final pendingReportsCount = reports.length;
      
      String aiBriefing = "Today you have $total consultations, including $followups follow-up visits, and $emergencies emergency cases currently checked in.";
      if (queue.isNotEmpty) {
        aiBriefing += " Your next checked-in patient is ${queue.first.name}, scheduled at ${queue.first.time}.";
      }
      
      return DoctorDashboardSummary(
        totalAppointments: total,
        totalFollowUps: followups,
        emergencyCases: emergencies,
        pendingReports: pendingReportsCount,
        referredCases: queue.where((p) => p.visitType == 'Referral').length,
        aiBriefing: aiBriefing,
      );
    } catch (e) {
      return _datasource.dashboardSummary;
    }
  }

  @override
  Future<List<PatientQueueItem>> getPatientQueue() async {
    try {
      final response = await dio.get('/doctors/appointments/active');
      final data = response.data as List<dynamic>;
      
      return data.map((item) {
        final id = item['id']?.toString() ?? '';
        final name = item['patientName']?.toString() ?? 'Rahim Islam';
        final ageStr = item['patientAge']?.toString() ?? '40';
        final age = int.tryParse(ageStr) ?? 40;
        final gender = item['patientGender']?.toString() ?? 'Male';
        final healthId = item['patientHealthId']?.toString() ?? '';
        final bp = '${item['bpSystolic'] ?? '120'}/${item['bpDiastolic'] ?? '80'}';
        final glucose = item['bloodGlucose']?.toString() ?? '95';
        final timeSlot = item['timeSlot']?.toString() ?? '10:00 AM';
        final riskIndicator = item['riskIndicator']?.toString() ?? 'Low';
        final visitType = item['visitType']?.toString() ?? 'Consultation';

        return PatientQueueItem(
          id: id,
          name: name,
          age: age,
          gender: gender,
          existingDiseases: [item['patientBloodGroup']?.toString() ?? 'O+'],
          riskIndicator: riskIndicator,
          visitType: visitType,
          time: timeSlot,
          healthId: healthId,
        );
      }).toList();
    } catch (e) {
      return _datasource.patientQueue;
    }
  }

  @override
  Future<List<ReportReviewItem>> getPendingReports() async {
    try {
      final response = await dio.get('/doctors/reports/pending');
      final data = response.data as List<dynamic>;
      return data.map((item) => ReportReviewItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _datasource.pendingReports;
    }
  }

  @override
  Future<List<ScheduleSlot>> getScheduleSlots(String day) async {
    // Fetch the doctor's real appointments and keep only the ones falling on
    // the requested weekday. No dummy fallback — an empty schedule stays empty.
    final response = await dio.get('/doctors/schedule');
    final data = response.data as List<dynamic>;
    final target = day.toUpperCase();
    return data
        .map((item) => ScheduleSlot.fromJson(item as Map<String, dynamic>))
        .where((slot) => slot.dayOfWeek.toUpperCase() == target)
        .toList();
  }

  @override
  Future<void> submitTreatmentPlan(TreatmentPlan plan) async {
    // Everything is keyed on the patient's Unified Health ID (NUD-000-<id>) so
    // it persists against the REAL patient being treated — regardless of whether
    // the consultation started from the live queue or a health-ID search. The
    // records land in that patient's Medical Vault and the hospital lab queue.
    final healthId = plan.patientId;
    if (healthId.isEmpty) {
      throw Exception('No patient selected — cannot submit treatment.');
    }

    // 1. Prescription — only raised when there is an actual diagnosis or at least
    //    one prescribed medicine, so we never persist an empty prescription card.
    final hasDiagnosis = plan.diagnoses.isNotEmpty;
    final hasMedicines = plan.medicines.isNotEmpty;
    if (hasDiagnosis || hasMedicines) {
      final prescriptionPayload = {
        'diagnosis': plan.diagnoses.map((d) => d.diseaseName).join(', '),
        'clinicalNotes': plan.clinicalNotes,
        'followUpDate': plan.followUp,
        'medicines': plan.medicines.map((m) => {
          'name': m.medicineName,
          'dosage': m.dosage,
          'instruction': m.instructions,
          'duration': m.duration,
        }).toList(),
      };
      await dio.post('/doctors/patients/$healthId/prescribe', data: prescriptionPayload);
    }

    // 2. Lab-test requests — one persisted order per selected investigation.
    for (final test in plan.investigations) {
      final lower = test.toLowerCase();
      final category = lower.contains('blood') || lower.contains('cbc') || lower.contains('glucose') || lower.contains('hba1c')
          ? 'Haematology'
          : 'Biochemistry';
      await dio.post('/doctors/patients/$healthId/lab-order', data: {
        'testName': test,
        'category': category,
      });
    }
  }

  @override
  Future<PatientProfile?> getPatientProfileByHealthId(String healthId) async {
    // Load the REAL patient by their Unified Health ID from the backend. No dummy
    // fallback — if the ID is unknown we return null so the UI shows "not found"
    // instead of another patient's data.
    try {
      final response = await dio.get('/patients/$healthId/profile');
      return PatientProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> reviewReport(String reportId) async {
    // Review report mock completion
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<String> getAiBriefing(String appointmentId) async {
    final response = await dio.post('/doctors/appointments/$appointmentId/ai-briefing');
    return response.data['briefing']?.toString() ?? 'Clinical briefing generation failed.';
  }

  @override
  Future<Map<String, dynamic>> updateDoctorProfile(Map<String, dynamic> data) async {
    final response = await dio.put('/doctors/profile', data: data);
    return response.data as Map<String, dynamic>;
  }
}
