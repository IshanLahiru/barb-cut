import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _themePreferenceKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Initialize theme controller and load saved theme preference
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadThemePreference();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final savedTheme = _prefs?.getString(_themePreferenceKey) ?? 'light';
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    final themeString = _themeMode == ThemeMode.dark ? 'dark' : 'light';
    await _prefs?.setString(_themePreferenceKey, themeString);
  }

  /// Toggle between light and dark mode (synchronous wrapper)
  void toggleDarkMode(bool enabled) {
    final newMode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (newMode == _themeMode) return;
    _themeMode = newMode;
    notifyListeners();
    // Save preference asynchronously without waiting
    _saveThemePreference();
  }

  /// Explicitly set theme mode
  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    // Save preference asynchronously without waiting
    _saveThemePreference();
  }
}
