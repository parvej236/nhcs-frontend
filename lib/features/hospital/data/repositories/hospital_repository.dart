import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:uhcs/features/patient/data/models/appointment.dart';
import '../datasources/hospital_mock_datasource.dart';
import '../models/hospital_dashboard_stats.dart';
import '../models/reception_queue_item.dart';
import '../models/staff_member.dart';
import '../models/lab_test_order.dart';
import '../models/bed_allocation.dart';
import '../models/pharmacy_item.dart';

abstract class HospitalRepository {
  Future<HospitalDashboardStats> getDashboardStats();
  Future<List<ReceptionQueueItem>> getReceptionQueue();
  Future<List<Appointment>> getPendingAppointments();
  Future<List<Appointment>> searchAppointments(String query);
  Future<void> approveAppointment(String id);
  Future<void> rejectAppointment(String id);
  Future<List<StaffMember>> getStaffMembers();
  Future<List<DoctorVerificationRequest>> getDoctorVerificationRequests();
  Future<List<LabTestOrder>> getLabTestOrders();
  Future<void> publishLabOrder(String orderId, List<Map<String, String>> results);
  Future<List<BedAllocation>> getBedAllocations();
  Future<List<PharmacyItem>> getPharmacyItems();
  Future<Map<String, dynamic>?> getPrescriptionById(String rxId);

  Future<void> checkInPatient(String name, String age, String gender, String healthId, String dept, String doctor);
  Future<void> updateQueueStatus(String queueNo, String newStatus);
  Future<void> updateStaffShift(String staffId, String day, String newShift);
  Future<void> verifyDoctorRequest(String requestId, String status);
  Future<void> advanceLabOrder(String orderId, Map<String, String>? results);
  Future<void> admitPatientToBed(String bedId, String patientName, String healthId, String doctor);
  Future<void> dischargePatientFromBed(String bedId);
  Future<bool> dispenseDrugs(String rxId);
  Future<void> addStaffMember(StaffMember staff);
}

class HospitalRepositoryImpl implements HospitalRepository {
  final Dio dio;
  final HospitalMockDatasource _datasource = HospitalMockDatasource();

  HospitalRepositoryImpl(this.dio);

  @override
  Future<void> addStaffMember(StaffMember staff) async {
    _datasource.staffMembers.add(staff);
  }

  @override
  Future<HospitalDashboardStats> getDashboardStats() async {
    try {
      final response = await dio.get(ApiEndpoints.hospitalDashboardOverview);
      final data = response.data as Map<String, dynamic>;
      
      final alertsJson = data['alerts'] as List<dynamic>? ?? [];
      final alerts = alertsJson.map((a) => OperationalAlert(
        id: a['id']?.toString() ?? '',
        title: a['title']?.toString() ?? '',
        description: a['description']?.toString() ?? '',
        timeAgo: a['timeAgo']?.toString() ?? '',
        type: a['type']?.toString() ?? 'info',
      )).toList();

      final deptLoadsJson = data['departmentLoads'] as List<dynamic>? ?? [];
      final deptLoads = deptLoadsJson.map((d) => DepartmentLoad(
        name: d['name']?.toString() ?? '',
        patients: d['patients'] as int? ?? 0,
        staff: d['staff'] as int? ?? 0,
        load: d['load']?.toString() ?? 'Normal',
      )).toList();

      return HospitalDashboardStats(
        activePatients: data['activePatients'] as int? ?? 0,
        bedOccupancyRate: (data['bedOccupancyRate'] as num?)?.toDouble() ?? 0.0,
        totalBeds: data['totalBeds'] as int? ?? 0,
        occupiedBeds: data['occupiedBeds'] as int? ?? 0,
        onDutyStaff: data['onDutyStaff'] as int? ?? 0,
        onDutyDoctors: data['onDutyDoctors'] as int? ?? 0,
        onDutyNurses: data['onDutyNurses'] as int? ?? 0,
        emergencyIntake: data['emergencyIntake'] as int? ?? 0,
        criticalCases: data['criticalCases'] as int? ?? 0,
        alerts: alerts,
        departmentLoads: deptLoads,
      );
    } catch (e) {
      return _datasource.dashboardStats;
    }
  }

  @override
  Future<List<ReceptionQueueItem>> getReceptionQueue() async {
    try {
      final response = await dio.get('/hospitals/reception/queue');
      final data = response.data as List<dynamic>;
      return data.map((item) => ReceptionQueueItem(
        queueNo: item['queueNo']?.toString() ?? '',
        name: item['name']?.toString() ?? '',
        age: item['age']?.toString() ?? '40',
        gender: item['gender']?.toString() ?? 'M',
        dept: item['dept']?.toString() ?? '',
        doctor: item['doctor']?.toString() ?? '',
        status: item['status']?.toString() ?? 'Waiting',
      )).toList();
    } catch (e) {
      return _datasource.receptionQueue;
    }
  }

  @override
  Future<List<Appointment>> getPendingAppointments() async {
    try {
      final response = await dio.get(ApiEndpoints.hospitalPendingAppointments);
      final list = response.data as List<dynamic>;
      return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> approveAppointment(String id) async {
    await dio.put(ApiEndpoints.hospitalApproveAppointment(id));
  }

  @override
  Future<void> rejectAppointment(String id) async {
    await dio.put(ApiEndpoints.hospitalRejectAppointment(id));
  }

  @override
  Future<List<Appointment>> searchAppointments(String query) async {
    try {
      final response = await dio.get(ApiEndpoints.hospitalSearchAppointments(query));
      final list = response.data as List<dynamic>;
      return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StaffMember>> getStaffMembers() async {
    return _datasource.staffMembers;
  }

  @override
  Future<List<DoctorVerificationRequest>> getDoctorVerificationRequests() async {
    return _datasource.verificationRequests;
  }

  @override
  Future<List<LabTestOrder>> getLabTestOrders() async {
    // Real pending lab requests raised by doctors, straight from the backend.
    final response = await dio.get('/hospitals/lab-orders');
    final data = response.data as List<dynamic>;
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return LabTestOrder(
        id: map['id']?.toString() ?? '',
        patient: map['patientName']?.toString() ?? 'Unknown',
        healthId: map['healthId']?.toString() ?? '',
        test: map['testName']?.toString() ?? '',
        doctor: map['doctorName']?.toString() ?? 'Attending Physician',
        status: map['status']?.toString() ?? 'PENDING',
        results: const {},
      );
    }).toList();
  }

  @override
  Future<void> publishLabOrder(String orderId, List<Map<String, String>> results) async {
    // Publishes the scanned report to the backend. The report is marked
    // 'Published' and its results attached, so it flows into the patient's
    // Medical Vault (/patients/me/lab-reports).
    await dio.post('/hospitals/lab-orders/$orderId/results', data: {'results': results});
  }

  @override
  Future<List<BedAllocation>> getBedAllocations() async {
    return _datasource.beds;
  }

  @override
  Future<List<PharmacyItem>> getPharmacyItems() async {
    return _datasource.pharmacyItems;
  }

  @override
  Future<Map<String, dynamic>?> getPrescriptionById(String rxId) async {
    return _datasource.mockPrescriptions[rxId];
  }

  @override
  Future<void> checkInPatient(String name, String age, String gender, String healthId, String dept, String doctor) async {
    try {
      await dio.put('/hospitals/appointments/check-in-by-patient', queryParameters: {'healthId': healthId});
    } catch (e) {
      // Fallback to local datasource if API fails or doesn't exist
      final String prefix = dept == 'Emergency' ? 'EM' : 'CD';
      final int nextNo = _datasource.receptionQueue.where((p) => p.dept == dept).length + 1;
      final newItem = ReceptionQueueItem(
        queueNo: '$prefix-${nextNo.toString().padLeft(2, '0')}',
        name: name,
        age: age,
        gender: gender,
        dept: dept,
        doctor: doctor,
        status: 'Waiting',
      );
      _datasource.receptionQueue.add(newItem);
    }
  }

  @override
  Future<void> updateQueueStatus(String queueNo, String newStatus) async {
    try {
      await dio.put('/hospitals/reception/queue/$queueNo/status', queryParameters: {'status': newStatus});
    } catch (e) {
      final idx = _datasource.receptionQueue.indexWhere((p) => p.queueNo == queueNo);
      if (idx != -1) {
        _datasource.receptionQueue[idx] = _datasource.receptionQueue[idx].copyWith(status: newStatus);
      }
    }
  }

  @override
  Future<void> updateStaffShift(String staffId, String day, String newShift) async {
    final idx = _datasource.staffMembers.indexWhere((s) => s.id == staffId);
    if (idx != -1) {
      final updatedShifts = Map<String, String>.from(_datasource.staffMembers[idx].shifts);
      updatedShifts[day] = newShift;
      _datasource.staffMembers[idx] = _datasource.staffMembers[idx].copyWith(shifts: updatedShifts);
    }
  }

  @override
  Future<void> verifyDoctorRequest(String requestId, String status) async {
    final idx = _datasource.verificationRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _datasource.verificationRequests[idx] = _datasource.verificationRequests[idx].copyWith(status: status);
    }
  }

  @override
  Future<void> advanceLabOrder(String orderId, Map<String, String>? results) async {
    final idx = _datasource.labOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final current = _datasource.labOrders[idx];
      String nextStatus = current.status;
      Map<String, String> updatedResults = Map.from(current.results);

      if (current.status == 'Ordered') {
        nextStatus = 'Sample Collected';
      } else if (current.status == 'Sample Collected') {
        nextStatus = 'Processing';
      } else if (current.status == 'Processing') {
        if (results != null) {
          updatedResults = results;
        }
        nextStatus = 'Verified';
      } else if (current.status == 'Verified') {
        nextStatus = 'Published';
      }

      _datasource.labOrders[idx] = current.copyWith(
        status: nextStatus,
        results: updatedResults,
      );
    }
  }

  @override
  Future<void> admitPatientToBed(String bedId, String patientName, String healthId, String doctor) async {
    final idx = _datasource.beds.indexWhere((b) => b.id == bedId);
    if (idx != -1) {
      _datasource.beds[idx] = _datasource.beds[idx].copyWith(
        status: 'Occupied',
        patient: patientName,
        healthId: healthId,
        doctor: doctor,
        days: 0,
      );
    }
  }

  @override
  Future<void> dischargePatientFromBed(String bedId) async {
    final idx = _datasource.beds.indexWhere((b) => b.id == bedId);
    if (idx != -1) {
      _datasource.beds[idx] = _datasource.beds[idx].copyWith(
        status: 'Available',
        clearPatientData: true,
      );
    }
  }

  @override
  Future<bool> dispenseDrugs(String rxId) async {
    return true;
  }
}

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return HospitalRepositoryImpl(dio);
});
