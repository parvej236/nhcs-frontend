import 'app_language.dart';
import 'translations/auth_translations.dart';
import 'translations/patient_translations.dart';
import 'translations/doctor_translations.dart';
import 'translations/hospital_translations.dart';
import 'translations/common_translations.dart';

/// Central multilingual translation utility.
///
/// This is intentionally dependency-free (no code-gen, no `.arb` tooling) so it
/// can be extended by simply adding a key to [_entries]. Look up a string with
/// [t] (or by calling the instance directly, e.g. `tr('nav_home')`).
///
/// To add a new language:
///   1. add a value to [AppLanguage],
///   2. add that language's string to each entry map below.
///
/// A missing translation gracefully falls back to English, and a missing key
/// falls back to the key itself (so nothing ever renders blank).
class AppTranslations {
  final AppLanguage language;

  const AppTranslations(this.language);

  /// Translates [key] into the active [language].
  String t(String key) {
    final entry = _entries[key];
    if (entry == null) return key; // unknown key -> show key (dev aid)
    return entry[language] ?? entry[AppLanguage.english] ?? key;
  }

  /// Sugar so widgets can write `tr('key')` instead of `tr.t('key')`.
  String call(String key) => t(key);

  /// All translatable strings, composed from the public/marketing core map
  /// below plus the per-feature maps (login, patient, doctor, hospital, and
  /// shared common). Splitting by feature keeps each area independently
  /// editable. Later spreads override earlier ones on key collision, but keys
  /// are namespaced by feature to avoid that.
  static final Map<String, Map<AppLanguage, String>> _entries = {
    ..._coreEntries,
    ...commonTranslations,
    ...authTranslations,
    ...patientTranslations,
    ...doctorTranslations,
    ...hospitalTranslations,
  };

  /// Public marketing-site + shared menu strings (authored inline here).
  ///
  /// NOTE on the demo content: to make the translation switch *visibly*
  /// obvious, strings that are authored in English carry a Bengali counterpart,
  /// and strings authored in Bengali (the success stories / testimonials) carry
  /// an English counterpart — so flipping the language genuinely swaps the
  /// language of the whole dashboard in both directions.
  static const Map<String, Map<AppLanguage, String>> _coreEntries = {
    // --- Language switcher ---------------------------------------------------
    'language': {
      AppLanguage.english: 'Language',
      AppLanguage.bengali: 'ভাষা',
    },
    'language_english': {
      AppLanguage.english: 'English',
      AppLanguage.bengali: 'ইংরেজি',
    },
    'language_bengali': {
      AppLanguage.english: 'Bengali',
      AppLanguage.bengali: 'বাংলা',
    },

    // --- Header nav ----------------------------------------------------------
    'nav_home': {
      AppLanguage.english: 'Home',
      AppLanguage.bengali: 'হোম',
    },
    'nav_vitals': {
      AppLanguage.english: 'Risk Analyzer',
      AppLanguage.bengali: 'ঝুঁকি বিশ্লেষক',
    },
    'nav_queue': {
      AppLanguage.english: 'Specialists & Queue',
      AppLanguage.bengali: 'বিশেষজ্ঞ ও সারি',
    },
    'nav_blood': {
      AppLanguage.english: 'Emergency Blood',
      AppLanguage.bengali: 'জরুরি রক্ত',
    },
    'nav_blog': {
      AppLanguage.english: 'Health Blog',
      AppLanguage.bengali: 'স্বাস্থ্য ব্লগ',
    },
    'login_portal': {
      AppLanguage.english: 'Login Portal',
      AppLanguage.bengali: 'লগইন পোর্টাল',
    },
    'menu_dashboard': {
      AppLanguage.english: 'Dashboard',
      AppLanguage.bengali: 'ড্যাশবোর্ড',
    },
    'menu_timeline': {
      AppLanguage.english: 'Health Timeline',
      AppLanguage.bengali: 'হেলথ টাইমলাইন',
    },
    'menu_appointments': {
      AppLanguage.english: 'Appointments',
      AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট',
    },
    'menu_vault': {
      AppLanguage.english: 'Medical Vault',
      AppLanguage.bengali: 'মেডিকেল ভল্ট',
    },
    'menu_profile': {
      AppLanguage.english: 'My Profile',
      AppLanguage.bengali: 'আমার প্রোফাইল',
    },
    'menu_healthcare_ai': {
      AppLanguage.english: 'Healthcare AI',
      AppLanguage.bengali: 'এআই স্বাস্থ্যসেবা',
    },
    'menu_blood_donation': {
      AppLanguage.english: 'Blood Donation',
      AppLanguage.bengali: 'রক্তদান',
    },
    'menu_clinical_workspace': {
      AppLanguage.english: 'Clinical Workspace',
      AppLanguage.bengali: 'ক্লিনিক্যাল ওয়ার্কস্পেস',
    },
    'menu_report_review': {
      AppLanguage.english: 'Report Review',
      AppLanguage.bengali: 'রিপোর্ট পর্যালোচনা',
    },
    'menu_schedule': {
      AppLanguage.english: 'My Schedule',
      AppLanguage.bengali: 'আমার সময়সূচী',
    },
    'menu_command_center': {
      AppLanguage.english: 'Command Center',
      AppLanguage.bengali: 'কন্ডিশনাল কমান্ড সেন্টার',
    },
    'menu_appointment_approvals': {
      AppLanguage.english: 'Appointment Approvals',
      AppLanguage.bengali: 'অ্যাপয়েন্টমেন্ট অনুমোদন',
    },
    'menu_laboratory': {
      AppLanguage.english: 'Laboratory',
      AppLanguage.bengali: 'ল্যাবরেটরি',
    },
    'menu_sign_out': {
      AppLanguage.english: 'Sign Out',
      AppLanguage.bengali: 'সাইন আউট',
    },
    'portal_doctor': {
      AppLanguage.english: 'Doctor Portal',
      AppLanguage.bengali: 'ডাক্তার পোর্টাল',
    },
    'portal_hospital': {
      AppLanguage.english: 'Hospital Authority',
      AppLanguage.bengali: 'হাসপাতাল কর্তৃপক্ষ',
    },
    'portal_patient': {
      AppLanguage.english: 'Patient Portal',
      AppLanguage.bengali: 'রোগী পোর্টাল',
    },

    // --- Hero ----------------------------------------------------------------
    'hero_badge': {
      AppLanguage.english: 'Real-time Clinical Sync Engine Active',
      AppLanguage.bengali: 'রিয়েল-টাইম ক্লিনিক্যাল সিঙ্ক ইঞ্জিন সক্রিয়',
    },
    'hero_title_line1': {
      AppLanguage.english: 'Smart Health Hub:',
      AppLanguage.bengali: 'স্মার্ট হেলথ হাব:',
    },
    'hero_title_highlight': {
      AppLanguage.english: 'Universal Digital Health',
      AppLanguage.bengali: 'সর্বজনীন ডিজিটাল স্বাস্থ্য',
    },
    'hero_title_tail': {
      AppLanguage.english: ' for Everyone',
      AppLanguage.bengali: ' সবার জন্য',
    },
    'hero_subtitle': {
      AppLanguage.english:
          'An AI-powered central medical registry providing real-time vital '
          'analysis, doctor queue tracking, and secure digital prescription access.',
      AppLanguage.bengali:
          'একটি এআই-চালিত কেন্দ্রীয় চিকিৎসা নিবন্ধন যা রিয়েল-টাইম ভাইটাল '
          'বিশ্লেষণ, ডাক্তারের সারি ট্র্যাকিং এবং নিরাপদ ডিজিটাল প্রেসক্রিপশন অ্যাক্সেস প্রদান করে।',
    },
    'hero_btn_vitals': {
      AppLanguage.english: 'Run Vitals Check',
      AppLanguage.bengali: 'ভাইটালস চেক করুন',
    },
    'hero_btn_search': {
      AppLanguage.english: 'Search for Doctor',
      AppLanguage.bengali: 'ডাক্তার খুঁজুন',
    },

    // --- Live tracker card ---------------------------------------------------
    'tracker_title': {
      AppLanguage.english: 'NHCS Live Tracker',
      AppLanguage.bengali: 'NHCS লাইভ ট্র্যাকার',
    },
    'tracker_registries': {
      AppLanguage.english: 'Active Registries',
      AppLanguage.bengali: 'সক্রিয় নিবন্ধন',
    },
    'tracker_hospitals': {
      AppLanguage.english: 'Hospitals Affiliated',
      AppLanguage.bengali: 'অন্তর্ভুক্ত হাসপাতাল',
    },
    'tracker_specialists': {
      AppLanguage.english: 'Specialists Online',
      AppLanguage.bengali: 'অনলাইন বিশেষজ্ঞ',
    },
    'tracker_patients': {
      AppLanguage.english: 'Patients',
      AppLanguage.bengali: 'রোগী',
    },
    'tracker_centres': {
      AppLanguage.english: 'Centres',
      AppLanguage.bengali: 'কেন্দ্র',
    },
    'tracker_doctors': {
      AppLanguage.english: 'Doctors',
      AppLanguage.bengali: 'ডাক্তার',
    },

    // --- Stat row ------------------------------------------------------------
    'stat_patients': {
      AppLanguage.english: 'Patients Seeded',
      AppLanguage.bengali: 'নিবন্ধিত রোগী',
    },
    'stat_specialists': {
      AppLanguage.english: 'Verified Specialists',
      AppLanguage.bengali: 'যাচাইকৃত বিশেষজ্ঞ',
    },
    'stat_facilities': {
      AppLanguage.english: 'Active Medical Facilities',
      AppLanguage.bengali: 'সক্রিয় চিকিৎসা কেন্দ্র',
    },

    // --- Section titles ------------------------------------------------------
    'section_vitals_analyzer': {
      AppLanguage.english: 'Clinical Vitals Risk Analyzer',
      AppLanguage.bengali: 'ক্লিনিক্যাল ভাইটালস ঝুঁকি বিশ্লেষক',
    },
    'section_donor_availability': {
      AppLanguage.english: 'Live Donor Availability',
      AppLanguage.bengali: 'লাইভ রক্তদাতার প্রাপ্যতা',
    },
    'donor_subtitle': {
      AppLanguage.english: 'Real-time predictions for hospital hubs',
      AppLanguage.bengali: 'হাসপাতাল হাবের জন্য রিয়েল-টাইম পূর্বাভাস',
    },
    'section_solutions': {
      AppLanguage.english: 'Our Solutions',
      AppLanguage.bengali: 'আমাদের সমাধান',
    },
    'section_success': {
      AppLanguage.english: 'Success Stories',
      AppLanguage.bengali: 'সফলতার গল্প',
    },
    'section_blog': {
      AppLanguage.english: 'NHCS AI Health Insights (Blog Hub)',
      AppLanguage.bengali: 'NHCS এআই স্বাস্থ্য অন্তর্দৃষ্টি (ব্লগ হাব)',
    },
    'view_details': {
      AppLanguage.english: 'View Details',
      AppLanguage.bengali: 'বিস্তারিত দেখুন',
    },

    // --- Our Solutions cards -------------------------------------------------
    'sol1_title': {
      AppLanguage.english: 'Digital Vitals Risk Analyzer',
      AppLanguage.bengali: 'ডিজিটাল ভাইটালস ঝুঁকি বিশ্লেষক',
    },
    'sol1_desc': {
      AppLanguage.english:
          'AI-powered immediate cardiac & diabetic symptom analysis and severity warnings.',
      AppLanguage.bengali:
          'এআই-চালিত তাৎক্ষণিক হৃদরোগ ও ডায়াবেটিক উপসর্গ বিশ্লেষণ এবং তীব্রতার সতর্কতা।',
    },
    'sol2_title': {
      AppLanguage.english: 'Universal Health Card ID',
      AppLanguage.bengali: 'সর্বজনীন স্বাস্থ্য কার্ড আইডি',
    },
    'sol2_desc': {
      AppLanguage.english:
          'One-click patient health profile & emergency ICE contact QR code registry.',
      AppLanguage.bengali:
          'এক ক্লিকে রোগীর স্বাস্থ্য প্রোফাইল ও জরুরি ICE যোগাযোগের QR কোড নিবন্ধন।',
    },
    'sol3_title': {
      AppLanguage.english: 'Active Doctor Queue Sync',
      AppLanguage.bengali: 'সক্রিয় ডাক্তার সারি সিঙ্ক',
    },
    'sol3_desc': {
      AppLanguage.english:
          'Links hospital arrivals check-in directly to specialist clinical workspaces.',
      AppLanguage.bengali:
          'হাসপাতালে আগত রোগীর চেক-ইন সরাসরি বিশেষজ্ঞের ক্লিনিক্যাল ওয়ার্কস্পেসে যুক্ত করে।',
    },
    'learn_more': {
      AppLanguage.english: 'Learn More  ➔',
      AppLanguage.bengali: 'আরও জানুন  ➔',
    },

    // --- Success stories (authored in Bengali -> English counterpart) --------
    'story1_title': {
      AppLanguage.english: 'Emergency Blood Support (Masud Rana - CUET, Raojan)',
      AppLanguage.bengali: 'জরুরি রক্ত সহায়তা (মাসুদ রানা - চুয়েট, রাউজান)',
    },
    'story1_body': {
      AppLanguage.english:
          '"Masud Rana from CUET, Raojan, Chittagong urgently needed O+ blood. '
          'Through the NHCS AI blood-matching system, a local Chittagong donor '
          'was found within minutes and the donation was completed successfully. '
          'It was truly a life-saving experience!"',
      AppLanguage.bengali:
          '"চুয়েট, রাউজান, চট্টগ্রামের মাসুদ রানা ভাইয়ের ও+ রক্তের জরুরি প্রয়োজন ছিল। '
          'NHCS AI ব্লাড ম্যাচিং সিস্টেমের মাধ্যমে মাত্র কয়েক মিনিটে চট্টগ্রামের স্থানীয় '
          'একজন দাতা খুঁজে পাওয়া যায় এবং সফলভাবে রক্ত প্রদান সম্পন্ন হয়। এটি সত্যিই একটি '
          'জীবন রক্ষাকারী অভিজ্ঞতা!"',
    },
    'story2_title': {
      AppLanguage.english: 'Easy Doctor Appointment (Sowkot Bhuiyan)',
      AppLanguage.bengali: 'সহজ ডাক্তার অ্যাপয়েন্টমেন্ট (শওকত ভূঁইয়া)',
    },
    'story2_body': {
      AppLanguage.english:
          '"As soon as I searched by typing my symptoms, the NHCS AI assistant '
          'directly found the right doctor for me. I did not have to go through '
          'any hassle of finding a doctor, and booked the appointment very '
          'easily. Thank you NHCS!"',
      AppLanguage.bengali:
          '"আমি আমার রোগের লক্ষণ লিখে সার্চ করতেই NHCS এর এআই অ্যাসিস্ট্যান্ট সরাসরি '
          'সঠিক ডক্টর খুঁজে দিয়েছে। ডক্টর খোঁজার কোনো ঝামেলাই পোহাতে হয়নি, খুব সহজেই '
          'অ্যাপয়েন্টমেন্ট বুকিং করতে পেরেছি। ধন্যবাদ NHCS!"',
    },
  };
}
