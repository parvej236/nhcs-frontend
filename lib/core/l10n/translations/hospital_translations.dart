import '../app_language.dart';

/// Hospital authority portal page strings. Keys are prefixed with `hospital_`.
/// Populated by the hospital-pages localization pass. Sub-prefixes map to pages:
///   hospital_cc_    -> command_center_page
///   hospital_blood_ -> blood_donation_management_page
///   hospital_recep_ -> reception_queue_page
///   hospital_appr_  -> appointment_approvals_page
///   hospital_lab_   -> laboratory_page
///   hospital_staff_ -> staff_management_page
///   hospital_pharm_ -> pharmacy_page
///   hospital_bed_   -> bed_management_page
const Map<String, Map<AppLanguage, String>> hospitalTranslations = {
  // ===== command_center_page.dart (hospital_cc_) =====
  'hospital_cc_ai_forecast_title': {
    AppLanguage.english: 'ICU & Workforce Optimization Forecast',
    AppLanguage.bengali: 'ICU ও জনবল সর্বোত্তমীকরণের পূর্বাভাস',
  },
  'hospital_cc_ai_forecast_desc': {
    AppLanguage.english:
        'AI model predicts a 15% increase in emergency intake over the next 6 hours due to local holiday traffic. ICU capacity is currently at critical levels.',
    AppLanguage.bengali:
        'স্থানীয় ছুটির চাপে আগামী ৬ ঘণ্টায় জরুরি রোগী ভর্তি ১৫% বাড়বে বলে AI মডেল পূর্বাভাস দিচ্ছে। ICU ধারণক্ষমতা বর্তমানে সংকটজনক পর্যায়ে রয়েছে।',
  },
  'hospital_cc_ai_rec_1': {
    AppLanguage.english: 'Pre-emptively route non-emergency triage to OPD wings.',
    AppLanguage.bengali: 'অ-জরুরি ট্রায়াজ রোগীদের আগেভাগেই OPD উইংয়ে পাঠান।',
  },
  'hospital_cc_ai_rec_2': {
    AppLanguage.english: 'Onboard call-shift nurses for the 8 PM - 2 AM block.',
    AppLanguage.bengali: 'রাত ৮টা - ২টা শিফটের জন্য কল-শিফট নার্স নিয়োগ করুন।',
  },
  'hospital_cc_ai_rec_3': {
    AppLanguage.english: 'Coordinate with Dhaka South general ward for tertiary back-up beds.',
    AppLanguage.bengali: 'তৃতীয় স্তরের ব্যাকআপ শয্যার জন্য ঢাকা দক্ষিণ জেনারেল ওয়ার্ডের সঙ্গে সমন্বয় করুন।',
  },
  'hospital_cc_hospital_name': {
    AppLanguage.english: 'Dhaka Central Hospital',
    AppLanguage.bengali: 'ঢাকা কেন্দ্রীয় হাসপাতাল',
  },
  'hospital_cc_connected_status': {
    AppLanguage.english: 'Connected to National Ecosystem • Live Feed',
    AppLanguage.bengali: 'জাতীয় ইকোসিস্টেমের সঙ্গে সংযুক্ত • লাইভ ফিড',
  },
  'hospital_cc_last_sync': {
    AppLanguage.english: 'Last Sync',
    AppLanguage.bengali: 'সর্বশেষ সিঙ্ক',
  },
  'hospital_cc_sync_live_data': {
    AppLanguage.english: 'Sync Live Data',
    AppLanguage.bengali: 'লাইভ ডেটা সিঙ্ক করুন',
  },
  'hospital_cc_active_patients': {
    AppLanguage.english: 'Active Patients',
    AppLanguage.bengali: 'সক্রিয় রোগী',
  },
  'hospital_cc_trend_from_yesterday': {
    AppLanguage.english: '+12% from yesterday',
    AppLanguage.bengali: 'গতকালের তুলনায় +১২%',
  },
  'hospital_cc_bed_occupancy': {
    AppLanguage.english: 'Bed Occupancy',
    AppLanguage.bengali: 'শয্যা দখল',
  },
  'hospital_cc_occupied': {
    AppLanguage.english: 'Occupied',
    AppLanguage.bengali: 'দখলকৃত',
  },
  'hospital_cc_beds_available': {
    AppLanguage.english: 'beds available',
    AppLanguage.bengali: 'শয্যা খালি',
  },
  'hospital_cc_on_duty_staff': {
    AppLanguage.english: 'On-Duty Staff',
    AppLanguage.bengali: 'কর্মরত স্টাফ',
  },
  'hospital_cc_doctors': {
    AppLanguage.english: 'Doctors',
    AppLanguage.bengali: 'ডাক্তার',
  },
  'hospital_cc_nurses': {
    AppLanguage.english: 'Nurses',
    AppLanguage.bengali: 'নার্স',
  },
  'hospital_cc_all_shifts_covered': {
    AppLanguage.english: 'All shifts covered',
    AppLanguage.bengali: 'সব শিফট পূর্ণ',
  },
  'hospital_cc_emergency_intake': {
    AppLanguage.english: 'Emergency Intake',
    AppLanguage.bengali: 'জরুরি রোগী ভর্তি',
  },
  'hospital_cc_critical_cases': {
    AppLanguage.english: 'Critical Cases',
    AppLanguage.bengali: 'সংকটজনক কেস',
  },
  'hospital_cc_response_time': {
    AppLanguage.english: 'Response time: 4m',
    AppLanguage.bengali: 'সাড়াদানের সময়: ৪ মিনিট',
  },
  'hospital_cc_department_triage_load': {
    AppLanguage.english: 'Department Triage Load',
    AppLanguage.bengali: 'বিভাগভিত্তিক ট্রায়াজ চাপ',
  },
  'hospital_cc_patients': {
    AppLanguage.english: 'patients',
    AppLanguage.bengali: 'রোগী',
  },
  'hospital_cc_staff_on_duty': {
    AppLanguage.english: 'staff on duty',
    AppLanguage.bengali: 'কর্মরত স্টাফ',
  },
  'hospital_cc_intake_volume_title': {
    AppLanguage.english: 'Patient Intake Volume (24 Hours)',
    AppLanguage.bengali: 'রোগী ভর্তির পরিমাণ (২৪ ঘণ্টা)',
  },
  'hospital_cc_intake_volume_desc': {
    AppLanguage.english: 'Displays the hourly patient intake numbers, highlighting peak hours.',
    AppLanguage.bengali: 'ঘণ্টাভিত্তিক রোগী ভর্তির সংখ্যা দেখায়, ব্যস্ততম সময়গুলো চিহ্নিত করে।',
  },
  'hospital_cc_legend_emergency': {
    AppLanguage.english: 'Emergency Admissions',
    AppLanguage.bengali: 'জরুরি ভর্তি',
  },
  'hospital_cc_legend_opd': {
    AppLanguage.english: 'OPD Consultations',
    AppLanguage.bengali: 'OPD পরামর্শ',
  },
  'hospital_cc_operational_alerts': {
    AppLanguage.english: 'Operational Alerts',
    AppLanguage.bengali: 'পরিচালনাগত সতর্কতা',
  },

  // ===== blood_donation_management_page.dart (hospital_blood_) =====
  'hospital_blood_notify_success': {
    AppLanguage.english: 'Notification sent successfully to',
    AppLanguage.bengali: 'সফলভাবে নোটিফিকেশন পাঠানো হয়েছে',
  },
  'hospital_blood_notify_failed': {
    AppLanguage.english: 'Failed to notify donor',
    AppLanguage.bengali: 'ডোনারকে জানাতে ব্যর্থ হয়েছে',
  },
  'hospital_blood_tab_pending': {
    AppLanguage.english: 'Pending Requests',
    AppLanguage.bengali: 'অপেক্ষমাণ অনুরোধ',
  },
  'hospital_blood_tab_accepted_closed': {
    AppLanguage.english: 'Accepted & Closed',
    AppLanguage.bengali: 'গৃহীত ও সম্পন্ন',
  },
  'hospital_blood_portal_title': {
    AppLanguage.english: 'Blood Donation Portal',
    AppLanguage.bengali: 'রক্তদান পোর্টাল',
  },
  'hospital_blood_portal_subtitle': {
    AppLanguage.english: 'Manage patient blood requests and utilize AI matchmaking to locate active compatible donors.',
    AppLanguage.bengali: 'রোগীদের রক্তের অনুরোধ পরিচালনা করুন এবং সক্রিয় উপযুক্ত ডোনার খুঁজে পেতে AI ম্যাচমেকিং ব্যবহার করুন।',
  },
  'hospital_blood_refresh': {
    AppLanguage.english: 'Refresh',
    AppLanguage.bengali: 'রিফ্রেশ',
  },
  'hospital_blood_empty_pending': {
    AppLanguage.english: 'No pending blood requests',
    AppLanguage.bengali: 'কোনো অপেক্ষমাণ রক্তের অনুরোধ নেই',
  },
  'hospital_blood_empty_accepted': {
    AppLanguage.english: 'No accepted blood requests',
    AppLanguage.bengali: 'কোনো গৃহীত রক্তের অনুরোধ নেই',
  },
  'hospital_blood_run_ai_matcher': {
    AppLanguage.english: 'Run AI Matcher',
    AppLanguage.bengali: 'AI ম্যাচার চালান',
  },
  'hospital_blood_accepted': {
    AppLanguage.english: 'Accepted',
    AppLanguage.bengali: 'গৃহীত',
  },
  'hospital_blood_patient_medical_history': {
    AppLanguage.english: 'PATIENT MEDICAL HISTORY',
    AppLanguage.bengali: 'রোগীর চিকিৎসা ইতিহাস',
  },
  'hospital_blood_matched_donor_details': {
    AppLanguage.english: 'MATCHED DONOR DETAILS',
    AppLanguage.bengali: 'ম্যাচকৃত ডোনারের বিবরণ',
  },
  'hospital_blood_blood_group_label': {
    AppLanguage.english: 'Blood Group',
    AppLanguage.bengali: 'রক্তের গ্রুপ',
  },
  'hospital_blood_address_label': {
    AppLanguage.english: 'Address',
    AppLanguage.bengali: 'ঠিকানা',
  },
  'hospital_blood_no_contact': {
    AppLanguage.english: 'No contact',
    AppLanguage.bengali: 'কোনো যোগাযোগ নম্বর নেই',
  },
  'hospital_blood_ai_donor_matcher': {
    AppLanguage.english: 'AI Donor Matcher',
    AppLanguage.bengali: 'AI ডোনার ম্যাচার',
  },
  'hospital_blood_searching_for': {
    AppLanguage.english: 'Searching compatible active donors for',
    AppLanguage.bengali: 'উপযুক্ত সক্রিয় ডোনার খোঁজা হচ্ছে',
  },
  'hospital_blood_analyzing': {
    AppLanguage.english: 'Analyzing donor pool & location factors...',
    AppLanguage.bengali: 'ডোনার পুল ও অবস্থানগত বিষয় বিশ্লেষণ করা হচ্ছে...',
  },
  'hospital_blood_no_matches': {
    AppLanguage.english: 'No matching active donors found in the database.',
    AppLanguage.bengali: 'ডাটাবেসে কোনো উপযুক্ত সক্রিয় ডোনার পাওয়া যায়নি।',
  },
  'hospital_blood_distance': {
    AppLanguage.english: 'Distance',
    AppLanguage.bengali: 'দূরত্ব',
  },
  'hospital_blood_km': {
    AppLanguage.english: 'km',
    AppLanguage.bengali: 'কিমি',
  },
  'hospital_blood_match': {
    AppLanguage.english: 'MATCH',
    AppLanguage.bengali: 'ম্যাচ',
  },
  'hospital_blood_eligible_desc': {
    AppLanguage.english: 'Donor is active, healthy & eligible to donate.',
    AppLanguage.bengali: 'ডোনার সক্রিয়, সুস্থ এবং রক্তদানের জন্য উপযুক্ত।',
  },
  'hospital_blood_deferred': {
    AppLanguage.english: 'Deferred',
    AppLanguage.bengali: 'স্থগিত',
  },
  'hospital_blood_send_match_request': {
    AppLanguage.english: 'Send Match Request',
    AppLanguage.bengali: 'ম্যাচ অনুরোধ পাঠান',
  },
  'hospital_blood_unknown_patient': {
    AppLanguage.english: 'Unknown Patient',
    AppLanguage.bengali: 'অজ্ঞাত রোগী',
  },
  'hospital_blood_general_hospital': {
    AppLanguage.english: 'General Hospital',
    AppLanguage.bengali: 'জেনারেল হাসপাতাল',
  },
  'hospital_blood_unknown_location': {
    AppLanguage.english: 'Unknown Location',
    AppLanguage.bengali: 'অজ্ঞাত অবস্থান',
  },
  'hospital_blood_unknown_donor': {
    AppLanguage.english: 'Unknown Donor',
    AppLanguage.bengali: 'অজ্ঞাত ডোনার',
  },

  // ===== reception_queue_page.dart (hospital_recep_) =====
  'hospital_recep_checked_in_prefix': {
    AppLanguage.english: 'Checked in',
    AppLanguage.bengali: 'চেক-ইন সম্পন্ন হয়েছে',
  },
  'hospital_recep_checked_in_mid': {
    AppLanguage.english: 'for',
    AppLanguage.bengali: '—',
  },
  'hospital_recep_checked_in_suffix': {
    AppLanguage.english: 'Queue!',
    AppLanguage.bengali: 'কিউতে যুক্ত করা হয়েছে!',
  },
  'hospital_recep_checkin_failed': {
    AppLanguage.english: 'Failed to check in patient. please try again.',
    AppLanguage.bengali: 'রোগী চেক-ইন করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।',
  },
  'hospital_recep_checkin_desk_title': {
    AppLanguage.english: 'Patient Check-In Desk',
    AppLanguage.bengali: 'রোগী চেক-ইন ডেস্ক',
  },
  'hospital_recep_checkin_desk_subtitle': {
    AppLanguage.english: 'Search for registered patients by Digital Health ID, NID or name to verify bookings and check in.',
    AppLanguage.bengali: 'বুকিং যাচাই ও চেক-ইনের জন্য ডিজিটাল হেলথ আইডি, এনআইডি বা নাম দিয়ে নিবন্ধিত রোগী খুঁজুন।',
  },
  'hospital_recep_lookup_title': {
    AppLanguage.english: 'Lookup Citizen Record',
    AppLanguage.bengali: 'নাগরিকের রেকর্ড খুঁজুন',
  },
  'hospital_recep_search_label': {
    AppLanguage.english: 'NHCS Health ID / NID / Name',
    AppLanguage.bengali: 'NHCS হেলথ আইডি / এনআইডি / নাম',
  },
  'hospital_recep_search_hint': {
    AppLanguage.english: 'e.g., NUD-000-1 or Rahim Islam',
    AppLanguage.bengali: 'যেমন, NUD-000-1 বা Rahim Islam',
  },
  'hospital_recep_find_patient': {
    AppLanguage.english: 'Find Patient',
    AppLanguage.bengali: 'রোগী খুঁজুন',
  },
  'hospital_recep_search_help': {
    AppLanguage.english: 'Try searching "NUD-000-1" (Rahim Islam) or patient name',
    AppLanguage.bengali: '"NUD-000-1" (Rahim Islam) অথবা রোগীর নাম দিয়ে খুঁজে দেখুন',
  },
  'hospital_recep_no_record_title': {
    AppLanguage.english: 'No Citizen Record Found',
    AppLanguage.bengali: 'কোনো নাগরিকের রেকর্ড পাওয়া যায়নি',
  },
  'hospital_recep_no_record_subtitle': {
    AppLanguage.english: 'Verify the Health ID or name, and ensure they have an approved appointment.',
    AppLanguage.bengali: 'হেলথ আইডি বা নাম যাচাই করুন এবং তাদের একটি অনুমোদিত অ্যাপয়েন্টমেন্ট আছে কিনা নিশ্চিত করুন।',
  },
  'hospital_recep_status_checked_in': {
    AppLanguage.english: 'Checked In',
    AppLanguage.bengali: 'চেক-ইন সম্পন্ন',
  },
  'hospital_recep_status_active_booking': {
    AppLanguage.english: 'Active Booking Verified',
    AppLanguage.bengali: 'সক্রিয় বুকিং যাচাইকৃত',
  },
  'hospital_recep_status_pending_approval': {
    AppLanguage.english: 'Pending Approval',
    AppLanguage.bengali: 'অনুমোদনের অপেক্ষায়',
  },
  'hospital_recep_health_id': {
    AppLanguage.english: 'Health ID:',
    AppLanguage.bengali: 'হেলথ আইডি:',
  },
  'hospital_recep_national_id': {
    AppLanguage.english: 'National ID',
    AppLanguage.bengali: 'জাতীয় পরিচয়পত্র',
  },
  'hospital_recep_age_gender': {
    AppLanguage.english: 'Age / Gender',
    AppLanguage.bengali: 'বয়স / লিঙ্গ',
  },
  'hospital_recep_years': {
    AppLanguage.english: 'years',
    AppLanguage.bengali: 'বছর',
  },
  'hospital_recep_blood_group': {
    AppLanguage.english: 'Blood Group',
    AppLanguage.bengali: 'রক্তের গ্রুপ',
  },
  'hospital_recep_scheduled_specialty': {
    AppLanguage.english: 'Scheduled Specialty',
    AppLanguage.bengali: 'নির্ধারিত বিশেষত্ব',
  },
  'hospital_recep_assigned_doctor': {
    AppLanguage.english: 'Assigned Doctor',
    AppLanguage.bengali: 'নিযুক্ত ডাক্তার',
  },
  'hospital_recep_time_slot': {
    AppLanguage.english: 'Time slot',
    AppLanguage.bengali: 'সময় স্লট',
  },
  'hospital_recep_already_checked_in': {
    AppLanguage.english: 'Already Checked In • Queue No:',
    AppLanguage.bengali: 'ইতিমধ্যে চেক-ইন সম্পন্ন • কিউ নম্বর:',
  },
  'hospital_recep_requires_approval': {
    AppLanguage.english: 'Requires Command Center Approval First',
    AppLanguage.bengali: 'প্রথমে কমান্ড সেন্টারের অনুমোদন প্রয়োজন',
  },
  'hospital_recep_confirm_checkin': {
    AppLanguage.english: 'Confirm Check-In & Issue Queue Ticket',
    AppLanguage.bengali: 'চেক-ইন নিশ্চিত করুন ও কিউ টিকিট দিন',
  },
  'hospital_recep_dashboard_title': {
    AppLanguage.english: 'Live Queue Dashboard',
    AppLanguage.bengali: 'লাইভ কিউ ড্যাশবোর্ড',
  },
  'hospital_recep_dashboard_subtitle': {
    AppLanguage.english: 'Track patient transit and consultation status across clinics.',
    AppLanguage.bengali: 'ক্লিনিকজুড়ে রোগীর চলাচল ও পরামর্শের অবস্থা পর্যবেক্ষণ করুন।',
  },
  'hospital_recep_reload': {
    AppLanguage.english: 'Reload',
    AppLanguage.bengali: 'পুনরায় লোড করুন',
  },
  'hospital_recep_reloaded': {
    AppLanguage.english: 'Reloaded.',
    AppLanguage.bengali: 'পুনরায় লোড করা হয়েছে।',
  },
  'hospital_recep_average_wait': {
    AppLanguage.english: 'Average Wait: 18m',
    AppLanguage.bengali: 'গড় অপেক্ষা: 18m',
  },
  'hospital_recep_dept_emergency': {
    AppLanguage.english: 'Emergency',
    AppLanguage.bengali: 'জরুরি বিভাগ',
  },
  'hospital_recep_dept_cardiology': {
    AppLanguage.english: 'Cardiology',
    AppLanguage.bengali: 'কার্ডিওলজি',
  },
  'hospital_recep_dept_icu': {
    AppLanguage.english: 'ICU',
    AppLanguage.bengali: 'ICU',
  },
  'hospital_recep_dept_general_ward': {
    AppLanguage.english: 'General Ward',
    AppLanguage.bengali: 'সাধারণ ওয়ার্ড',
  },
  'hospital_recep_dept_pediatrics': {
    AppLanguage.english: 'Pediatrics',
    AppLanguage.bengali: 'শিশু বিভাগ',
  },
  'hospital_recep_queue_empty_title': {
    AppLanguage.english: 'Queue is Empty',
    AppLanguage.bengali: 'কিউ খালি',
  },
  'hospital_recep_no_patients_prefix': {
    AppLanguage.english: 'No checked-in patients in the',
    AppLanguage.bengali: 'কোনো চেক-ইন করা রোগী নেই —',
  },
  'hospital_recep_no_patients_suffix': {
    AppLanguage.english: 'clinic.',
    AppLanguage.bengali: 'ক্লিনিকে।',
  },
  'hospital_recep_yrs': {
    AppLanguage.english: 'yrs',
    AppLanguage.bengali: 'বছর',
  },
  'hospital_recep_start_consultation': {
    AppLanguage.english: 'Start Consultation',
    AppLanguage.bengali: 'পরামর্শ শুরু করুন',
  },
  'hospital_recep_complete_session': {
    AppLanguage.english: 'Complete Session',
    AppLanguage.bengali: 'সেশন সম্পন্ন করুন',
  },

  // ===== appointment_approvals_page.dart (hospital_appr_) =====
  'hospital_appr_error_loading': {
    AppLanguage.english: 'Error loading pending appointments:',
    AppLanguage.bengali: 'অপেক্ষমাণ অ্যাপয়েন্টমেন্ট লোড করতে সমস্যা:',
  },
  'hospital_appr_all_caught_up': {
    AppLanguage.english: 'All caught up!',
    AppLanguage.bengali: 'সব কাজ শেষ!',
  },
  'hospital_appr_no_pending': {
    AppLanguage.english: 'No pending appointment requests need verification.',
    AppLanguage.bengali: 'যাচাইয়ের জন্য কোনো অপেক্ষমাণ অ্যাপয়েন্টমেন্ট অনুরোধ নেই।',
  },
  'hospital_appr_title': {
    AppLanguage.english: 'Appointment Verification Queue',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট যাচাই কিউ',
  },
  'hospital_appr_pending_count': {
    AppLanguage.english: 'pending',
    AppLanguage.bengali: 'অপেক্ষমাণ',
  },
  'hospital_appr_subtitle': {
    AppLanguage.english: 'Verify citizen details and doctor schedule compatibility before approving medical bookings.',
    AppLanguage.bengali: 'মেডিকেল বুকিং অনুমোদনের আগে নাগরিকের তথ্য ও ডাক্তারের সময়সূচির সামঞ্জস্য যাচাই করুন।',
  },
  'hospital_appr_health_id': {
    AppLanguage.english: 'Health ID:',
    AppLanguage.bengali: 'হেলথ আইডি:',
  },
  'hospital_appr_pending_badge': {
    AppLanguage.english: 'PENDING',
    AppLanguage.bengali: 'অপেক্ষমাণ',
  },
  'hospital_appr_appointment': {
    AppLanguage.english: 'Appointment',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট',
  },
  'hospital_appr_rejected': {
    AppLanguage.english: 'rejected.',
    AppLanguage.bengali: 'বাতিল করা হয়েছে।',
  },
  'hospital_appr_approved': {
    AppLanguage.english: 'approved!',
    AppLanguage.bengali: 'অনুমোদিত হয়েছে!',
  },
  'hospital_appr_reject': {
    AppLanguage.english: 'Reject',
    AppLanguage.bengali: 'বাতিল করুন',
  },
  'hospital_appr_verify_approve': {
    AppLanguage.english: 'Verify & Approve',
    AppLanguage.bengali: 'যাচাই ও অনুমোদন করুন',
  },

  // ===== laboratory_page.dart (hospital_lab_) =====
  'hospital_lab_requested_lab_reports': {
    AppLanguage.english: 'Requested Lab Reports',
    AppLanguage.bengali: 'অনুরোধকৃত ল্যাব রিপোর্ট',
  },
  'hospital_lab_pending': {
    AppLanguage.english: 'pending',
    AppLanguage.bengali: 'অপেক্ষমাণ',
  },
  'hospital_lab_reload_requests': {
    AppLanguage.english: 'Reload lab requests',
    AppLanguage.bengali: 'ল্যাব অনুরোধ পুনরায় লোড করুন',
  },
  'hospital_lab_header_subtitle': {
    AppLanguage.english: 'Requests sent in by doctors. Open a request to scan, review and confirm the report.',
    AppLanguage.bengali: 'ডাক্তারদের পাঠানো অনুরোধসমূহ। রিপোর্ট স্ক্যান, পর্যালোচনা ও নিশ্চিত করতে একটি অনুরোধ খুলুন।',
  },
  'hospital_lab_no_pending_requests': {
    AppLanguage.english: 'No pending lab requests',
    AppLanguage.bengali: 'কোনো অপেক্ষমাণ ল্যাব অনুরোধ নেই',
  },
  'hospital_lab_empty_hint': {
    AppLanguage.english: 'New requests from doctors will appear here.',
    AppLanguage.bengali: 'ডাক্তারদের নতুন অনুরোধ এখানে প্রদর্শিত হবে।',
  },
  'hospital_lab_requested_by': {
    AppLanguage.english: 'Requested by',
    AppLanguage.bengali: 'অনুরোধকারী',
  },
  'hospital_lab_submitted': {
    AppLanguage.english: 'Submitted',
    AppLanguage.bengali: 'জমা দেওয়া হয়েছে',
  },
  'hospital_lab_scanning': {
    AppLanguage.english: 'Scanning the Lab report.....',
    AppLanguage.bengali: 'ল্যাব রিপোর্ট স্ক্যান করা হচ্ছে.....',
  },
  'hospital_lab_scanning_completed': {
    AppLanguage.english: 'Scanning completed',
    AppLanguage.bengali: 'স্ক্যানিং সম্পন্ন হয়েছে',
  },
  'hospital_lab_submit_report': {
    AppLanguage.english: 'Submit Report',
    AppLanguage.bengali: 'রিপোর্ট জমা দিন',
  },
  'hospital_lab_ai_interpretation': {
    AppLanguage.english: 'Automated analysis of the scanned report values is within the expected clinical range. Please verify against the patient history before confirming.',
    AppLanguage.bengali: 'স্ক্যানকৃত রিপোর্টের মানসমূহের স্বয়ংক্রিয় বিশ্লেষণ প্রত্যাশিত ক্লিনিক্যাল সীমার মধ্যে রয়েছে। নিশ্চিত করার আগে অনুগ্রহ করে রোগীর ইতিহাসের সাথে যাচাই করুন।',
  },
  'hospital_lab_report_word': {
    AppLanguage.english: 'Report',
    AppLanguage.bengali: 'রিপোর্ট',
  },
  'hospital_lab_snackbar_published_mid': {
    AppLanguage.english: 'published — now in',
    AppLanguage.bengali: 'প্রকাশিত হয়েছে — এখন',
  },
  'hospital_lab_snackbar_vault_and': {
    AppLanguage.english: '\'s Medical Vault and Dr.',
    AppLanguage.bengali: '-এর মেডিকেল ভল্ট এবং ডাঃ',
  },
  'hospital_lab_snackbar_queue_end': {
    AppLanguage.english: '\'s review queue.',
    AppLanguage.bengali: '-এর রিভিউ কিউতে যুক্ত হয়েছে।',
  },
  'hospital_lab_publish_failed': {
    AppLanguage.english: 'Failed to publish report',
    AppLanguage.bengali: 'রিপোর্ট প্রকাশ করা যায়নি',
  },

  // ===== staff_management_page.dart (hospital_staff_) =====
  'hospital_staff_title': {
    AppLanguage.english: 'Staff & Workforce Management',
    AppLanguage.bengali: 'কর্মী ও জনবল ব্যবস্থাপনা',
  },
  'hospital_staff_subtitle': {
    AppLanguage.english: 'Manage clinical rosters, staff directory list, and verify doctor affiliations.',
    AppLanguage.bengali: 'ক্লিনিক্যাল রোস্টার, কর্মী তালিকা পরিচালনা করুন এবং চিকিৎসকের অন্তর্ভুক্তি যাচাই করুন।',
  },
  'hospital_staff_reload': {
    AppLanguage.english: 'Reload',
    AppLanguage.bengali: 'পুনরায় লোড করুন',
  },
  'hospital_staff_reloaded': {
    AppLanguage.english: 'Reloaded.',
    AppLanguage.bengali: 'পুনরায় লোড করা হয়েছে।',
  },
  'hospital_staff_add_member': {
    AppLanguage.english: 'Add Staff Member',
    AppLanguage.bengali: 'কর্মী যোগ করুন',
  },
  'hospital_staff_tab_directory': {
    AppLanguage.english: 'Staff Directory',
    AppLanguage.bengali: 'কর্মী তালিকা',
  },
  'hospital_staff_tab_roster': {
    AppLanguage.english: 'Duty Roster Planner',
    AppLanguage.bengali: 'ডিউটি রোস্টার পরিকল্পনা',
  },
  'hospital_staff_tab_verification': {
    AppLanguage.english: 'Verification Queue',
    AppLanguage.bengali: 'যাচাইকরণ সারি',
  },
  'hospital_staff_search_hint': {
    AppLanguage.english: 'Search staff by name or department...',
    AppLanguage.bengali: 'নাম বা বিভাগ দিয়ে কর্মী খুঁজুন...',
  },
  'hospital_staff_role_all': {
    AppLanguage.english: 'All',
    AppLanguage.bengali: 'সকল',
  },
  'hospital_staff_role_doctor': {
    AppLanguage.english: 'Doctor',
    AppLanguage.bengali: 'চিকিৎসক',
  },
  'hospital_staff_role_nurse': {
    AppLanguage.english: 'Nurse',
    AppLanguage.bengali: 'নার্স',
  },
  'hospital_staff_role_technician': {
    AppLanguage.english: 'Technician',
    AppLanguage.bengali: 'টেকনিশিয়ান',
  },
  'hospital_staff_role_pharmacist': {
    AppLanguage.english: 'Pharmacist',
    AppLanguage.bengali: 'ফার্মাসিস্ট',
  },
  'hospital_staff_no_match': {
    AppLanguage.english: 'No staff matches filter criteria',
    AppLanguage.bengali: 'ফিল্টার শর্তের সাথে কোনো কর্মী মেলেনি',
  },
  'hospital_staff_col_name': {
    AppLanguage.english: 'Name',
    AppLanguage.bengali: 'নাম',
  },
  'hospital_staff_col_role': {
    AppLanguage.english: 'Role',
    AppLanguage.bengali: 'পদবি',
  },
  'hospital_staff_col_department': {
    AppLanguage.english: 'Department',
    AppLanguage.bengali: 'বিভাগ',
  },
  'hospital_staff_col_shift_mon': {
    AppLanguage.english: 'Shift (Mon)',
    AppLanguage.bengali: 'শিফট (সোম)',
  },
  'hospital_staff_col_status': {
    AppLanguage.english: 'Status',
    AppLanguage.bengali: 'অবস্থা',
  },
  'hospital_staff_status_active': {
    AppLanguage.english: 'Active',
    AppLanguage.bengali: 'সক্রিয়',
  },
  'hospital_staff_col_staff_member': {
    AppLanguage.english: 'Staff Member',
    AppLanguage.bengali: 'কর্মী',
  },
  'hospital_staff_day_saturday': {
    AppLanguage.english: 'Saturday',
    AppLanguage.bengali: 'শনিবার',
  },
  'hospital_staff_day_sunday': {
    AppLanguage.english: 'Sunday',
    AppLanguage.bengali: 'রবিবার',
  },
  'hospital_staff_day_monday': {
    AppLanguage.english: 'Monday',
    AppLanguage.bengali: 'সোমবার',
  },
  'hospital_staff_day_tuesday': {
    AppLanguage.english: 'Tuesday',
    AppLanguage.bengali: 'মঙ্গলবার',
  },
  'hospital_staff_day_wednesday': {
    AppLanguage.english: 'Wednesday',
    AppLanguage.bengali: 'বুধবার',
  },
  'hospital_staff_day_thursday': {
    AppLanguage.english: 'Thursday',
    AppLanguage.bengali: 'বৃহস্পতিবার',
  },
  'hospital_staff_day_friday': {
    AppLanguage.english: 'Friday',
    AppLanguage.bengali: 'শুক্রবার',
  },
  'hospital_staff_shift_off': {
    AppLanguage.english: 'Off',
    AppLanguage.bengali: 'ছুটি',
  },
  'hospital_staff_shift_opd': {
    AppLanguage.english: 'OPD',
    AppLanguage.bengali: 'OPD',
  },
  'hospital_staff_shift_ward': {
    AppLanguage.english: 'Ward',
    AppLanguage.bengali: 'ওয়ার্ড',
  },
  'hospital_staff_shift_emergency': {
    AppLanguage.english: 'Emergency',
    AppLanguage.bengali: 'জরুরি',
  },
  'hospital_staff_shift_night': {
    AppLanguage.english: 'Night',
    AppLanguage.bengali: 'রাত',
  },
  'hospital_staff_shift_morning': {
    AppLanguage.english: 'Morning',
    AppLanguage.bengali: 'সকাল',
  },
  'hospital_staff_shift_evening': {
    AppLanguage.english: 'Evening',
    AppLanguage.bengali: 'সন্ধ্যা',
  },
  'hospital_staff_edit_duty_shift_for': {
    AppLanguage.english: 'Edit Duty Shift for',
    AppLanguage.bengali: 'ডিউটি শিফট সম্পাদনা করুন —',
  },
  'hospital_staff_day': {
    AppLanguage.english: 'Day',
    AppLanguage.bengali: 'দিন',
  },
  'hospital_staff_shift_designation': {
    AppLanguage.english: 'Shift Designation',
    AppLanguage.bengali: 'শিফট নির্ধারণ',
  },
  'hospital_staff_cancel': {
    AppLanguage.english: 'Cancel',
    AppLanguage.bengali: 'বাতিল',
  },
  'hospital_staff_save_shift': {
    AppLanguage.english: 'Save Shift',
    AppLanguage.bengali: 'শিফট সংরক্ষণ করুন',
  },
  'hospital_staff_updated_shift_for': {
    AppLanguage.english: 'Updated shift for',
    AppLanguage.bengali: 'শিফট হালনাগাদ করা হয়েছে —',
  },
  'hospital_staff_on': {
    AppLanguage.english: 'on',
    AppLanguage.bengali: ',',
  },
  'hospital_staff_to': {
    AppLanguage.english: 'to',
    AppLanguage.bengali: '→',
  },
  'hospital_staff_added_prefix': {
    AppLanguage.english: 'Added',
    AppLanguage.bengali: 'যোগ করা হয়েছে —',
  },
  'hospital_staff_added_suffix': {
    AppLanguage.english: 'to Hospital Directory.',
    AppLanguage.bengali: '— হাসপাতাল তালিকায়।',
  },
  'hospital_staff_approved_prefix': {
    AppLanguage.english: 'Approved',
    AppLanguage.bengali: 'অনুমোদিত —',
  },
  'hospital_staff_approved_suffix': {
    AppLanguage.english: 'Added to Hospital Staff Directory.',
    AppLanguage.bengali: 'হাসপাতাল কর্মী তালিকায় যোগ করা হয়েছে।',
  },
  'hospital_staff_application_rejected': {
    AppLanguage.english: 'Application rejected.',
    AppLanguage.bengali: 'আবেদন প্রত্যাখ্যান করা হয়েছে।',
  },
  'hospital_staff_all_reviewed': {
    AppLanguage.english: 'All Applications Reviewed',
    AppLanguage.bengali: 'সকল আবেদন পর্যালোচনা করা হয়েছে',
  },
  'hospital_staff_no_pending': {
    AppLanguage.english: 'No pending doctor affiliations at this time.',
    AppLanguage.bengali: 'এই মুহূর্তে কোনো অমীমাংসিত চিকিৎসক অন্তর্ভুক্তি নেই।',
  },
  'hospital_staff_bmdc_registration': {
    AppLanguage.english: 'BMDC Registration',
    AppLanguage.bengali: 'BMDC নিবন্ধন',
  },
  'hospital_staff_specialization': {
    AppLanguage.english: 'Specialization',
    AppLanguage.bengali: 'বিশেষত্ব',
  },
  'hospital_staff_submitted_date': {
    AppLanguage.english: 'Submitted Date',
    AppLanguage.bengali: 'জমাদানের তারিখ',
  },
  'hospital_staff_view_credentials': {
    AppLanguage.english: 'View Credentials',
    AppLanguage.bengali: 'সনদপত্র দেখুন',
  },
  'hospital_staff_reject': {
    AppLanguage.english: 'Reject',
    AppLanguage.bengali: 'প্রত্যাখ্যান',
  },
  'hospital_staff_approve_affiliation': {
    AppLanguage.english: 'Approve Affiliation',
    AppLanguage.bengali: 'অন্তর্ভুক্তি অনুমোদন করুন',
  },
  'hospital_staff_credentials_summary': {
    AppLanguage.english: 'Credentials Summary',
    AppLanguage.bengali: 'সনদপত্রের সারসংক্ষেপ',
  },
  'hospital_staff_cred_license_title': {
    AppLanguage.english: 'Medical Board License',
    AppLanguage.bengali: 'মেডিকেল বোর্ড লাইসেন্স',
  },
  'hospital_staff_cred_license_desc': {
    AppLanguage.english: 'BMDC Verification Status: VALIDATED (National Database Link)',
    AppLanguage.bengali: 'BMDC যাচাই অবস্থা: বৈধ (জাতীয় ডাটাবেস লিঙ্ক)',
  },
  'hospital_staff_cred_degree_title': {
    AppLanguage.english: 'Degree Certificate',
    AppLanguage.bengali: 'ডিগ্রি সনদপত্র',
  },
  'hospital_staff_cred_degree_desc': {
    AppLanguage.english: 'MBBS, MD - Dhaka Medical College (Verified)',
    AppLanguage.bengali: 'MBBS, MD - ঢাকা মেডিকেল কলেজ (যাচাইকৃত)',
  },
  'hospital_staff_cred_nid_title': {
    AppLanguage.english: 'NID Match',
    AppLanguage.bengali: 'NID মিল',
  },
  'hospital_staff_cred_nid_desc': {
    AppLanguage.english: 'Verified with Bangladesh Election Commission databases',
    AppLanguage.bengali: 'বাংলাদেশ নির্বাচন কমিশনের ডাটাবেসের সাথে যাচাইকৃত',
  },
  'hospital_staff_cred_specialist_title': {
    AppLanguage.english: 'Specialist Qualification',
    AppLanguage.bengali: 'বিশেষজ্ঞ যোগ্যতা',
  },
  'hospital_staff_cred_specialist_desc': {
    AppLanguage.english: 'Fellowship of College of Physicians and Surgeons (FCPS)',
    AppLanguage.bengali: 'ফেলোশিপ অব কলেজ অব ফিজিশিয়ানস অ্যান্ড সার্জনস (FCPS)',
  },
  'hospital_staff_close': {
    AppLanguage.english: 'Close',
    AppLanguage.bengali: 'বন্ধ করুন',
  },
  'hospital_staff_add_new_member': {
    AppLanguage.english: 'Add New Staff Member',
    AppLanguage.bengali: 'নতুন কর্মী যোগ করুন',
  },
  'hospital_staff_full_name': {
    AppLanguage.english: 'Full Name',
    AppLanguage.bengali: 'পূর্ণ নাম',
  },
  'hospital_staff_full_name_hint': {
    AppLanguage.english: 'e.g., Dr. Amina Islam',
    AppLanguage.bengali: 'যেমন, ডা. আমিনা ইসলাম',
  },
  'hospital_staff_field_role': {
    AppLanguage.english: 'Role',
    AppLanguage.bengali: 'পদবি',
  },
  'hospital_staff_field_department': {
    AppLanguage.english: 'Department',
    AppLanguage.bengali: 'বিভাগ',
  },
  'hospital_staff_field_shift': {
    AppLanguage.english: 'Shift',
    AppLanguage.bengali: 'শিফট',
  },
  'hospital_staff_dept_cardiology': {
    AppLanguage.english: 'Cardiology',
    AppLanguage.bengali: 'কার্ডিওলজি',
  },
  'hospital_staff_dept_emergency': {
    AppLanguage.english: 'Emergency',
    AppLanguage.bengali: 'জরুরি বিভাগ',
  },
  'hospital_staff_dept_pediatrics': {
    AppLanguage.english: 'Pediatrics',
    AppLanguage.bengali: 'শিশু বিভাগ',
  },
  'hospital_staff_dept_laboratory': {
    AppLanguage.english: 'Laboratory',
    AppLanguage.bengali: 'ল্যাবরেটরি',
  },
  'hospital_staff_dept_pharmacy': {
    AppLanguage.english: 'Pharmacy',
    AppLanguage.bengali: 'ফার্মেসি',
  },
  'hospital_staff_dept_general_ward': {
    AppLanguage.english: 'General Ward',
    AppLanguage.bengali: 'সাধারণ ওয়ার্ড',
  },
  'hospital_staff_add_staff': {
    AppLanguage.english: 'Add Staff',
    AppLanguage.bengali: 'কর্মী যোগ করুন',
  },

  // ===== pharmacy_page.dart (hospital_pharm_) =====
  'hospital_pharm_dispensing_counter': {
    AppLanguage.english: 'Dispensing Counter',
    AppLanguage.bengali: 'ঔষধ বিতরণ কাউন্টার',
  },
  'hospital_pharm_reload': {
    AppLanguage.english: 'Reload',
    AppLanguage.bengali: 'রিলোড',
  },
  'hospital_pharm_reloaded': {
    AppLanguage.english: 'Reloaded.',
    AppLanguage.bengali: 'রিলোড হয়েছে।',
  },
  'hospital_pharm_dispensing_subtitle': {
    AppLanguage.english: 'Validate and dispense medications against electronic doctor prescriptions.',
    AppLanguage.bengali: 'ইলেকট্রনিক ডাক্তারি প্রেসক্রিপশন যাচাই করে ঔষধ বিতরণ করুন।',
  },
  'hospital_pharm_formulary_inventory': {
    AppLanguage.english: 'Formulary Inventory',
    AppLanguage.bengali: 'ফর্মুলারি ইনভেন্টরি',
  },
  'hospital_pharm_search_formulary_hint': {
    AppLanguage.english: 'Search medicine formulary list...',
    AppLanguage.bengali: 'ঔষধের ফর্মুলারি তালিকা খুঁজুন...',
  },
  'hospital_pharm_no_matches': {
    AppLanguage.english: 'No formulary matches found.',
    AppLanguage.bengali: 'কোনো ফর্মুলারি মিল পাওয়া যায়নি।',
  },
  'hospital_pharm_stock': {
    AppLanguage.english: 'Stock',
    AppLanguage.bengali: 'মজুদ',
  },
  'hospital_pharm_min': {
    AppLanguage.english: 'Min',
    AppLanguage.bengali: 'সর্বনিম্ন',
  },
  'hospital_pharm_lookup_eprescription': {
    AppLanguage.english: 'Lookup E-Prescription ID',
    AppLanguage.bengali: 'ই-প্রেসক্রিপশন আইডি খুঁজুন',
  },
  'hospital_pharm_prescription_code': {
    AppLanguage.english: 'Prescription Code',
    AppLanguage.bengali: 'প্রেসক্রিপশন কোড',
  },
  'hospital_pharm_retrieve_rx': {
    AppLanguage.english: 'Retrieve RX',
    AppLanguage.bengali: 'RX আনুন',
  },
  'hospital_pharm_try_searching': {
    AppLanguage.english: 'Try searching "RX-9921" (Rahim Islam) or "RX-1024" (Jahanara Begum)',
    AppLanguage.bengali: '"RX-9921" (রহিম ইসলাম) অথবা "RX-1024" (জাহানারা বেগম) খুঁজে দেখুন',
  },
  'hospital_pharm_record_not_found': {
    AppLanguage.english: 'Prescription Record Not Found',
    AppLanguage.bengali: 'প্রেসক্রিপশন রেকর্ড পাওয়া যায়নি',
  },
  'hospital_pharm_verify_rx': {
    AppLanguage.english: 'Verify the RX number and search again.',
    AppLanguage.bengali: 'RX নম্বরটি যাচাই করে আবার খুঁজুন।',
  },
  'hospital_pharm_valid_esigned': {
    AppLanguage.english: 'Valid Prescription E-Signed',
    AppLanguage.bengali: 'বৈধ প্রেসক্রিপশন ই-স্বাক্ষরিত',
  },
  'hospital_pharm_patient': {
    AppLanguage.english: 'Patient',
    AppLanguage.bengali: 'রোগী',
  },
  'hospital_pharm_code': {
    AppLanguage.english: 'Code',
    AppLanguage.bengali: 'কোড',
  },
  'hospital_pharm_prescribed_by': {
    AppLanguage.english: 'Prescribed by',
    AppLanguage.bengali: 'প্রেসক্রাইব করেছেন',
  },
  'hospital_pharm_on': {
    AppLanguage.english: 'on',
    AppLanguage.bengali: 'তারিখে',
  },
  'hospital_pharm_qty': {
    AppLanguage.english: 'Qty',
    AppLanguage.bengali: 'পরিমাণ',
  },
  'hospital_pharm_dispense_medications': {
    AppLanguage.english: 'Dispense Medications',
    AppLanguage.bengali: 'ঔষধ বিতরণ করুন',
  },
  'hospital_pharm_stock_warnings': {
    AppLanguage.english: 'Inventory Stock Warnings',
    AppLanguage.bengali: 'ইনভেন্টরি মজুদ সতর্কতা',
  },
  'hospital_pharm_levels_normal': {
    AppLanguage.english: 'All medication inventory levels are normal.',
    AppLanguage.bengali: 'সকল ঔষধের মজুদ স্বাভাবিক পর্যায়ে রয়েছে।',
  },
  'hospital_pharm_dispense_success': {
    AppLanguage.english: 'Prescription successfully dispensed. Inventory quantities updated!',
    AppLanguage.bengali: 'প্রেসক্রিপশন সফলভাবে বিতরণ করা হয়েছে। ইনভেন্টরির পরিমাণ হালনাগাদ হয়েছে!',
  },
  'hospital_pharm_stock_out_warning': {
    AppLanguage.english: 'Stock Out Warning',
    AppLanguage.bengali: 'মজুদ শেষ হওয়ার সতর্কতা',
  },
  'hospital_pharm_insufficient_stock': {
    AppLanguage.english: 'Insufficient stock or items not found in the hospital inventory formulary.',
    AppLanguage.bengali: 'পর্যাপ্ত মজুদ নেই অথবা হাসপাতালের ইনভেন্টরি ফর্মুলারিতে আইটেম পাওয়া যায়নি।',
  },
  'hospital_pharm_dismiss': {
    AppLanguage.english: 'Dismiss',
    AppLanguage.bengali: 'বাতিল করুন',
  },

  // ===== bed_management_page.dart (hospital_bed_) =====
  'hospital_bed_patient': {
    AppLanguage.english: 'Patient',
    AppLanguage.bengali: 'রোগী',
  },
  'hospital_bed_admitted_success': {
    AppLanguage.english: 'admitted successfully.',
    AppLanguage.bengali: 'সফলভাবে ভর্তি হয়েছেন।',
  },
  'hospital_bed_discharge_patient': {
    AppLanguage.english: 'Discharge Patient',
    AppLanguage.bengali: 'রোগীকে ছাড়পত্র দিন',
  },
  'hospital_bed_final_diagnosis': {
    AppLanguage.english: 'Final Diagnosis',
    AppLanguage.bengali: 'চূড়ান্ত রোগ নির্ণয়',
  },
  'hospital_bed_discharge_summary': {
    AppLanguage.english: 'Discharge Summary Notes',
    AppLanguage.bengali: 'ছাড়পত্রের সারসংক্ষেপ নোট',
  },
  'hospital_bed_discharge_summary_hint': {
    AppLanguage.english: 'Patient is stable. Prescribed meds...',
    AppLanguage.bengali: 'রোগী স্থিতিশীল। নির্ধারিত ঔষধ...',
  },
  'hospital_bed_cancel': {
    AppLanguage.english: 'Cancel',
    AppLanguage.bengali: 'বাতিল',
  },
  'hospital_bed_patient_discharged': {
    AppLanguage.english: 'Patient discharged.',
    AppLanguage.bengali: 'রোগীকে ছাড়পত্র দেওয়া হয়েছে।',
  },
  'hospital_bed_now_available': {
    AppLanguage.english: 'is now available.',
    AppLanguage.bengali: 'এখন খালি রয়েছে।',
  },
  'hospital_bed_confirm_discharge': {
    AppLanguage.english: 'Confirm Discharge',
    AppLanguage.bengali: 'ছাড়পত্র নিশ্চিত করুন',
  },
  'hospital_bed_admit_to': {
    AppLanguage.english: 'Admit to',
    AppLanguage.bengali: 'ভর্তি করুন',
  },
  'hospital_bed_digital_health_id': {
    AppLanguage.english: 'Digital Health ID',
    AppLanguage.bengali: 'ডিজিটাল স্বাস্থ্য আইডি',
  },
  'hospital_bed_patient_name': {
    AppLanguage.english: 'Patient Name',
    AppLanguage.bengali: 'রোগীর নাম',
  },
  'hospital_bed_attending_physician': {
    AppLanguage.english: 'Attending Physician',
    AppLanguage.bengali: 'দায়িত্বপ্রাপ্ত চিকিৎসক',
  },
  'hospital_bed_admit_patient': {
    AppLanguage.english: 'Admit Patient',
    AppLanguage.bengali: 'রোগী ভর্তি করুন',
  },
  'hospital_bed_capacity_management': {
    AppLanguage.english: 'Bed Capacity Management',
    AppLanguage.bengali: 'শয্যা ধারণক্ষমতা ব্যবস্থাপনা',
  },
  'hospital_bed_reload': {
    AppLanguage.english: 'Reload',
    AppLanguage.bengali: 'রিলোড',
  },
  'hospital_bed_reloaded': {
    AppLanguage.english: 'Reloaded.',
    AppLanguage.bengali: 'রিলোড হয়েছে।',
  },
  'hospital_bed_subtitle': {
    AppLanguage.english: 'Click on any bed slot to admit a patient or manage occupancy.',
    AppLanguage.bengali: 'রোগী ভর্তি করতে বা দখল পরিচালনা করতে যেকোনো শয্যা স্লটে ক্লিক করুন।',
  },
  'hospital_bed_active_admissions': {
    AppLanguage.english: 'Active Admissions',
    AppLanguage.bengali: 'সক্রিয় ভর্তি',
  },
  'hospital_bed_no_patients': {
    AppLanguage.english: 'No patients currently admitted.',
    AppLanguage.bengali: 'বর্তমানে কোনো রোগী ভর্তি নেই।',
  },
  'hospital_bed_ward_general_male': {
    AppLanguage.english: 'General Ward (Male)',
    AppLanguage.bengali: 'সাধারণ ওয়ার্ড (পুরুষ)',
  },
  'hospital_bed_ward_general_female': {
    AppLanguage.english: 'General Ward (Female)',
    AppLanguage.bengali: 'সাধারণ ওয়ার্ড (মহিলা)',
  },
  'hospital_bed_ward_icu': {
    AppLanguage.english: 'ICU',
    AppLanguage.bengali: 'ICU',
  },
  'hospital_bed_status_occupied': {
    AppLanguage.english: 'Occupied',
    AppLanguage.bengali: 'দখলকৃত',
  },
  'hospital_bed_status_maintenance': {
    AppLanguage.english: 'Maintenance',
    AppLanguage.bengali: 'রক্ষণাবেক্ষণ',
  },
  'hospital_bed_status_available': {
    AppLanguage.english: 'Available',
    AppLanguage.bengali: 'খালি',
  },
  'hospital_bed_maintenance_snack': {
    AppLanguage.english: 'Bed is currently undergoing sanitary maintenance.',
    AppLanguage.bengali: 'শয্যাটি বর্তমানে স্যানিটারি রক্ষণাবেক্ষণাধীন রয়েছে।',
  },
  'hospital_bed_days_admitted': {
    AppLanguage.english: 'days admitted',
    AppLanguage.bengali: 'দিন ভর্তি আছেন',
  },
  'hospital_bed_unknown_patient': {
    AppLanguage.english: 'Unknown Patient',
    AppLanguage.bengali: 'অজ্ঞাত রোগী',
  },
  'hospital_bed_health_id': {
    AppLanguage.english: 'Health ID',
    AppLanguage.bengali: 'স্বাস্থ্য আইডি',
  },
  'hospital_bed_na': {
    AppLanguage.english: 'N/A',
    AppLanguage.bengali: 'প্রযোজ্য নয়',
  },
  'hospital_bed_doctor': {
    AppLanguage.english: 'Doctor',
    AppLanguage.bengali: 'ডাক্তার',
  },
  'hospital_bed_unassigned': {
    AppLanguage.english: 'Unassigned',
    AppLanguage.bengali: 'নির্ধারিত নয়',
  },
  'hospital_bed_discharge_workflow': {
    AppLanguage.english: 'Discharge Workflow',
    AppLanguage.bengali: 'ছাড়পত্র প্রক্রিয়া',
  },
};
