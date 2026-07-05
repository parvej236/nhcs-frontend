/// A real appointment slot in the doctor's weekly schedule, sourced from the
/// backend `/doctors/schedule` endpoint. No dummy data — every slot maps to a
/// persisted appointment.
class ScheduleSlot {
  final String id;
  final String date; // ISO date, e.g. 2026-06-16
  final String dayOfWeek; // MONDAY, TUESDAY, ...
  final String time; // e.g. 08:00 AM
  final String patientName;
  final String visitType;
  final String department;
  final String arrivalStatus;

  ScheduleSlot({
    required this.id,
    required this.date,
    required this.dayOfWeek,
    required this.time,
    required this.patientName,
    required this.visitType,
    required this.department,
    required this.arrivalStatus,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      dayOfWeek: json['dayOfWeek']?.toString() ?? '',
      time: json['timeSlot']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? 'Unknown',
      visitType: json['visitType']?.toString() ?? 'Consultation',
      department: json['department']?.toString() ?? 'General',
      arrivalStatus: json['arrivalStatus']?.toString() ?? '',
    );
  }
}
