import 'package:dio/dio.dart';
import '../../../patient/data/models/patient_profile.dart';
import '../datasources/doctor_mock_datasource.dart';
import '../models/doctor_dashboard_summary.dart';
import '../models/patient_queue_item.dart';
import '../models/report_review_item.dart';
import '../models/clinical_case.dart';

abstract class DoctorRepository {
  Future<DoctorDashboardSummary> getDashboardSummary();
  Future<List<PatientQueueItem>> getPatientQueue();
  Future<List<ReportReviewItem>> getPendingReports();
  Future<List<String>> getScheduleSlots(String day);
  Future<void> submitTreatmentPlan(TreatmentPlan plan);
  Future<PatientProfile?> getPatientProfileByHealthId(String healthId);
  Future<void> reviewReport(String reportId);
  Future<String> getAiBriefing(String appointmentId);
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
      return DoctorDashboardSummary(
        totalAppointments: queue.length,
        totalFollowUps: queue.where((p) => p.visitType == 'Follow-up').length,
        emergencyCases: queue.where((p) => p.riskIndicator == 'Emergency').length,
        pendingReports: reports.length,
        referredCases: 0,
        aiBriefing: 'System operates under normal clinic volume.',
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

        return PatientQueueItem(
          id: id,
          name: name,
          age: age,
          gender: gender,
          existingDiseases: [item['patientBloodGroup']?.toString() ?? 'O+'],
          riskIndicator: 'Normal',
          visitType: 'Consultation',
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
      // Return mock report reviews for demonstration
      return _datasource.pendingReports;
    } catch (e) {
      return _datasource.pendingReports;
    }
  }

  @override
  Future<List<String>> getScheduleSlots(String day) async {
    return _datasource.scheduleSlots[day] ?? [];
  }

  @override
  Future<void> submitTreatmentPlan(TreatmentPlan plan) async {
    // 1. Submit prescription
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

    await dio.post('/doctors/appointments/${plan.appointmentId}/prescribe', data: prescriptionPayload);

    // 2. Submit lab orders
    for (final test in plan.investigations) {
      final category = test.toLowerCase().contains('blood') || test.toLowerCase().contains('cbc') ? 'Haematology' : 'Biochemistry';
      await dio.post('/doctors/appointments/${plan.appointmentId}/lab-order', data: {
        'testName': test,
        'category': category,
      });
    }
  }

  @override
  Future<PatientProfile?> getPatientProfileByHealthId(String healthId) async {
    try {
      // Since all patient details are embedded in the checked-in active appointment,
      // we can fetch the active queue and retrieve it directly to avoid extra backend queries!
      final queue = await dio.get('/doctors/appointments/active');
      final list = queue.data as List<dynamic>;
      
      final match = list.firstWhere(
        (e) => e['patientHealthId']?.toString() == healthId,
        orElse: () => null,
      );

      if (match != null) {
        final idStr = match['patient']?['id']?.toString() ?? '1';
        final id = int.tryParse(idStr) ?? 1;
        final name = match['patientName']?.toString() ?? 'Rahim Islam';
        final ageStr = match['patientAge']?.toString() ?? '40';
        final age = int.tryParse(ageStr) ?? 40;
        final gender = match['patientGender']?.toString() ?? 'Male';
        final bpSystolic = match['bpSystolic']?.toString() ?? '120';
        final bpDiastolic = match['bpDiastolic']?.toString() ?? '80';
        final bloodGlucose = match['bloodGlucose']?.toString() ?? '95';
        final heartRate = match['heartRate']?.toString() ?? '75';
        final weight = match['weight']?.toString() ?? '70';

        // Parse allergies from patient json
        final List<dynamic> allergiesJson = match['patient']?['allergies'] as List<dynamic>? ?? [];
        final allergies = allergiesJson.map((e) => Allergy(
          allergen: e['allergen']?.toString() ?? '',
          severity: e['severity']?.toString() ?? 'Mild',
          reaction: e['reaction']?.toString() ?? '',
        )).toList();

        // Parse chronic diseases
        final List<dynamic> chronicJson = match['patient']?['chronicDiseases'] as List<dynamic>? ?? [];
        final chronicDiseases = chronicJson.map((e) => ChronicDisease(
          diseaseName: e['diseaseName']?.toString() ?? '',
          status: e['status']?.toString() ?? 'Active',
          diagnosedDate: DateTime.now(),
        )).toList();

        return PatientProfile(
          healthId: healthId,
          name: name,
          dateOfBirth: DateTime.now().subtract(Duration(days: age * 365)),
          gender: gender,
          bloodGroup: match['patientBloodGroup']?.toString() ?? 'O+',
          nationalId: match['patient']?['nationalId']?.toString() ?? '8210398457',
          phone: match['patient']?['contactNumber']?.toString() ?? '+880 1555-555555',
          occupation: match['patient']?['occupation']?.toString() ?? 'Service',
          maritalStatus: match['patient']?['maritalStatus']?.toString() ?? 'Married',
          presentAddress: match['patient']?['presentAddress']?.toString() ?? 'Dhaka, Bangladesh',
          permanentAddress: match['patient']?['permanentAddress']?.toString() ?? 'Dhaka, Bangladesh',
          emergencyContacts: [],
          allergies: allergies,
          chronicDiseases: chronicDiseases,
          vitals: VitalSign(
            bpSystolic: bpSystolic,
            bpDiastolic: bpDiastolic,
            bloodGlucose: bloodGlucose,
            heartRate: heartRate,
            weight: weight,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      // Fallback
    }

    // Default mock fallback to prevent crash
    return PatientProfile(
      healthId: healthId,
      name: 'Rahim Islam',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 40 * 365)),
      gender: 'Male',
      bloodGroup: 'O+',
      nationalId: '8210398457',
      phone: '+880 1555-555555',
      occupation: 'Service',
      maritalStatus: 'Married',
      presentAddress: 'Dhaka, Bangladesh',
      permanentAddress: 'Dhaka, Bangladesh',
      emergencyContacts: [],
      allergies: [],
      chronicDiseases: [],
      vitals: VitalSign(
        bpSystolic: '120',
        bpDiastolic: '80',
        bloodGlucose: '95',
        heartRate: '75',
        weight: '70',
        lastUpdated: DateTime.now(),
      ),
    );
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
}
