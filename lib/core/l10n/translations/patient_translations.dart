import '../app_language.dart';

/// Patient portal page strings. Keys are prefixed with `patient_`.
/// (Populated by the patient-pages localization pass.)
const Map<String, Map<AppLanguage, String>> patientTranslations = {
  // --- Shared / common ------------------------------------------------------
  'patient_reload': {
    AppLanguage.english: 'Reload',
    AppLanguage.bengali: 'রিলোড',
  },
  'patient_reloaded': {
    AppLanguage.english: 'Reloaded.',
    AppLanguage.bengali: 'রিলোড হয়েছে।',
  },
  'patient_retry': {
    AppLanguage.english: 'Retry',
    AppLanguage.bengali: 'পুনরায় চেষ্টা করুন',
  },
  'patient_cancel': {
    AppLanguage.english: 'Cancel',
    AppLanguage.bengali: 'বাতিল',
  },
  'patient_back': {
    AppLanguage.english: 'Back',
    AppLanguage.bengali: 'পূর্ববর্তী',
  },
  'patient_next': {
    AppLanguage.english: 'Next',
    AppLanguage.bengali: 'পরবর্তী',
  },
  'patient_close': {
    AppLanguage.english: 'Close',
    AppLanguage.bengali: 'বন্ধ করুন',
  },
  'patient_view_details': {
    AppLanguage.english: 'View details',
    AppLanguage.bengali: 'বিস্তারিত দেখুন',
  },
  'patient_book_slot': {
    AppLanguage.english: 'Book Slot',
    AppLanguage.bengali: 'স্লট বুক করুন',
  },
  'patient_none': {
    AppLanguage.english: 'None',
    AppLanguage.bengali: 'নেই',
  },
  'patient_health_vitals': {
    AppLanguage.english: 'Health Vitals',
    AppLanguage.bengali: 'স্বাস্থ্য ভাইটালস',
  },
  'patient_blood_pressure': {
    AppLanguage.english: 'Blood Pressure',
    AppLanguage.bengali: 'রক্তচাপ',
  },
  'patient_blood_glucose': {
    AppLanguage.english: 'Blood Glucose',
    AppLanguage.bengali: 'রক্তে গ্লুকোজ',
  },
  'patient_heart_rate': {
    AppLanguage.english: 'Heart Rate',
    AppLanguage.bengali: 'হৃদস্পন্দন',
  },
  'patient_weight': {
    AppLanguage.english: 'Weight',
    AppLanguage.bengali: 'ওজন',
  },
  'patient_blood_group': {
    AppLanguage.english: 'Blood Group',
    AppLanguage.bengali: 'রক্তের গ্রুপ',
  },
  'patient_full_name': {
    AppLanguage.english: 'Full Name',
    AppLanguage.bengali: 'পূর্ণ নাম',
  },
  'patient_phone_number': {
    AppLanguage.english: 'Phone Number',
    AppLanguage.bengali: 'ফোন নম্বর',
  },
  'patient_occupation': {
    AppLanguage.english: 'Occupation',
    AppLanguage.bengali: 'পেশা',
  },
  'patient_marital_status': {
    AppLanguage.english: 'Marital Status',
    AppLanguage.bengali: 'বৈবাহিক অবস্থা',
  },
  'patient_gender': {
    AppLanguage.english: 'Gender',
    AppLanguage.bengali: 'লিঙ্গ',
  },
  'patient_national_id': {
    AppLanguage.english: 'National ID (NID)',
    AppLanguage.bengali: 'জাতীয় পরিচয়পত্র (NID)',
  },
  'patient_present_address': {
    AppLanguage.english: 'Present Address',
    AppLanguage.bengali: 'বর্তমান ঠিকানা',
  },
  'patient_permanent_address': {
    AppLanguage.english: 'Permanent Address',
    AppLanguage.bengali: 'স্থায়ী ঠিকানা',
  },

  // --- Dashboard ------------------------------------------------------------
  'patient_err_loading_dashboard': {
    AppLanguage.english: 'Error loading dashboard',
    AppLanguage.bengali: 'ড্যাশবোর্ড লোড করতে সমস্যা হয়েছে',
  },
  'patient_search_placeholder': {
    AppLanguage.english: 'Search records, doctors, appointments...',
    AppLanguage.bengali: 'রেকর্ড, ডাক্তার, অ্যাপয়েন্টমেন্ট খুঁজুন...',
  },
  'patient_quick_services': {
    AppLanguage.english: 'Quick Services',
    AppLanguage.bengali: 'দ্রুত সেবা',
  },
  'patient_digital_health_card': {
    AppLanguage.english: 'NHCS Digital Health Card',
    AppLanguage.bengali: 'NHCS ডিজিটাল হেলথ কার্ড',
  },
  'patient_age': {
    AppLanguage.english: 'Age',
    AppLanguage.bengali: 'বয়স',
  },
  'patient_allergies': {
    AppLanguage.english: 'Allergies',
    AppLanguage.bengali: 'অ্যালার্জি',
  },
  'patient_chronic': {
    AppLanguage.english: 'Chronic',
    AppLanguage.bengali: 'দীর্ঘমেয়াদি',
  },
  'patient_ai_health_assessment': {
    AppLanguage.english: 'AI Health Assessment & Vitals Briefing',
    AppLanguage.bengali: 'এআই স্বাস্থ্য মূল্যায়ন ও ভাইটালস ব্রিফিং',
  },
  'patient_ai_rec_1': {
    AppLanguage.english: 'Vitals are stable, keep monitoring BP daily.',
    AppLanguage.bengali: 'ভাইটালস স্থিতিশীল, প্রতিদিন BP পর্যবেক্ষণ করুন।',
  },
  'patient_ai_rec_2': {
    AppLanguage.english:
        'Take prescribed Metformin 500mg as instructed by Dr. Ahmed Khan.',
    AppLanguage.bengali:
        'ডা. আহমেদ খানের নির্দেশ অনুযায়ী নির্ধারিত মেটফরমিন ৫০০ মি.গ্রা. গ্রহণ করুন।',
  },
  'patient_ai_rec_3': {
    AppLanguage.english: 'Avoid high sodium meals and keep well hydrated.',
    AppLanguage.bengali:
        'অতিরিক্ত সোডিয়ামযুক্ত খাবার এড়িয়ে চলুন এবং পর্যাপ্ত পানি পান করুন।',
  },
  'patient_action_book_appointment': {
    AppLanguage.english: 'Book Appointment',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট বুক করুন',
  },
  'patient_health_timeline': {
    AppLanguage.english: 'Health Timeline',
    AppLanguage.bengali: 'হেলথ টাইমলাইন',
  },
  'patient_medical_vault': {
    AppLanguage.english: 'Medical Vault',
    AppLanguage.bengali: 'মেডিকেল ভল্ট',
  },
  'patient_healthcare_ai': {
    AppLanguage.english: 'Healthcare AI',
    AppLanguage.bengali: 'এআই স্বাস্থ্যসেবা',
  },
  'patient_active_prescriptions': {
    AppLanguage.english: 'Active Prescriptions',
    AppLanguage.bengali: 'সক্রিয় প্রেসক্রিপশন',
  },
  'patient_err_loading_prescriptions': {
    AppLanguage.english: 'Error loading prescriptions',
    AppLanguage.bengali: 'প্রেসক্রিপশন লোড করতে সমস্যা হয়েছে',
  },
  'patient_no_active_prescriptions': {
    AppLanguage.english: 'No active prescriptions',
    AppLanguage.bengali: 'কোনো সক্রিয় প্রেসক্রিপশন নেই',
  },
  'patient_no_active_medications': {
    AppLanguage.english: 'No active medications',
    AppLanguage.bengali: 'কোনো সক্রিয় ওষুধ নেই',
  },
  'patient_upcoming_appointments': {
    AppLanguage.english: 'Upcoming Appointments',
    AppLanguage.bengali: 'আসন্ন অ্যাপয়েন্টমেন্ট',
  },
  'patient_err_loading_appointments': {
    AppLanguage.english: 'Error loading appointments',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট লোড করতে সমস্যা হয়েছে',
  },
  'patient_no_upcoming_appointments': {
    AppLanguage.english: 'No upcoming appointments',
    AppLanguage.bengali: 'কোনো আসন্ন অ্যাপয়েন্টমেন্ট নেই',
  },
  'patient_duration': {
    AppLanguage.english: 'Duration',
    AppLanguage.bengali: 'মেয়াদ',
  },
  'patient_recent_test_reports': {
    AppLanguage.english: 'Recent Test Reports',
    AppLanguage.bengali: 'সাম্প্রতিক পরীক্ষার রিপোর্ট',
  },
  'patient_err_loading_reports': {
    AppLanguage.english: 'Error loading reports',
    AppLanguage.bengali: 'রিপোর্ট লোড করতে সমস্যা হয়েছে',
  },
  'patient_no_test_reports': {
    AppLanguage.english: 'No test reports yet',
    AppLanguage.bengali: 'এখনো কোনো পরীক্ষার রিপোর্ট নেই',
  },
  'patient_blood_donation_portal': {
    AppLanguage.english: 'Blood Donation Portal',
    AppLanguage.bengali: 'রক্তদান পোর্টাল',
  },
  'patient_donor_registration': {
    AppLanguage.english: 'Donor Registration:',
    AppLanguage.bengali: 'দাতা নিবন্ধন:',
  },
  'patient_registered': {
    AppLanguage.english: 'Registered',
    AppLanguage.bengali: 'নিবন্ধিত',
  },
  'patient_inactive': {
    AppLanguage.english: 'Inactive',
    AppLanguage.bengali: 'নিষ্ক্রিয়',
  },
  'patient_matched_requests': {
    AppLanguage.english: 'Matched Requests:',
    AppLanguage.bengali: 'মিলে যাওয়া অনুরোধ:',
  },
  'patient_manage_portal': {
    AppLanguage.english: 'Manage Portal',
    AppLanguage.bengali: 'পোর্টাল পরিচালনা',
  },

  // --- Health Timeline ------------------------------------------------------
  'patient_filter_all': {
    AppLanguage.english: 'All',
    AppLanguage.bengali: 'সব',
  },
  'patient_filter_consultations': {
    AppLanguage.english: 'Consultations',
    AppLanguage.bengali: 'পরামর্শ',
  },
  'patient_filter_lab_tests': {
    AppLanguage.english: 'Lab Tests',
    AppLanguage.bengali: 'ল্যাব পরীক্ষা',
  },
  'patient_filter_imaging': {
    AppLanguage.english: 'Imaging',
    AppLanguage.bengali: 'ইমেজিং',
  },
  'patient_err_loading_timeline': {
    AppLanguage.english: 'Error loading timeline',
    AppLanguage.bengali: 'টাইমলাইন লোড করতে সমস্যা হয়েছে',
  },
  'patient_no_matching_events': {
    AppLanguage.english: 'No matching health events found.',
    AppLanguage.bengali: 'কোনো মিল থাকা স্বাস্থ্য ঘটনা পাওয়া যায়নি।',
  },

  // --- Appointments ---------------------------------------------------------
  'patient_appointments_portal': {
    AppLanguage.english: 'Appointments Portal',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট পোর্টাল',
  },
  'patient_book_new': {
    AppLanguage.english: 'Book New',
    AppLanguage.bengali: 'নতুন বুক করুন',
  },
  'patient_tab_upcoming': {
    AppLanguage.english: 'Upcoming',
    AppLanguage.bengali: 'আসন্ন',
  },
  'patient_tab_past': {
    AppLanguage.english: 'Past',
    AppLanguage.bengali: 'অতীত',
  },
  'patient_tab_cancelled': {
    AppLanguage.english: 'Cancelled',
    AppLanguage.bengali: 'বাতিলকৃত',
  },
  'patient_no_appointments_prefix': {
    AppLanguage.english: 'No',
    AppLanguage.bengali: 'কোনো',
  },
  'patient_no_appointments_suffix': {
    AppLanguage.english: 'appointments found.',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট পাওয়া যায়নি।',
  },
  'patient_find_specialist': {
    AppLanguage.english: 'Find a Medical Specialist',
    AppLanguage.bengali: 'একজন চিকিৎসা বিশেষজ্ঞ খুঁজুন',
  },
  'patient_pending_approval': {
    AppLanguage.english: 'Pending Approval',
    AppLanguage.bengali: 'অনুমোদনের অপেক্ষায়',
  },
  'patient_rejected': {
    AppLanguage.english: 'Rejected',
    AppLanguage.bengali: 'প্রত্যাখ্যাত',
  },
  'patient_checked_in': {
    AppLanguage.english: 'Checked In',
    AppLanguage.bengali: 'চেক-ইন হয়েছে',
  },
  'patient_completed': {
    AppLanguage.english: 'Completed',
    AppLanguage.bengali: 'সম্পন্ন',
  },
  'patient_approved': {
    AppLanguage.english: 'Approved',
    AppLanguage.bengali: 'অনুমোদিত',
  },
  'patient_cancel_appointment_menu': {
    AppLanguage.english: 'Cancel appointment',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট বাতিল করুন',
  },
  'patient_queue': {
    AppLanguage.english: 'Queue',
    AppLanguage.bengali: 'সারি',
  },
  'patient_search_doctor_placeholder': {
    AppLanguage.english: 'Search by doctor name or specialization...',
    AppLanguage.bengali: 'ডাক্তারের নাম বা বিশেষত্ব দিয়ে খুঁজুন...',
  },
  'patient_spec_all': {
    AppLanguage.english: 'All Specializations',
    AppLanguage.bengali: 'সকল বিশেষত্ব',
  },
  'patient_spec_cardiology': {
    AppLanguage.english: 'Cardiology',
    AppLanguage.bengali: 'কার্ডিওলজি',
  },
  'patient_spec_endocrinology': {
    AppLanguage.english: 'Endocrinology',
    AppLanguage.bengali: 'এন্ডোক্রাইনোলজি',
  },
  'patient_spec_general_medicine': {
    AppLanguage.english: 'General Medicine',
    AppLanguage.bengali: 'জেনারেল মেডিসিন',
  },
  'patient_spec_gynae': {
    AppLanguage.english: 'Gynaecology & Obstetrics',
    AppLanguage.bengali: 'গাইনোকোলজি ও অবস্টেট্রিক্স',
  },
  'patient_no_doctors_match': {
    AppLanguage.english: 'No doctors match your search filters.',
    AppLanguage.bengali: 'আপনার অনুসন্ধান ফিল্টারের সাথে কোনো ডাক্তার মিলছে না।',
  },
  'patient_years_exp': {
    AppLanguage.english: 'years exp.',
    AppLanguage.bengali: 'বছরের অভিজ্ঞতা',
  },
  'patient_yrs_exp_short': {
    AppLanguage.english: 'Yrs Exp',
    AppLanguage.bengali: 'বছরের অভিজ্ঞতা',
  },
  'patient_cancel_appointment_title': {
    AppLanguage.english: 'Cancel Appointment',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট বাতিল করুন',
  },
  'patient_cancel_appointment_confirm': {
    AppLanguage.english:
        'Are you sure you want to cancel this appointment? This action cannot be undone.',
    AppLanguage.bengali:
        'আপনি কি নিশ্চিত এই অ্যাপয়েন্টমেন্টটি বাতিল করতে চান? এই কাজটি আর ফেরানো যাবে না।',
  },
  'patient_no_keep': {
    AppLanguage.english: 'No, Keep',
    AppLanguage.bengali: 'না, রাখুন',
  },
  'patient_yes_cancel': {
    AppLanguage.english: 'Yes, Cancel',
    AppLanguage.bengali: 'হ্যাঁ, বাতিল করুন',
  },
  // AI smart booking assistant
  'patient_ai_smart_booking': {
    AppLanguage.english: 'AI Smart Booking',
    AppLanguage.bengali: 'এআই স্মার্ট বুকিং',
  },
  'patient_ai_booking_assistant': {
    AppLanguage.english: 'AI-Powered Appointment Assistant',
    AppLanguage.bengali: 'এআই-চালিত অ্যাপয়েন্টমেন্ট সহকারী',
  },
  'patient_ai_booking_desc': {
    AppLanguage.english:
        'Describe your medical symptoms in Bangla or English, or use voice input. The AI will analyze your condition, summarize your symptoms, recommend the proper specialist, and locate the nearest hospitals and doctors.',
    AppLanguage.bengali:
        'আপনার শারীরিক উপসর্গ বাংলা বা ইংরেজিতে লিখুন, অথবা ভয়েস ইনপুট ব্যবহার করুন। এআই আপনার অবস্থা বিশ্লেষণ করবে, উপসর্গ সংক্ষেপে তুলে ধরবে, উপযুক্ত বিশেষজ্ঞের পরামর্শ দেবে এবং নিকটতম হাসপাতাল ও ডাক্তার খুঁজে দেবে।',
  },
  'patient_ai_hint_listening': {
    AppLanguage.english:
        'I am listening, please speak... (e.g. I have a headache and nausea)',
    AppLanguage.bengali:
        'আমি শুনছি, বলুন... (উদা: আমার মাথা ব্যাথ ও বমি বমি ভাব)',
  },
  'patient_ai_hint_idle': {
    AppLanguage.english:
        'Write or speak your problem in detail (e.g. chest pain and breathing difficulty for a few days)...',
    AppLanguage.bengali:
        'আপনার সমস্যাটি বিস্তারিত লিখুন বা বলুন (উদা: কয়েক দিন ধরে বুকে ব্যথা ও শ্বাসকষ্ট)...',
  },
  'patient_stop_listening': {
    AppLanguage.english: 'Stop Listening',
    AppLanguage.bengali: 'শোনা বন্ধ করুন',
  },
  'patient_speak_in_bangla': {
    AppLanguage.english: 'Speak in Bangla',
    AppLanguage.bengali: 'বাংলায় বলুন',
  },
  'patient_clear': {
    AppLanguage.english: 'Clear',
    AppLanguage.bengali: 'মুছুন',
  },
  'patient_listening_status': {
    AppLanguage.english: 'Listening... Speak in Bangla (বাংলায় বলুন)',
    AppLanguage.bengali: 'শুনছি... বাংলায় বলুন',
  },
  'patient_ai_analyzing': {
    AppLanguage.english: 'AI Analyzing Symptoms...',
    AppLanguage.bengali: 'এআই উপসর্গ বিশ্লেষণ করছে...',
  },
  'patient_ai_analyze_btn': {
    AppLanguage.english: 'Analyze Symptoms with AI',
    AppLanguage.bengali: 'এআই দিয়ে উপসর্গ বিশ্লেষণ করুন',
  },
  'patient_ai_health_summary': {
    AppLanguage.english: 'AI Health Summary (স্বাস্থ্য সারসংক্ষেপ):',
    AppLanguage.bengali: 'এআই স্বাস্থ্য সারসংক্ষেপ:',
  },
  'patient_english_summary': {
    AppLanguage.english: 'English Summary:',
    AppLanguage.bengali: 'ইংরেজি সারসংক্ষেপ:',
  },
  'patient_bangla_summary': {
    AppLanguage.english: 'Bangla Summary:',
    AppLanguage.bengali: 'বাংলা সারসংক্ষেপ:',
  },
  'patient_recommended_specialization': {
    AppLanguage.english: 'Recommended Specialization:',
    AppLanguage.bengali: 'প্রস্তাবিত বিশেষত্ব:',
  },
  'patient_nearby_hospitals': {
    AppLanguage.english: 'Nearby Matching Hospitals:',
    AppLanguage.bengali: 'নিকটবর্তী উপযুক্ত হাসপাতাল:',
  },
  'patient_recommended_doctors': {
    AppLanguage.english: 'Recommended Doctors:',
    AppLanguage.bengali: 'প্রস্তাবিত ডাক্তার:',
  },
  'patient_no_matching_doctors_spec': {
    AppLanguage.english: 'No matching doctors found for this specialization.',
    AppLanguage.bengali: 'এই বিশেষত্বের জন্য কোনো ডাক্তার পাওয়া যায়নি।',
  },
  // Booking wizard dialog
  'patient_booking_confirmed': {
    AppLanguage.english: 'Booking Confirmed',
    AppLanguage.bengali: 'বুকিং নিশ্চিত হয়েছে',
  },
  'patient_book_appointment_title': {
    AppLanguage.english: 'Book Appointment',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট বুক করুন',
  },
  'patient_select_doctor_begin': {
    AppLanguage.english: 'Select a Doctor to begin:',
    AppLanguage.bengali: 'শুরু করতে একজন ডাক্তার নির্বাচন করুন:',
  },
  'patient_select_date': {
    AppLanguage.english: 'Select Date:',
    AppLanguage.bengali: 'তারিখ নির্বাচন করুন:',
  },
  'patient_select_time_slot': {
    AppLanguage.english: 'Select Time Slot:',
    AppLanguage.bengali: 'সময় নির্বাচন করুন:',
  },
  'patient_review_details': {
    AppLanguage.english:
        'Please review the details below before confirming the booking.',
    AppLanguage.bengali: 'বুকিং নিশ্চিত করার আগে অনুগ্রহ করে নিচের তথ্যগুলো যাচাই করুন।',
  },
  'patient_doctor': {
    AppLanguage.english: 'Doctor',
    AppLanguage.bengali: 'ডাক্তার',
  },
  'patient_specialization': {
    AppLanguage.english: 'Specialization',
    AppLanguage.bengali: 'বিশেষত্ব',
  },
  'patient_hospital': {
    AppLanguage.english: 'Hospital',
    AppLanguage.bengali: 'হাসপাতাল',
  },
  'patient_date': {
    AppLanguage.english: 'Date',
    AppLanguage.bengali: 'তারিখ',
  },
  'patient_time_slot': {
    AppLanguage.english: 'Time Slot',
    AppLanguage.bengali: 'সময়',
  },
  'patient_time': {
    AppLanguage.english: 'Time',
    AppLanguage.bengali: 'সময়',
  },
  'patient_consultation_fee': {
    AppLanguage.english: 'Consultation Fee',
    AppLanguage.bengali: 'পরামর্শ ফি',
  },
  'patient_appointment_placed': {
    AppLanguage.english: 'Appointment Placed!',
    AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট নেওয়া হয়েছে!',
  },
  'patient_appointment_booked_with_prefix': {
    AppLanguage.english: 'Your appointment with',
    AppLanguage.bengali: 'আপনার অ্যাপয়েন্টমেন্ট',
  },
  'patient_appointment_booked_with_suffix': {
    AppLanguage.english: 'has been booked.',
    AppLanguage.bengali: 'এর সাথে বুক করা হয়েছে।',
  },
  'patient_back_to_dashboard': {
    AppLanguage.english: 'Back to Dashboard',
    AppLanguage.bengali: 'ড্যাশবোর্ডে ফিরে যান',
  },
  'patient_confirm_booking': {
    AppLanguage.english: 'Confirm Booking',
    AppLanguage.bengali: 'বুকিং নিশ্চিত করুন',
  },

  // --- Medical Vault --------------------------------------------------------
  'patient_vault_subtitle': {
    AppLanguage.english: 'All your medical records in one secure place',
    AppLanguage.bengali: 'আপনার সকল চিকিৎসা রেকর্ড এক নিরাপদ জায়গায়',
  },
  'patient_tab_prescriptions': {
    AppLanguage.english: 'Prescriptions',
    AppLanguage.bengali: 'প্রেসক্রিপশন',
  },
  'patient_tab_lab_reports': {
    AppLanguage.english: 'Lab Reports',
    AppLanguage.bengali: 'ল্যাব রিপোর্ট',
  },
  'patient_tab_imaging': {
    AppLanguage.english: 'Imaging',
    AppLanguage.bengali: 'ইমেজিং',
  },
  'patient_no_prescriptions_found': {
    AppLanguage.english: 'No prescriptions found.',
    AppLanguage.bengali: 'কোনো প্রেসক্রিপশন পাওয়া যায়নি।',
  },
  'patient_follow_up': {
    AppLanguage.english: 'Follow-up',
    AppLanguage.bengali: 'ফলো-আপ',
  },
  'patient_no_follow_up': {
    AppLanguage.english: 'No follow-up scheduled',
    AppLanguage.bengali: 'কোনো ফলো-আপ নির্ধারিত নেই',
  },
  'patient_err_loading_lab_reports': {
    AppLanguage.english: 'Error loading lab reports',
    AppLanguage.bengali: 'ল্যাব রিপোর্ট লোড করতে সমস্যা হয়েছে',
  },
  'patient_no_lab_reports_found': {
    AppLanguage.english: 'No lab reports found.',
    AppLanguage.bengali: 'কোনো ল্যাব রিপোর্ট পাওয়া যায়নি।',
  },
  'patient_category': {
    AppLanguage.english: 'Category',
    AppLanguage.bengali: 'বিভাগ',
  },
  'patient_err_loading_imaging': {
    AppLanguage.english: 'Error loading imaging reports',
    AppLanguage.bengali: 'ইমেজিং রিপোর্ট লোড করতে সমস্যা হয়েছে',
  },
  'patient_no_imaging_found': {
    AppLanguage.english: 'No imaging reports found.',
    AppLanguage.bengali: 'কোনো ইমেজিং রিপোর্ট পাওয়া যায়নি।',
  },
  'patient_reported': {
    AppLanguage.english: 'Reported',
    AppLanguage.bengali: 'রিপোর্ট করা হয়েছে',
  },
  'patient_scan_placeholder': {
    AppLanguage.english: 'Scan Image Placeholder',
    AppLanguage.bengali: 'স্ক্যান চিত্রের স্থানধারক',
  },
  'patient_secure_mock': {
    AppLanguage.english: '(SECURE MOCK)',
    AppLanguage.bengali: '(নিরাপদ নমুনা)',
  },
  'patient_imaging_findings': {
    AppLanguage.english: 'Imaging Findings',
    AppLanguage.bengali: 'ইমেজিং ফলাফল',
  },
  'patient_exam_details': {
    AppLanguage.english: 'Exam Details:',
    AppLanguage.bengali: 'পরীক্ষার বিবরণ:',
  },
  'patient_body_part': {
    AppLanguage.english: 'Body Part',
    AppLanguage.bengali: 'শরীরের অংশ',
  },
  'patient_facility': {
    AppLanguage.english: 'Facility',
    AppLanguage.bengali: 'কেন্দ্র',
  },
  'patient_referrer': {
    AppLanguage.english: 'Referrer',
    AppLanguage.bengali: 'রেফারকারী',
  },
  'patient_findings': {
    AppLanguage.english: 'Findings:',
    AppLanguage.bengali: 'ফলাফল:',
  },
  'patient_impression': {
    AppLanguage.english: 'Impression:',
    AppLanguage.bengali: 'পর্যবেক্ষণ:',
  },

  // --- Patient Profile ------------------------------------------------------
  'patient_profile_updated': {
    AppLanguage.english: 'Profile updated successfully!',
    AppLanguage.bengali: 'প্রোফাইল সফলভাবে হালনাগাদ হয়েছে!',
  },
  'patient_profile_update_failed': {
    AppLanguage.english: 'Failed to update profile. Please try again.',
    AppLanguage.bengali: 'প্রোফাইল হালনাগাদ ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
  },
  'patient_err_loading_profile': {
    AppLanguage.english: 'Error loading profile',
    AppLanguage.bengali: 'প্রোফাইল লোড করতে সমস্যা হয়েছে',
  },
  'patient_my_health_profile': {
    AppLanguage.english: 'My Health Profile',
    AppLanguage.bengali: 'আমার স্বাস্থ্য প্রোফাইল',
  },
  'patient_personal_information': {
    AppLanguage.english: 'Personal Information',
    AppLanguage.bengali: 'ব্যক্তিগত তথ্য',
  },
  'patient_date_of_birth': {
    AppLanguage.english: 'Date of Birth',
    AppLanguage.bengali: 'জন্ম তারিখ',
  },
  'patient_years': {
    AppLanguage.english: 'years',
    AppLanguage.bengali: 'বছর',
  },
  'patient_addresses': {
    AppLanguage.english: 'Addresses',
    AppLanguage.bengali: 'ঠিকানা',
  },
  'patient_emergency_contacts': {
    AppLanguage.english: 'Emergency Contacts',
    AppLanguage.bengali: 'জরুরি যোগাযোগ',
  },
  'patient_no_emergency_contacts': {
    AppLanguage.english: 'No emergency contacts defined.',
    AppLanguage.bengali: 'কোনো জরুরি যোগাযোগ নির্ধারিত নেই।',
  },
  'patient_allergies_reactions': {
    AppLanguage.english: 'Allergies & Reactions',
    AppLanguage.bengali: 'অ্যালার্জি ও প্রতিক্রিয়া',
  },
  'patient_no_known_allergies': {
    AppLanguage.english: 'No known allergies.',
    AppLanguage.bengali: 'কোনো পরিচিত অ্যালার্জি নেই।',
  },
  'patient_chronic_diseases': {
    AppLanguage.english: 'Chronic Diseases',
    AppLanguage.bengali: 'দীর্ঘমেয়াদি রোগ',
  },
  'patient_no_chronic_conditions': {
    AppLanguage.english: 'No registered chronic conditions.',
    AppLanguage.bengali: 'কোনো নিবন্ধিত দীর্ঘমেয়াদি রোগ নেই।',
  },
  'patient_diagnosed': {
    AppLanguage.english: 'Diagnosed',
    AppLanguage.bengali: 'নির্ণয়',
  },
  'patient_current_vitals': {
    AppLanguage.english: 'Current Vitals',
    AppLanguage.bengali: 'বর্তমান ভাইটালস',
  },
  'patient_body_weight': {
    AppLanguage.english: 'Body Weight',
    AppLanguage.bengali: 'শারীরিক ওজন',
  },
  'patient_update_profile_wizard': {
    AppLanguage.english: 'Update Profile Wizard',
    AppLanguage.bengali: 'প্রোফাইল হালনাগাদ উইজার্ড',
  },
  'patient_step_personal': {
    AppLanguage.english: 'Personal',
    AppLanguage.bengali: 'ব্যক্তিগত',
  },
  'patient_step_emergency': {
    AppLanguage.english: 'Emergency',
    AppLanguage.bengali: 'জরুরি',
  },
  'patient_step_vitals': {
    AppLanguage.english: 'Vitals',
    AppLanguage.bengali: 'ভাইটালস',
  },
  'patient_copy_present_permanent': {
    AppLanguage.english: 'Copy Present to Permanent Address',
    AppLanguage.bengali: 'বর্তমান ঠিকানা স্থায়ী ঠিকানায় কপি করুন',
  },
  'patient_primary_ice': {
    AppLanguage.english: 'Primary Emergency Contact (ICE)',
    AppLanguage.bengali: 'প্রাথমিক জরুরি যোগাযোগ (ICE)',
  },
  'patient_contact_name': {
    AppLanguage.english: 'Contact Name',
    AppLanguage.bengali: 'যোগাযোগের নাম',
  },
  'patient_relationship': {
    AppLanguage.english: 'Relationship',
    AppLanguage.bengali: 'সম্পর্ক',
  },
  'patient_contact_phone': {
    AppLanguage.english: 'Contact Phone',
    AppLanguage.bengali: 'যোগাযোগের ফোন',
  },
  'patient_bp_systolic': {
    AppLanguage.english: 'BP Systolic (mmHg)',
    AppLanguage.bengali: 'BP সিস্টোলিক (mmHg)',
  },
  'patient_bp_diastolic': {
    AppLanguage.english: 'BP Diastolic (mmHg)',
    AppLanguage.bengali: 'BP ডায়াস্টোলিক (mmHg)',
  },
  'patient_blood_glucose_unit': {
    AppLanguage.english: 'Blood Glucose (mg/dL)',
    AppLanguage.bengali: 'রক্তে গ্লুকোজ (mg/dL)',
  },
  'patient_heart_rate_unit': {
    AppLanguage.english: 'Heart Rate (bpm)',
    AppLanguage.bengali: 'হৃদস্পন্দন (bpm)',
  },
  'patient_body_weight_unit': {
    AppLanguage.english: 'Body Weight (kg)',
    AppLanguage.bengali: 'শারীরিক ওজন (kg)',
  },
  'patient_save_changes': {
    AppLanguage.english: 'Save Changes',
    AppLanguage.bengali: 'পরিবর্তন সংরক্ষণ করুন',
  },
  'patient_health_id': {
    AppLanguage.english: 'Health ID',
    AppLanguage.bengali: 'হেলথ আইডি',
  },
  'patient_organ_donor': {
    AppLanguage.english: 'Organ Donor ❤️',
    AppLanguage.bengali: 'অঙ্গদাতা ❤️',
  },
  'patient_edit_profile': {
    AppLanguage.english: 'Edit Profile',
    AppLanguage.bengali: 'প্রোফাইল সম্পাদনা',
  },
};
