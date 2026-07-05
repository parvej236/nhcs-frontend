import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_language.dart';
import '../l10n/app_translations.dart';

/// Persisted app language. Defaults to [AppLanguage.english] and is restored
/// from / saved to shared_preferences so the selection is remembered across
/// launches. Mirrors the pattern used by `ThemeModeNotifier`.
class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _prefsKey = 'app_language';

  LanguageNotifier() : super(AppLanguage.english) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppLanguage.fromCode(prefs.getString(_prefsKey));
  }

  /// Cycles to the next language (English ⇄ Bengali) — used by a one-tap toggle.
  Future<void> toggle() => setLanguage(state.next);

  /// Sets an explicit [language] and persists it.
  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}

/// The currently selected app language, applied across the whole system.
final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

/// A ready-to-use [AppTranslations] bound to the active language. Watch this in
/// widgets and call `tr('some_key')` to get the localized string; it rebuilds
/// automatically whenever the language changes.
final translationsProvider = Provider<AppTranslations>((ref) {
  return AppTranslations(ref.watch(languageProvider));
});
