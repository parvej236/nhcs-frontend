import '../app_language.dart';

/// Shared strings used across multiple feature areas (buttons, statuses,
/// generic labels). Keep keys prefixed with `common_` to avoid collisions.
const Map<String, Map<AppLanguage, String>> commonTranslations = {
  'common_save': {
    AppLanguage.english: 'Save',
    AppLanguage.bengali: 'সংরক্ষণ',
  },
  'common_cancel': {
    AppLanguage.english: 'Cancel',
    AppLanguage.bengali: 'বাতিল',
  },
  'common_close': {
    AppLanguage.english: 'Close',
    AppLanguage.bengali: 'বন্ধ করুন',
  },
  'common_confirm': {
    AppLanguage.english: 'Confirm',
    AppLanguage.bengali: 'নিশ্চিত করুন',
  },
  'common_search': {
    AppLanguage.english: 'Search',
    AppLanguage.bengali: 'অনুসন্ধান',
  },
  'common_loading': {
    AppLanguage.english: 'Loading...',
    AppLanguage.bengali: 'লোড হচ্ছে...',
  },
  'common_view_all': {
    AppLanguage.english: 'View All',
    AppLanguage.bengali: 'সব দেখুন',
  },
  'common_status': {
    AppLanguage.english: 'Status',
    AppLanguage.bengali: 'অবস্থা',
  },
  'common_actions': {
    AppLanguage.english: 'Actions',
    AppLanguage.bengali: 'ক্রিয়াকলাপ',
  },
};
