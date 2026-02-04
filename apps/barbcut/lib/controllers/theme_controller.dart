import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _themePreferenceKey = 'app_theme_mode';
  static const String _genderModePreferenceKey = 'app_gender_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isFemaleVersion = false;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get isFemaleVersion => _isFemaleVersion;

  /// Initialize theme controller and load saved preferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadThemePreference();
    await _loadGenderPreference();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final savedTheme = _prefs?.getString(_themePreferenceKey) ?? 'light';
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Load gender mode preference from SharedPreferences
  Future<void> _loadGenderPreference() async {
    _isFemaleVersion = _prefs?.getBool(_genderModePreferenceKey) ?? false;
    notifyListeners();
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    final themeString = _themeMode == ThemeMode.dark ? 'dark' : 'light';
    await _prefs?.setString(_themePreferenceKey, themeString);
  }

  /// Save gender mode preference to SharedPreferences
  Future<void> _saveGenderPreference() async {
    await _prefs?.setBool(_genderModePreferenceKey, _isFemaleVersion);
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

  /// Toggle between male and female version
  void toggleFemaleVersion(bool enabled) {
    if (enabled == _isFemaleVersion) return;
    _isFemaleVersion = enabled;
    notifyListeners();
    // Save preference asynchronously without waiting
    _saveGenderPreference();
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
