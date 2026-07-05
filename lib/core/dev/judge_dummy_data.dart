// ignore_for_file: constant_identifier_names
//
// ─────────────────────────────────────────────────────────────────────────────
//  JUDGE DUMMY DATA  (TEMPORARY — FOR EVALUATION / DEMO ONLY)
// ─────────────────────────────────────────────────────────────────────────────
//
//  Purpose:
//  Judges / evaluators should not have to hand-type long, realistic clinical
//  data into every text field to test the system. This file holds pre-written,
//  *related* dummy strings for text fields across the whole frontend.
//
//  How it is used:
//  A [JudgeDummyField] (see core/widgets/judge_dummy_field.dart) wraps a normal
//  text field. When a judge taps into the field, a small suggestion box appears
//  under it with a red "for judges testing" label and the dummy value below.
//  Tapping the box autofills the field. No dropdown involved.
//
//  Naming convention (fully descriptive, system-wide):
//      <role>_<screen>_textField_<fieldPurpose>
//
//  e.g. doctor_clinicalWorkspace_textField_symptoms
//       doctor_profile_textField_fullName
//
//  ⚠️  This is scaffolding for evaluation. Remove (or gate behind a debug flag)
//      before any real production release.
// ─────────────────────────────────────────────────────────────────────────────

class JudgeDummyData {
  JudgeDummyData._();

  // Label shown (in red) at the top of every suggestion box.
  static const String suggestionLabel = 'For judges testing — tap to autofill';

  // ───────────────────────────────────────────────────────────────────────────
  //  DOCTOR · CLINICAL WORKSPACE
  //  Scenario: 54-year-old known Type-2 Diabetic + Hypertensive patient
  //  presenting for a routine review. All values below are internally consistent.
  // ───────────────────────────────────────────────────────────────────────────

  static const String doctor_clinicalWorkspace_textField_patientSearchId =
      'NUD-892-441-X7';

  static const String doctor_clinicalWorkspace_textField_symptoms =
      'Excessive thirst and frequent urination for the past 3 weeks';

  static const String doctor_clinicalWorkspace_textField_diagnosis =
      'Type 2 Diabetes Mellitus with poor glycaemic control (E11.9)';

  static const String doctor_clinicalWorkspace_textField_medicationName =
      'Glimepiride';

  static const String doctor_clinicalWorkspace_textField_medicationDosage =
      '1+0+0';

  static const String doctor_clinicalWorkspace_textField_medicationDuration =
      '30 days';

  static const String doctor_clinicalWorkspace_textField_medicationInstructions =
      'Before breakfast, with a full glass of water';

  static const String doctor_clinicalWorkspace_textField_clinicalNotes =
      'Patient reports inconsistent medication compliance and missed one prior '
      'follow-up. Fasting blood glucose trending upward across last three visits. '
      'Reinforced dietary counselling and daily self-monitoring. Advised to '
      'return earlier if symptoms worsen.';

  static const String doctor_clinicalWorkspace_textField_followUp =
      'In 2 weeks';

  static const String doctor_clinicalWorkspace_textField_referral =
      'Dr. Karim — Endocrinology (National Heart Foundation)';

  // ───────────────────────────────────────────────────────────────────────────
  //  PATIENT · APPOINTMENTS  (AI-Powered Appointment Assistant)
  //  The AI symptom checker accepts Bangla or English. This is the dummy Bangla
  //  complaint judges can autofill instead of typing / using voice input.
  // ───────────────────────────────────────────────────────────────────────────

  static const String patient_appointments_textField_aiSymptom =
      'আমার মাথা ব্যাথা ও বমি বমি ভাব, সেই সাথে কয়েকদিন ধরে জ্বর জ্বর লাগছে';

  // ───────────────────────────────────────────────────────────────────────────
  //  DOCTOR · PROFILE
  //  (Ready for wiring when the profile edit form gains real text fields.)
  // ───────────────────────────────────────────────────────────────────────────

  static const String doctor_profile_textField_fullName =
      'Dr. Ahmed Rahman';

  static const String doctor_profile_textField_specialization =
      'Cardiology';

  static const String doctor_profile_textField_bmdcRegistration =
      'A-12345';

  static const String doctor_profile_textField_experienceYears =
      '15 years';

  static const String doctor_profile_textField_languages =
      'Bengali, English, Hindi';
}
