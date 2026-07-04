import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted app theme mode. Defaults to [ThemeMode.dark] (dark-first design),
/// and is restored from / saved to shared_preferences.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefsKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.dark) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode == ThemeMode.light ? 'light' : 'dark');
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
