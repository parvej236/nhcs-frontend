import 'package:flutter_riverpod/legacy.dart';

import '../../features/hospital/data/models/lab_test_order.dart';

/// ─────────────────────────────────────────────────────────────────────────
///  SHARED LAB-ORDER FLOW  (single source of truth across all three portals)
/// ─────────────────────────────────────────────────────────────────────────
///
///  This provider connects the previously-disconnected mock stores so a lab
///  test flows end-to-end:
///
///    Doctor (Clinical Workspace)  ──requests──▶  status: 'Ordered'
///        │                                            │
///        ▼                                            ▼
///    Hospital (Laboratory kanban) ──processes/uploads──▶ 'Published'
///        │                                            │
///        ▼                                            ▼
///    Patient (Medical Vault → Lab Reports)  ◀──shows the published report
///
///  Because every portal watches this one [StateNotifier], a change made in
///  one portal is reflected live in the others (no manual refresh needed).
class LabOrdersNotifier extends StateNotifier<List<LabTestOrder>> {
  LabOrdersNotifier() : super(_seed());

  // Counter for generating unique ids for doctor-created orders.
  int _sequence = 900;

  static List<LabTestOrder> _seed() => [
        LabTestOrder(id: 'LB-101', patient: 'Rahim Islam', healthId: 'NUD-892-441-X7', test: 'Complete Blood Count (CBC)', doctor: 'Dr. Ahmed Khan', status: 'Ordered', results: {}),
        LabTestOrder(id: 'LB-102', patient: 'Jahanara Begum', healthId: 'NUD-123-456-A1', test: 'Fasting Blood Glucose', doctor: 'Trauma Lead', status: 'Sample Collected', results: {}),
        LabTestOrder(id: 'LB-103', patient: 'Kamal Hossain', healthId: 'NUD-987-654-B2', test: 'Lipid Profile', doctor: 'Dr. Fatima', status: 'Processing', results: {}),
        LabTestOrder(id: 'LB-104', patient: 'Abdul Karim', healthId: 'NUD-111-222-A2', test: 'Serum Creatinine', doctor: 'Dr. Ahmed Khan', status: 'Verified', results: {'Creatinine': '1.1 mg/dL'}),
        LabTestOrder(id: 'LB-105', patient: 'Hasan Ali', healthId: 'NUD-444-555-C3', test: 'ECG / Electrocardiogram', doctor: 'Trauma Lead', status: 'Published', results: {'Rhythm': 'Normal Sinus Rhythm'}),
      ];

  /// Called by the doctor's Clinical Workspace when a treatment plan with
  /// investigations is submitted. Each requested test enters the lab pipeline
  /// as a fresh 'Ordered' card in the hospital Laboratory queue.
  void addOrdersFromDoctor({
    required String patientName,
    required String healthId,
    required String doctorName,
    required List<String> tests,
  }) {
    if (tests.isEmpty) return;
    final newOrders = tests.map((test) {
      _sequence++;
      return LabTestOrder(
        id: 'LB-$_sequence',
        patient: patientName.isEmpty ? 'Patient' : patientName,
        healthId: healthId,
        test: test,
        doctor: doctorName,
        status: 'Ordered',
        results: {},
      );
    }).toList();
    // Prepend so the newest requests surface at the top of the 'Ordered' column.
    state = [...newOrders, ...state];
  }

  /// Advances a single order through the lab pipeline:
  /// Ordered → Sample Collected → Processing → Verified → Published.
  /// When moving out of 'Processing', the entered [results] (uploaded report)
  /// are attached to the order.
  void advanceStage(String orderId, {Map<String, String>? results}) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(
            status: _nextStatus(order.status),
            results: (order.status == 'Processing' && results != null) ? results : order.results,
          )
        else
          order,
    ];
  }

  /// Publishes a report straight to the patient in a single confirmation step
  /// (used by the redesigned Laboratory "Requested Lab Reports" flow). Sets the
  /// order to 'Published' and attaches the scanned [results] so it immediately
  /// surfaces in the patient's Medical Vault → Lab Reports.
  void publishOrder(String orderId, {Map<String, String>? results}) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(
            status: 'Published',
            results: results ?? order.results,
          )
        else
          order,
    ];
  }

  String _nextStatus(String current) {
    switch (current) {
      case 'Ordered':
        return 'Sample Collected';
      case 'Sample Collected':
        return 'Processing';
      case 'Processing':
        return 'Verified';
      case 'Verified':
        return 'Published';
      default:
        return current;
    }
  }
}

final labOrdersProvider = StateNotifierProvider<LabOrdersNotifier, List<LabTestOrder>>(
  (ref) => LabOrdersNotifier(),
);
