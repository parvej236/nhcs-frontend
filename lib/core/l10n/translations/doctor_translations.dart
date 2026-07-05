import '../app_language.dart';

/// Doctor portal page strings. Keys are prefixed with `doctor_`.
const Map<String, Map<AppLanguage, String>> doctorTranslations = {
  // =========================================================================
  // Dashboard
  // =========================================================================
  'doctor_dashboard_title': {
    AppLanguage.english: 'Doctor Dashboard',
    AppLanguage.bengali: 'ডাক্তার ড্যাশবোর্ড',
  },
  'doctor_loading_department': {
    AppLanguage.english: 'Loading department info…',
    AppLanguage.bengali: 'বিভাগের তথ্য লোড হচ্ছে…',
  },
  'doctor_reload_dashboard': {
    AppLanguage.english: 'Reload Dashboard',
    AppLanguage.bengali: 'ড্যাশবোর্ড রিলোড করুন',
  },
  'doctor_dashboard_reloaded': {
    AppLanguage.english: 'Dashboard reloaded.',
    AppLanguage.bengali: 'ড্যাশবোর্ড রিলোড হয়েছে।',
  },
  'doctor_stat_todays_patients': {
    AppLanguage.english: "Today's Patients",
    AppLanguage.bengali: 'আজকের রোগী',
  },
  'doctor_stat_todays_patients_sub': {
    AppLanguage.english: '+2 vs yesterday',
    AppLanguage.bengali: 'গতকালের তুলনায় +২',
  },
  'doctor_stat_followups': {
    AppLanguage.english: 'Follow-ups',
    AppLanguage.bengali: 'ফলো-আপ',
  },
  'doctor_stat_followups_sub': {
    AppLanguage.english: '2 scheduled',
    AppLanguage.bengali: '২টি নির্ধারিত',
  },
  'doctor_stat_emergency': {
    AppLanguage.english: 'Emergency',
    AppLanguage.bengali: 'জরুরি',
  },
  'doctor_stat_emergency_sub': {
    AppLanguage.english: 'Action required',
    AppLanguage.bengali: 'পদক্ষেপ প্রয়োজন',
  },
  'doctor_stat_pending_reports': {
    AppLanguage.english: 'Pending Reports',
    AppLanguage.bengali: 'অপেক্ষমাণ রিপোর্ট',
  },
  'doctor_stat_pending_reports_sub': {
    AppLanguage.english: '3 unread',
    AppLanguage.bengali: '৩টি অপঠিত',
  },
  'doctor_ai_daily_briefing_title': {
    AppLanguage.english: 'AI Daily Briefing & Patient Summary',
    AppLanguage.bengali: 'এআই দৈনিক ব্রিফিং ও রোগীর সারসংক্ষেপ',
  },
  'doctor_ai_briefing_rec1': {
    AppLanguage.english:
        'Check-in on Emergency consult Patient: Fatema Zohra immediately.',
    AppLanguage.bengali:
        'জরুরি পরামর্শের রোগী ফাতেমা জোহরার সাথে অবিলম্বে যোগাযোগ করুন।',
  },
  'doctor_ai_briefing_rec2': {
    AppLanguage.english: 'Verify pending CBC lab report for Rahim Islam.',
    AppLanguage.bengali: 'রহিম ইসলামের অপেক্ষমাণ CBC ল্যাব রিপোর্ট যাচাই করুন।',
  },
  'doctor_ai_briefing_rec3': {
    AppLanguage.english:
        'Prepare weekly clinical shift roster update for approval.',
    AppLanguage.bengali:
        'অনুমোদনের জন্য সাপ্তাহিক ক্লিনিক্যাল শিফট রোস্টার আপডেট প্রস্তুত করুন।',
  },
  'doctor_error_loading_summary': {
    AppLanguage.english: 'Error loading summary:',
    AppLanguage.bengali: 'সারসংক্ষেপ লোড করতে ত্রুটি:',
  },
  'doctor_patient_queue_today': {
    AppLanguage.english: 'Patient Queue — Today',
    AppLanguage.bengali: 'রোগীর সারি — আজ',
  },
  'doctor_waiting_count_suffix': {
    AppLanguage.english: 'waiting',
    AppLanguage.bengali: 'জন অপেক্ষমাণ',
  },
  'doctor_queue_empty_title': {
    AppLanguage.english: 'No patients in the queue yet',
    AppLanguage.bengali: 'সারিতে এখনও কোনো রোগী নেই',
  },
  'doctor_queue_empty_desc': {
    AppLanguage.english:
        'New appointments booked by patients will appear here in real time.',
    AppLanguage.bengali:
        'রোগীদের বুক করা নতুন অ্যাপয়েন্টমেন্ট এখানে রিয়েল-টাইমে দেখা যাবে।',
  },
  'doctor_status_in_consultation': {
    AppLanguage.english: 'IN CONSULTATION',
    AppLanguage.bengali: 'পরামর্শ চলছে',
  },
  'doctor_status_waiting': {
    AppLanguage.english: 'WAITING',
    AppLanguage.bengali: 'অপেক্ষমাণ',
  },
  'doctor_btn_continue': {
    AppLanguage.english: 'Continue',
    AppLanguage.bengali: 'চালিয়ে যান',
  },
  'doctor_btn_start': {
    AppLanguage.english: 'Start',
    AppLanguage.bengali: 'শুরু করুন',
  },

  // =========================================================================
  // Clinical Workspace
  // =========================================================================
  'doctor_treatment_submitted': {
    AppLanguage.english:
        'Treatment plan submitted successfully and synced to patient records!',
    AppLanguage.bengali:
        'চিকিৎসা পরিকল্পনা সফলভাবে জমা এবং রোগীর রেকর্ডে সিঙ্ক হয়েছে!',
  },
  'doctor_reload_workspace': {
    AppLanguage.english: 'Reload Workspace',
    AppLanguage.bengali: 'ওয়ার্কস্পেস রিলোড করুন',
  },
  'doctor_workspace_reloaded': {
    AppLanguage.english: 'Workspace reloaded.',
    AppLanguage.bengali: 'ওয়ার্কস্পেস রিলোড হয়েছে।',
  },
  'doctor_clinical_workspace_title': {
    AppLanguage.english: 'Clinical Workspace',
    AppLanguage.bengali: 'ক্লিনিক্যাল ওয়ার্কস্পেস',
  },
  'doctor_active_patient_prefix': {
    AppLanguage.english: 'Active Patient:',
    AppLanguage.bengali: 'সক্রিয় রোগী:',
  },
  'doctor_select_patient_hint': {
    AppLanguage.english: '• Select a patient from the queue or search below',
    AppLanguage.bengali: '• সারি থেকে একজন রোগী নির্বাচন করুন অথবা নিচে অনুসন্ধান করুন',
  },
  'doctor_cancel': {
    AppLanguage.english: 'Cancel',
    AppLanguage.bengali: 'বাতিল',
  },
  'doctor_submitting': {
    AppLanguage.english: 'Submitting...',
    AppLanguage.bengali: 'জমা দেওয়া হচ্ছে...',
  },
  'doctor_submit_treatment': {
    AppLanguage.english: 'Submit Treatment',
    AppLanguage.bengali: 'চিকিৎসা জমা দিন',
  },
  'doctor_patient_profile_not_found': {
    AppLanguage.english: 'Patient profile not found.',
    AppLanguage.bengali: 'রোগীর প্রোফাইল পাওয়া যায়নি।',
  },
  'doctor_error_loading_profile': {
    AppLanguage.english: 'Error loading profile:',
    AppLanguage.bengali: 'প্রোফাইল লোড করতে ত্রুটি:',
  },
  'doctor_select_patient_open_form': {
    AppLanguage.english: 'Select a patient to open clinical form.',
    AppLanguage.bengali: 'ক্লিনিক্যাল ফর্ম খুলতে একজন রোগী নির্বাচন করুন।',
  },
  'doctor_health_id_search_hint': {
    AppLanguage.english:
        'Enter National Health ID to retrieve records... (e.g. NUD-892-441-X7)',
    AppLanguage.bengali:
        'রেকর্ড আনতে জাতীয় স্বাস্থ্য আইডি লিখুন... (যেমন NUD-892-441-X7)',
  },
  'doctor_no_active_consultation': {
    AppLanguage.english: 'No Active Consultation',
    AppLanguage.bengali: 'কোনো সক্রিয় পরামর্শ নেই',
  },
  'doctor_no_consultation_desc': {
    AppLanguage.english:
        'Select a patient from the queue in the Dashboard, or search using their National Unified Health ID to access their lifelong health history.',
    AppLanguage.bengali:
        'ড্যাশবোর্ডের সারি থেকে একজন রোগী নির্বাচন করুন, অথবা তাদের আজীবন স্বাস্থ্য ইতিহাস দেখতে জাতীয় ইউনিফায়েড স্বাস্থ্য আইডি দিয়ে অনুসন্ধান করুন।',
  },
  'doctor_dob_prefix': {
    AppLanguage.english: 'DOB:',
    AppLanguage.bengali: 'জন্মতারিখ:',
  },
  'doctor_years_short': {
    AppLanguage.english: 'yrs',
    AppLanguage.bengali: 'বছর',
  },
  'doctor_blood_prefix': {
    AppLanguage.english: 'Blood:',
    AppLanguage.bengali: 'রক্ত:',
  },
  'doctor_allergies': {
    AppLanguage.english: 'Allergies',
    AppLanguage.bengali: 'অ্যালার্জি',
  },
  'doctor_none': {
    AppLanguage.english: 'None',
    AppLanguage.bengali: 'নেই',
  },
  'doctor_chronic_diseases': {
    AppLanguage.english: 'Chronic Diseases',
    AppLanguage.bengali: 'দীর্ঘস্থায়ী রোগ',
  },
  'doctor_unified_id_prefix': {
    AppLanguage.english: 'Unified ID:',
    AppLanguage.bengali: 'ইউনিফায়েড আইডি:',
  },
  'doctor_ai_clinical_overview': {
    AppLanguage.english: 'AI Clinical Overview',
    AppLanguage.bengali: 'এআই ক্লিনিক্যাল ওভারভিউ',
  },
  'doctor_profile_loaded_for': {
    AppLanguage.english: 'Patient profile loaded for',
    AppLanguage.bengali: 'রোগীর প্রোফাইল লোড হয়েছে —',
  },
  'doctor_profile_loaded_tail': {
    AppLanguage.english:
        '. Review current vital signs, allergies and chronic conditions before prescribing treatment. Use "Generate Briefing" for an AI summary of this patient\'s medical history.',
    AppLanguage.bengali:
        '। চিকিৎসা নির্ধারণের আগে বর্তমান ভাইটাল সাইন, অ্যালার্জি ও দীর্ঘস্থায়ী অবস্থা পর্যালোচনা করুন। এই রোগীর চিকিৎসা ইতিহাসের এআই সারসংক্ষেপের জন্য "ব্রিফিং তৈরি করুন" ব্যবহার করুন।',
  },
  'doctor_ai_medical_history_briefing': {
    AppLanguage.english: 'AI Medical History Briefing',
    AppLanguage.bengali: 'এআই চিকিৎসা ইতিহাস ব্রিফিং',
  },
  'doctor_analyzing': {
    AppLanguage.english: 'Analyzing...',
    AppLanguage.bengali: 'বিশ্লেষণ করা হচ্ছে...',
  },
  'doctor_generate_briefing': {
    AppLanguage.english: 'Generate Briefing',
    AppLanguage.bengali: 'ব্রিফিং তৈরি করুন',
  },
  'doctor_ai_briefing_generated': {
    AppLanguage.english: 'AI Medical Briefing Generated',
    AppLanguage.bengali: 'এআই চিকিৎসা ব্রিফিং তৈরি হয়েছে',
  },
  'doctor_regenerate_briefing': {
    AppLanguage.english: 'Regenerate Briefing',
    AppLanguage.bengali: 'ব্রিফিং পুনরায় তৈরি করুন',
  },
  'doctor_latest_vital_signs': {
    AppLanguage.english: 'Latest Vital Signs',
    AppLanguage.bengali: 'সর্বশেষ ভাইটাল সাইন',
  },
  'doctor_blood_pressure': {
    AppLanguage.english: 'Blood Pressure',
    AppLanguage.bengali: 'রক্তচাপ',
  },
  'doctor_blood_glucose': {
    AppLanguage.english: 'Blood Glucose',
    AppLanguage.bengali: 'রক্তে গ্লুকোজ',
  },
  'doctor_heart_rate': {
    AppLanguage.english: 'Heart Rate',
    AppLanguage.bengali: 'হৃদস্পন্দন',
  },
  'doctor_chronic_disease_log': {
    AppLanguage.english: 'Chronic Disease Log',
    AppLanguage.bengali: 'দীর্ঘস্থায়ী রোগের নথি',
  },
  'doctor_diagnosed_prefix': {
    AppLanguage.english: 'Diagnosed:',
    AppLanguage.bengali: 'নির্ণয়:',
  },
  'doctor_status_prefix': {
    AppLanguage.english: 'Status:',
    AppLanguage.bengali: 'অবস্থা:',
  },
  'doctor_historic_records': {
    AppLanguage.english: 'Historic Records',
    AppLanguage.bengali: 'পূর্ববর্তী রেকর্ড',
  },
  'doctor_no_historic_records': {
    AppLanguage.english: 'No historic lab reports or prescriptions yet',
    AppLanguage.bengali: 'এখনও কোনো পূর্ববর্তী ল্যাব রিপোর্ট বা প্রেসক্রিপশন নেই',
  },
  'doctor_records_appear_here': {
    AppLanguage.english: 'Records created for this patient will appear here.',
    AppLanguage.bengali: 'এই রোগীর জন্য তৈরি রেকর্ড এখানে দেখা যাবে।',
  },
  'doctor_symptoms_complaints': {
    AppLanguage.english: 'Symptoms / Presenting Complaints',
    AppLanguage.bengali: 'উপসর্গ / প্রধান অভিযোগ',
  },
  'doctor_symptom_hint': {
    AppLanguage.english: 'Type symptom... (e.g. Chest pain, Shortness of breath)',
    AppLanguage.bengali: 'উপসর্গ লিখুন... (যেমন বুকে ব্যথা, শ্বাসকষ্ট)',
  },
  'doctor_add': {
    AppLanguage.english: 'Add',
    AppLanguage.bengali: 'যোগ করুন',
  },
  'doctor_diagnosis': {
    AppLanguage.english: 'Diagnosis',
    AppLanguage.bengali: 'রোগ নির্ণয়',
  },
  'doctor_diagnosis_hint': {
    AppLanguage.english: 'Diagnosis (ICD name)...',
    AppLanguage.bengali: 'রোগ নির্ণয় (ICD নাম)...',
  },
  'doctor_prescribe_medication': {
    AppLanguage.english: 'Prescribe Medication',
    AppLanguage.bengali: 'ওষুধ নির্ধারণ করুন',
  },
  'doctor_medicine_name_hint': {
    AppLanguage.english: 'Medicine name (e.g. Glimepiride, Amlodipine)',
    AppLanguage.bengali: 'ওষুধের নাম (যেমন Glimepiride, Amlodipine)',
  },
  'doctor_dosage_hint': {
    AppLanguage.english: 'Dosage (e.g. 1+0+1)',
    AppLanguage.bengali: 'মাত্রা (যেমন ১+০+১)',
  },
  'doctor_duration_hint': {
    AppLanguage.english: 'Duration (e.g. 15 days)',
    AppLanguage.bengali: 'সময়কাল (যেমন ১৫ দিন)',
  },
  'doctor_instructions_hint': {
    AppLanguage.english: 'e.g. After food',
    AppLanguage.bengali: 'যেমন খাবারের পরে',
  },
  'doctor_add_medicine': {
    AppLanguage.english: 'Add Medicine',
    AppLanguage.bengali: 'ওষুধ যোগ করুন',
  },
  'doctor_dosage_prefix': {
    AppLanguage.english: 'Dosage:',
    AppLanguage.bengali: 'মাত্রা:',
  },
  'doctor_duration_prefix': {
    AppLanguage.english: 'Duration:',
    AppLanguage.bengali: 'সময়কাল:',
  },
  'doctor_investigations_diagnostics': {
    AppLanguage.english: 'Investigations / Diagnostics',
    AppLanguage.bengali: 'পরীক্ষা / ডায়াগনস্টিকস',
  },
  'doctor_clinical_notes': {
    AppLanguage.english: 'Clinical Notes / Observations',
    AppLanguage.bengali: 'ক্লিনিক্যাল নোট / পর্যবেক্ষণ',
  },
  'doctor_clinical_notes_hint': {
    AppLanguage.english:
        'Enter clinical history findings, observations, or advice...',
    AppLanguage.bengali:
        'ক্লিনিক্যাল ইতিহাসের ফলাফল, পর্যবেক্ষণ বা পরামর্শ লিখুন...',
  },
  'doctor_followup': {
    AppLanguage.english: 'Follow-up',
    AppLanguage.bengali: 'ফলো-আপ',
  },
  'doctor_followup_hint': {
    AppLanguage.english: 'In 2 weeks, In 1 month, etc.',
    AppLanguage.bengali: '২ সপ্তাহে, ১ মাসে, ইত্যাদি',
  },
  'doctor_referral_optional': {
    AppLanguage.english: 'Referral (Optional)',
    AppLanguage.bengali: 'রেফারেল (ঐচ্ছিক)',
  },
  'doctor_referral_hint': {
    AppLanguage.english: 'Specialist name / Department',
    AppLanguage.bengali: 'বিশেষজ্ঞের নাম / বিভাগ',
  },
  'doctor_allergy_warning_title': {
    AppLanguage.english: 'Critical Allergy Warning (Penicillin Derivatives)',
    AppLanguage.bengali: 'গুরুতর অ্যালার্জি সতর্কতা (পেনিসিলিন ডেরিভেটিভ)',
  },
  'doctor_allergy_warning_desc': {
    AppLanguage.english:
        'Patient has a recorded Penicillin allergy with severity: Severe (Anaphylaxis). Prescribed medicine is a penicillin derivative. Risk of severe allergic reaction!',
    AppLanguage.bengali:
        'রোগীর পেনিসিলিন অ্যালার্জি রেকর্ড করা আছে, তীব্রতা: গুরুতর (অ্যানাফাইল্যাক্সিস)। নির্ধারিত ওষুধটি একটি পেনিসিলিন ডেরিভেটিভ। গুরুতর অ্যালার্জিক প্রতিক্রিয়ার ঝুঁকি!',
  },
  'doctor_allergy_warning_rec1': {
    AppLanguage.english:
        'Replace Amoxicillin/Penicillin with a Macrolide (e.g. Azithromycin) or Fluoroquinolone.',
    AppLanguage.bengali:
        'Amoxicillin/Penicillin এর পরিবর্তে একটি ম্যাক্রোলাইড (যেমন Azithromycin) বা ফ্লুরোকুইনোলোন ব্যবহার করুন।',
  },
  'doctor_allergy_warning_rec2': {
    AppLanguage.english:
        'Verify patient allergy history card prior to treatment plan submission.',
    AppLanguage.bengali:
        'চিকিৎসা পরিকল্পনা জমা দেওয়ার আগে রোগীর অ্যালার্জি ইতিহাস কার্ড যাচাই করুন।',
  },
  'doctor_drug_interaction_title': {
    AppLanguage.english: 'Drug-Drug Interaction Alert (Aspirin & Glimepiride)',
    AppLanguage.bengali:
        'ড্রাগ-ড্রাগ ইন্টারঅ্যাকশন সতর্কতা (Aspirin ও Glimepiride)',
  },
  'doctor_drug_interaction_desc': {
    AppLanguage.english:
        'Aspirin may enhance the hypoglycemic effect of Glimepiride, increasing the risk of hypoglycemia. Monitor blood glucose levels closely.',
    AppLanguage.bengali:
        'Aspirin, Glimepiride-এর হাইপোগ্লাইসেমিক প্রভাব বাড়াতে পারে, যা হাইপোগ্লাইসেমিয়ার ঝুঁকি বাড়ায়। রক্তে গ্লুকোজের মাত্রা নিবিড়ভাবে পর্যবেক্ষণ করুন।',
  },
  'doctor_drug_interaction_rec1': {
    AppLanguage.english:
        'Adjust Glimepiride dosage if co-administered with daily Aspirin.',
    AppLanguage.bengali:
        'দৈনিক Aspirin-এর সাথে একত্রে দিলে Glimepiride-এর মাত্রা সমন্বয় করুন।',
  },
  'doctor_drug_interaction_rec2': {
    AppLanguage.english:
        'Advise the patient to monitor for symptoms of hypoglycemia (dizziness, sweating, shakiness).',
    AppLanguage.bengali:
        'রোগীকে হাইপোগ্লাইসেমিয়ার উপসর্গ (মাথা ঘোরা, ঘাম, কাঁপুনি) পর্যবেক্ষণ করতে পরামর্শ দিন।',
  },
  'doctor_diagnostics_support_title': {
    AppLanguage.english: 'Clinical Diagnostics Support Recommendation',
    AppLanguage.bengali: 'ক্লিনিক্যাল ডায়াগনস্টিকস সহায়তা সুপারিশ',
  },
  'doctor_diagnostics_support_desc': {
    AppLanguage.english:
        'Patient presents with cardiac symptoms (e.g. chest pain). A 12-lead ECG is recommended to rule out myocardial ischemia.',
    AppLanguage.bengali:
        'রোগীর হৃদরোগের উপসর্গ (যেমন বুকে ব্যথা) রয়েছে। মায়োকার্ডিয়াল ইস্কেমিয়া বাদ দিতে ১২-লিড ECG সুপারিশ করা হয়।',
  },
  'doctor_diagnostics_support_rec1': {
    AppLanguage.english:
        'Order a 12-lead resting ECG card from the Investigations menu.',
    AppLanguage.bengali:
        'পরীক্ষা মেনু থেকে একটি ১২-লিড রেস্টিং ECG অর্ডার করুন।',
  },
  'doctor_diagnostics_support_rec2': {
    AppLanguage.english: 'Monitor baseline cardiovascular telemetry logs.',
    AppLanguage.bengali: 'বেসলাইন কার্ডিওভাসকুলার টেলিমেট্রি লগ পর্যবেক্ষণ করুন।',
  },
  'doctor_ai_safety_check_ok': {
    AppLanguage.english: 'AI Safety Check: No issues or warnings found.',
    AppLanguage.bengali: 'এআই নিরাপত্তা যাচাই: কোনো সমস্যা বা সতর্কতা পাওয়া যায়নি।',
  },

  // =========================================================================
  // Report Review
  // =========================================================================
  'doctor_report_review_portal': {
    AppLanguage.english: 'Report Review Portal',
    AppLanguage.bengali: 'রিপোর্ট পর্যালোচনা পোর্টাল',
  },
  'doctor_reload_reports': {
    AppLanguage.english: 'Reload Reports',
    AppLanguage.bengali: 'রিপোর্ট রিলোড করুন',
  },
  'doctor_reports_reloaded': {
    AppLanguage.english: 'Reports reloaded.',
    AppLanguage.bengali: 'রিপোর্ট রিলোড হয়েছে।',
  },
  'doctor_filter_all': {
    AppLanguage.english: 'All',
    AppLanguage.bengali: 'সব',
  },
  'doctor_filter_pending': {
    AppLanguage.english: 'Pending',
    AppLanguage.bengali: 'অপেক্ষমাণ',
  },
  'doctor_filter_reviewed': {
    AppLanguage.english: 'Reviewed',
    AppLanguage.bengali: 'পর্যালোচিত',
  },
  'doctor_no_reports_category': {
    AppLanguage.english: 'No reports found in this category',
    AppLanguage.bengali: 'এই বিভাগে কোনো রিপোর্ট পাওয়া যায়নি',
  },
  'doctor_all_caught_up': {
    AppLanguage.english:
        'All caught up! Excellent work maintaining patient care records.',
    AppLanguage.bengali:
        'সব সম্পন্ন! রোগীর যত্নের রেকর্ড রক্ষণাবেক্ষণে চমৎকার কাজ।',
  },
  'doctor_error_loading_reports': {
    AppLanguage.english: 'Error loading reports:',
    AppLanguage.bengali: 'রিপোর্ট লোড করতে ত্রুটি:',
  },
  'doctor_id_label': {
    AppLanguage.english: 'ID:',
    AppLanguage.bengali: 'আইডি:',
  },
  'doctor_ordered_prefix': {
    AppLanguage.english: 'Ordered:',
    AppLanguage.bengali: 'আদেশকৃত:',
  },
  'doctor_test_parameters_results': {
    AppLanguage.english: 'Test Parameters & Results',
    AppLanguage.bengali: 'পরীক্ষার প্যারামিটার ও ফলাফল',
  },
  'doctor_trend_prefix': {
    AppLanguage.english: 'Trend:',
    AppLanguage.bengali: 'প্রবণতা:',
  },
  'doctor_ai_trend_assessment_prefix': {
    AppLanguage.english: 'AI Trend Assessment:',
    AppLanguage.bengali: 'এআই প্রবণতা মূল্যায়ন:',
  },
  'doctor_view_full_report': {
    AppLanguage.english: 'View Full Report',
    AppLanguage.bengali: 'সম্পূর্ণ রিপোর্ট দেখুন',
  },
  'doctor_open_workspace': {
    AppLanguage.english: 'Open Workspace',
    AppLanguage.bengali: 'ওয়ার্কস্পেস খুলুন',
  },
  'doctor_mark_reviewed': {
    AppLanguage.english: 'Mark Reviewed',
    AppLanguage.bengali: 'পর্যালোচিত চিহ্নিত করুন',
  },
  'doctor_report_for': {
    AppLanguage.english: 'Report for',
    AppLanguage.bengali: '',
  },
  'doctor_marked_reviewed_suffix': {
    AppLanguage.english: 'marked as Reviewed.',
    AppLanguage.bengali: 'এর রিপোর্ট পর্যালোচিত হিসেবে চিহ্নিত হয়েছে।',
  },
  'doctor_detailed_diagnostics_report': {
    AppLanguage.english: 'Detailed Diagnostics Report',
    AppLanguage.bengali: 'বিস্তারিত ডায়াগনস্টিকস রিপোর্ট',
  },
  'doctor_patient_name_label': {
    AppLanguage.english: 'Patient Name:',
    AppLanguage.bengali: 'রোগীর নাম:',
  },
  'doctor_health_id_label': {
    AppLanguage.english: 'Health ID:',
    AppLanguage.bengali: 'স্বাস্থ্য আইডি:',
  },
  'doctor_investigation_label': {
    AppLanguage.english: 'Investigation:',
    AppLanguage.bengali: 'পরীক্ষা:',
  },
  'doctor_category_label': {
    AppLanguage.english: 'Category:',
    AppLanguage.bengali: 'বিভাগ:',
  },
  'doctor_ordered_date_label': {
    AppLanguage.english: 'Ordered Date:',
    AppLanguage.bengali: 'আদেশের তারিখ:',
  },
  'doctor_lab_readings_values': {
    AppLanguage.english: 'Lab Readings & Values:',
    AppLanguage.bengali: 'ল্যাব রিডিং ও মান:',
  },
  'doctor_ai_interpretation': {
    AppLanguage.english: 'AI Interpretation:',
    AppLanguage.bengali: 'এআই ব্যাখ্যা:',
  },
  'doctor_ai_interp_prefix': {
    AppLanguage.english: 'Comparative analysis with history shows',
    AppLanguage.bengali: 'ইতিহাসের সাথে তুলনামূলক বিশ্লেষণ দেখায়',
  },
  'doctor_ai_interp_suffix': {
    AppLanguage.english:
        '. Patient medication compliance should be checked. If parameters do not stabilize, please review the clinical medication dosage.',
    AppLanguage.bengali:
        '। রোগীর ওষুধ সেবনের সঙ্গতি পরীক্ষা করা উচিত। প্যারামিটারগুলি স্থিতিশীল না হলে, অনুগ্রহ করে ক্লিনিক্যাল ওষুধের মাত্রা পর্যালোচনা করুন।',
  },
  'doctor_close': {
    AppLanguage.english: 'Close',
    AppLanguage.bengali: 'বন্ধ করুন',
  },

  // =========================================================================
  // Schedule
  // =========================================================================
  'doctor_my_schedule': {
    AppLanguage.english: 'My Schedule',
    AppLanguage.bengali: 'আমার সময়সূচী',
  },
  'doctor_reload_schedule': {
    AppLanguage.english: 'Reload Schedule',
    AppLanguage.bengali: 'সময়সূচী রিলোড করুন',
  },
  'doctor_schedule_reloaded': {
    AppLanguage.english: 'Schedule reloaded.',
    AppLanguage.bengali: 'সময়সূচী রিলোড হয়েছে।',
  },
  'doctor_no_appointments_day': {
    AppLanguage.english: 'No appointments scheduled for this day.',
    AppLanguage.bengali: 'এই দিনের জন্য কোনো অ্যাপয়েন্টমেন্ট নির্ধারিত নেই।',
  },
  'doctor_error_loading_schedule': {
    AppLanguage.english: 'Error loading schedule:',
    AppLanguage.bengali: 'সময়সূচী লোড করতে ত্রুটি:',
  },
  'doctor_available_slot': {
    AppLanguage.english: 'Available Slot — Click to block',
    AppLanguage.bengali: 'খালি স্লট — ব্লক করতে ক্লিক করুন',
  },
  'doctor_month_1': {
    AppLanguage.english: 'January',
    AppLanguage.bengali: 'জানুয়ারি',
  },
  'doctor_month_2': {
    AppLanguage.english: 'February',
    AppLanguage.bengali: 'ফেব্রুয়ারি',
  },
  'doctor_month_3': {
    AppLanguage.english: 'March',
    AppLanguage.bengali: 'মার্চ',
  },
  'doctor_month_4': {
    AppLanguage.english: 'April',
    AppLanguage.bengali: 'এপ্রিল',
  },
  'doctor_month_5': {
    AppLanguage.english: 'May',
    AppLanguage.bengali: 'মে',
  },
  'doctor_month_6': {
    AppLanguage.english: 'June',
    AppLanguage.bengali: 'জুন',
  },
  'doctor_month_7': {
    AppLanguage.english: 'July',
    AppLanguage.bengali: 'জুলাই',
  },
  'doctor_month_8': {
    AppLanguage.english: 'August',
    AppLanguage.bengali: 'আগস্ট',
  },
  'doctor_month_9': {
    AppLanguage.english: 'September',
    AppLanguage.bengali: 'সেপ্টেম্বর',
  },
  'doctor_month_10': {
    AppLanguage.english: 'October',
    AppLanguage.bengali: 'অক্টোবর',
  },
  'doctor_month_11': {
    AppLanguage.english: 'November',
    AppLanguage.bengali: 'নভেম্বর',
  },
  'doctor_month_12': {
    AppLanguage.english: 'December',
    AppLanguage.bengali: 'ডিসেম্বর',
  },

  // =========================================================================
  // Profile
  // =========================================================================
  'doctor_profile_updated': {
    AppLanguage.english: 'Profile updated successfully in central registry!',
    AppLanguage.bengali: 'কেন্দ্রীয় নিবন্ধনে প্রোফাইল সফলভাবে আপডেট হয়েছে!',
  },
  'doctor_profile_update_failed': {
    AppLanguage.english: 'Failed to update profile:',
    AppLanguage.bengali: 'প্রোফাইল আপডেট করতে ব্যর্থ:',
  },
  'doctor_professional_profile': {
    AppLanguage.english: 'Professional Profile',
    AppLanguage.bengali: 'পেশাগত প্রোফাইল',
  },
  'doctor_reload_profile': {
    AppLanguage.english: 'Reload Profile',
    AppLanguage.bengali: 'প্রোফাইল রিলোড করুন',
  },
  'doctor_profile_reloaded': {
    AppLanguage.english: 'Profile reloaded.',
    AppLanguage.bengali: 'প্রোফাইল রিলোড হয়েছে।',
  },
  'doctor_saving': {
    AppLanguage.english: 'Saving...',
    AppLanguage.bengali: 'সংরক্ষণ করা হচ্ছে...',
  },
  'doctor_save_changes': {
    AppLanguage.english: 'Save Changes',
    AppLanguage.bengali: 'পরিবর্তন সংরক্ষণ করুন',
  },
  'doctor_edit_profile': {
    AppLanguage.english: 'Edit Profile',
    AppLanguage.bengali: 'প্রোফাইল সম্পাদনা করুন',
  },
  'doctor_doctor_name_hint': {
    AppLanguage.english: 'Doctor Name',
    AppLanguage.bengali: 'ডাক্তারের নাম',
  },
  'doctor_verified': {
    AppLanguage.english: 'Verified',
    AppLanguage.bengali: 'যাচাইকৃত',
  },
  'doctor_specialization_hint': {
    AppLanguage.english: 'Specialization (e.g. Cardiology)',
    AppLanguage.bengali: 'বিশেষত্ব (যেমন কার্ডিওলজি)',
  },
  'doctor_license_prefix': {
    AppLanguage.english: 'License:',
    AppLanguage.bengali: 'লাইসেন্স:',
  },
  'doctor_years_experience_suffix': {
    AppLanguage.english: 'years experience',
    AppLanguage.bengali: 'বছরের অভিজ্ঞতা',
  },
  'doctor_professional_information': {
    AppLanguage.english: 'Professional Information',
    AppLanguage.bengali: 'পেশাগত তথ্য',
  },
  'doctor_education_degrees': {
    AppLanguage.english: 'Education & Degrees',
    AppLanguage.bengali: 'শিক্ষা ও ডিগ্রি',
  },
  'doctor_hospital_affiliations': {
    AppLanguage.english: 'Hospital Affiliations',
    AppLanguage.bengali: 'হাসপাতাল সংযুক্তি',
  },
  'doctor_performance_summary': {
    AppLanguage.english: 'Performance Summary',
    AppLanguage.bengali: 'কর্মক্ষমতা সারসংক্ষেপ',
  },
  'doctor_certifications': {
    AppLanguage.english: 'Certifications',
    AppLanguage.bengali: 'সার্টিফিকেশন',
  },
  'doctor_full_name': {
    AppLanguage.english: 'Full Name',
    AppLanguage.bengali: 'পূর্ণ নাম',
  },
  'doctor_specialization': {
    AppLanguage.english: 'Specialization',
    AppLanguage.bengali: 'বিশেষত্ব',
  },
  'doctor_hospital_affiliation': {
    AppLanguage.english: 'Hospital Affiliation',
    AppLanguage.bengali: 'হাসপাতাল সংযুক্তি',
  },
  'doctor_bmdc_registration': {
    AppLanguage.english: 'BMDC Registration',
    AppLanguage.bengali: 'BMDC নিবন্ধন',
  },
  'doctor_experience_years': {
    AppLanguage.english: 'Experience (Years)',
    AppLanguage.bengali: 'অভিজ্ঞতা (বছর)',
  },
  'doctor_consultation_fee': {
    AppLanguage.english: 'Consultation Fee (BDT)',
    AppLanguage.bengali: 'পরামর্শ ফি (টাকা)',
  },
  'doctor_contact_number': {
    AppLanguage.english: 'Contact Number',
    AppLanguage.bengali: 'যোগাযোগ নম্বর',
  },
  'doctor_senior_consultant': {
    AppLanguage.english: 'Senior Consultant',
    AppLanguage.bengali: 'সিনিয়র কনসালট্যান্ট',
  },
  'doctor_visiting_consultant': {
    AppLanguage.english: 'Visiting Consultant',
    AppLanguage.bengali: 'ভিজিটিং কনসালট্যান্ট',
  },
  'doctor_cardiology_dept': {
    AppLanguage.english: 'Cardiology Dept',
    AppLanguage.bengali: 'কার্ডিওলজি বিভাগ',
  },
  'doctor_interventional': {
    AppLanguage.english: 'Interventional',
    AppLanguage.bengali: 'ইন্টারভেনশনাল',
  },
  'doctor_status_active': {
    AppLanguage.english: 'Active',
    AppLanguage.bengali: 'সক্রিয়',
  },
  'doctor_total_patients_treated': {
    AppLanguage.english: 'Total Patients Treated',
    AppLanguage.bengali: 'মোট চিকিৎসাপ্রাপ্ত রোগী',
  },
  'doctor_this_month': {
    AppLanguage.english: 'This Month',
    AppLanguage.bengali: 'এই মাস',
  },
  'doctor_followup_compliance': {
    AppLanguage.english: 'Follow-up Compliance',
    AppLanguage.bengali: 'ফলো-আপ সঙ্গতি',
  },
  'doctor_average_rating': {
    AppLanguage.english: 'Average Rating',
    AppLanguage.bengali: 'গড় রেটিং',
  },
  'doctor_cert_acls': {
    AppLanguage.english: 'Advanced Cardiac Life Support',
    AppLanguage.bengali: 'অ্যাডভান্সড কার্ডিয়াক লাইফ সাপোর্ট',
  },
  'doctor_cert_echo': {
    AppLanguage.english: 'Echocardiography',
    AppLanguage.bengali: 'ইকোকার্ডিওগ্রাফি',
  },
  'doctor_cert_interventional_fellowship': {
    AppLanguage.english: 'Interventional Cardiology Fellowship',
    AppLanguage.bengali: 'ইন্টারভেনশনাল কার্ডিওলজি ফেলোশিপ',
  },
  'doctor_status_valid': {
    AppLanguage.english: 'Valid',
    AppLanguage.bengali: 'বৈধ',
  },
  'doctor_status_completed': {
    AppLanguage.english: 'Completed',
    AppLanguage.bengali: 'সম্পন্ন',
  },
};
