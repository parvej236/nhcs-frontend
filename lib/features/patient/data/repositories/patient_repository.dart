import '../models/appointment.dart';
import '../models/dashboard_summary.dart';
import '../models/health_event.dart';
import '../models/medical_record.dart';
import '../models/patient_profile.dart';
import '../datasources/patient_mock_datasource.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

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
}

class PatientRepositoryImpl implements PatientRepository {
  final _datasource = PatientMockDatasource();
  final ApiClient _apiClient;

  PatientRepositoryImpl(this._apiClient);

  // Simulate network latency
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<DashboardSummary> getDashboardSummary(String healthId) async {
    await _delay();
    return _datasource.dashboardSummary;
  }

  @override
  Future<AiHealthSummary> getAiHealthSummary(String healthId) async {
    await _delay();
    return _datasource.aiHealthSummary;
  }

  @override
  Future<PatientProfile> getPatientProfile(String healthId) async {
    try {
      final response = await _apiClient.dio.get('/patients/me');
      return _mapBackendPatientToProfile(response.data);
    } catch (e) {
      print('Error fetching profile from backend: $e. Falling back to mock.');
      await _delay();
      return _datasource.profile;
    }
  }

  @override
  Future<PatientProfile> updatePatientProfile(String healthId, PatientProfile profile) async {
    try {
      final data = {
        'fullName': profile.name,
        'dateOfBirth': profile.dateOfBirth.toIso8601String().split('T')[0],
        'gender': profile.gender,
        'bloodGroup': profile.bloodGroup,
        'contactNumber': profile.phone,
        'occupation': profile.occupation,
        'maritalStatus': profile.maritalStatus,
        'presentAddress': profile.presentAddress,
        'permanentAddress': profile.permanentAddress,
        'emergencyContactName': profile.emergencyContacts.isNotEmpty ? profile.emergencyContacts.first.name : null,
        'emergencyContactRelation': profile.emergencyContacts.isNotEmpty ? profile.emergencyContacts.first.relationship : null,
        'emergencyContactPhone': profile.emergencyContacts.isNotEmpty ? profile.emergencyContacts.first.phone : null,
      };
      
      final response = await _apiClient.dio.put('/patients/me', data: data);
      final updatedProfile = _mapBackendPatientToProfile(response.data);
      // Update mock data for consistency in other mock methods
      _datasource.profile = updatedProfile;
      return updatedProfile;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  PatientProfile _mapBackendPatientToProfile(Map<String, dynamic> data) {
    // Merge backend data with mock data to preserve vitals/history which aren't in backend yet
    final mock = _datasource.profile;
    
    List<EmergencyContact> contacts = [];
    if (data['emergencyContactName'] != null) {
      contacts.add(EmergencyContact(
        name: data['emergencyContactName'],
        relationship: data['emergencyContactRelation'] ?? '',
        phone: data['emergencyContactPhone'] ?? '',
      ));
    }

    return PatientProfile(
      healthId: mock.healthId,
      name: data['fullName'] ?? mock.name,
      dateOfBirth: data['dateOfBirth'] != null ? DateTime.parse(data['dateOfBirth']) : mock.dateOfBirth,
      gender: data['gender'] ?? mock.gender,
      bloodGroup: data['bloodGroup'] ?? mock.bloodGroup,
      nationalId: mock.nationalId,
      phone: data['contactNumber'] ?? mock.phone,
      occupation: data['occupation'] ?? mock.occupation,
      maritalStatus: data['maritalStatus'] ?? mock.maritalStatus,
      presentAddress: data['presentAddress'] ?? mock.presentAddress,
      permanentAddress: data['permanentAddress'] ?? mock.permanentAddress,
      emergencyContacts: contacts.isNotEmpty ? contacts : mock.emergencyContacts,
      allergies: mock.allergies,
      chronicDiseases: mock.chronicDiseases,
      vitals: mock.vitals,
    );
  }

  @override
  Future<List<HealthEvent>> getHealthEvents(String healthId) async {
    await _delay();
    return _datasource.healthEvents;
  }

  @override
  Future<List<DoctorSpecialist>> getAvailableDoctors() async {
    await _delay();
    return _datasource.availableDoctors;
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    await _delay();
    // In a real app we would query slots for that doctor on that date
    return _datasource.timeSlots;
  }

  @override
  Future<Appointment> bookAppointment({
    required String healthId,
    required DoctorSpecialist doctor,
    required DateTime date,
    required String timeSlot,
  }) async {
    await _delay();
    final newAppointment = Appointment(
      id: 'APP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      doctor: doctor,
      date: date,
      timeSlot: timeSlot,
      hospital: doctor.hospital,
      queueNumber: 'Q-09',
      status: 'Upcoming',
    );
    _datasource.appointments.insert(0, newAppointment);
    return newAppointment;
  }

  @override
  Future<List<Appointment>> getAppointments(String healthId) async {
    await _delay();
    return _datasource.appointments;
  }

  @override
  Future<List<Prescription>> getPrescriptions(String healthId) async {
    await _delay();
    return _datasource.prescriptions;
  }

  @override
  Future<List<LabReport>> getLabReports(String healthId) async {
    await _delay();
    return _datasource.labReports;
  }

  @override
  Future<List<ImagingReport>> getImagingReports(String healthId) async {
    await _delay();
    return _datasource.imagingReports;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await _delay();
    final index = _datasource.appointments.indexWhere((app) => app.id == appointmentId);
    if (index != -1) {
      final oldApp = _datasource.appointments[index];
      _datasource.appointments[index] = Appointment(
        id: oldApp.id,
        doctor: oldApp.doctor,
        date: oldApp.date,
        timeSlot: oldApp.timeSlot,
        hospital: oldApp.hospital,
        queueNumber: oldApp.queueNumber,
        status: 'Cancelled',
      );
    }
  }
}
