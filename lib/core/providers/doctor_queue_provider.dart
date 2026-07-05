import 'package:flutter_riverpod/legacy.dart';

import '../../features/doctor/data/models/patient_queue_item.dart';

/// ─────────────────────────────────────────────────────────────────────────
///  SHARED DOCTOR QUEUE  (patient booking → doctor's queue, in real time)
/// ─────────────────────────────────────────────────────────────────────────
///
///  When a patient books an appointment it is added directly to the booked
///  doctor's live queue — no hospital confirmation step. The doctor's Dashboard
///  watches this provider, so a new booking appears immediately.
///
///  Seeded empty on purpose (no dummy appointments): the queue only ever shows
///  real bookings made during the session.
class DoctorQueueNotifier extends StateNotifier<List<PatientQueueItem>> {
  DoctorQueueNotifier() : super([]);

  int _sequence = 0;

  void setQueue(List<PatientQueueItem> newQueue) {
    state = newQueue;
  }

  /// Adds a freshly-booked patient to the doctor's queue.
  void addBookedPatient({
    required String name,
    required int age,
    required String gender,
    required String healthId,
    required String time,
    String visitType = 'First Consultation',
    List<String> existingDiseases = const [],
    String riskIndicator = 'Low',
  }) {
    _sequence++;
    final item = PatientQueueItem(
      id: 'BK-$_sequence',
      name: name.isEmpty ? 'Patient' : name,
      age: age,
      gender: gender,
      existingDiseases: existingDiseases,
      riskIndicator: riskIndicator,
      visitType: visitType,
      time: time,
      healthId: healthId,
    );
    state = [...state, item];
  }

  /// Removes a patient from the queue once their consultation is complete
  /// (called after the doctor submits a treatment plan).
  void removeByHealthId(String healthId) {
    if (healthId.isEmpty) return;
    state = state.where((p) => p.healthId != healthId).toList();
  }
}

final doctorQueueProvider = StateNotifierProvider<DoctorQueueNotifier, List<PatientQueueItem>>(
  (ref) => DoctorQueueNotifier(),
);
