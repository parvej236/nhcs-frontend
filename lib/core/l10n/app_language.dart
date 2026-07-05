/// Supported UI languages for the app. The [code] is what gets persisted to
/// shared_preferences; [label] is the human-readable name shown in the
/// language switcher, and [short] is the compact badge shown in the header pill.
enum AppLanguage {
  english('en', 'English', 'EN'),
  bengali('bn', 'বাংলা', 'বাং');

  const AppLanguage(this.code, this.label, this.short);

  /// Persisted language code (e.g. `en`, `bn`).
  final String code;

  /// Native display name of the language.
  final String label;

  /// Two/short-character badge for compact UI (header pill).
  final String short;

  /// Resolves a persisted [code] back to an [AppLanguage], defaulting to
  /// [AppLanguage.english] when unknown or null.
  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  /// The next language in a simple round-robin cycle. Handy for a one-tap
  /// toggle button (English ⇄ Bengali).
  AppLanguage get next {
    final all = AppLanguage.values;
    return all[(index + 1) % all.length];
  }
}
