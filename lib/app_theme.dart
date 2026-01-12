import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const String _themeKey = 'app_theme';
  static const String _darkTheme = 'dark';
  static const String _lightTheme = 'light';

  // Dark theme colors
  static const Color darkBackground = Color(0xFF2D2D44);
  static const Color darkCardBackground = Color(0xFF3D3D5C);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightCardBackground = Colors.white;
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);

  static bool _isDarkTheme = true;
  static final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(true);

  /// Initialize theme from shared preferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themeKey) ?? _darkTheme;
    _isDarkTheme = theme == _darkTheme;
    themeNotifier.value = _isDarkTheme;
  }

  /// Get current theme mode
  static bool get isDarkTheme => _isDarkTheme;

  /// Toggle theme
  static Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    themeNotifier.value = _isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _isDarkTheme ? _darkTheme : _lightTheme);
  }

  /// Set theme explicitly
  static Future<void> setTheme(bool isDark) async {
    _isDarkTheme = isDark;
    themeNotifier.value = _isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _isDarkTheme ? _darkTheme : _lightTheme);
  }

  /// Get background color based on current theme
  static Color get backgroundColor => _isDarkTheme ? darkBackground : lightBackground;

  /// Get card background color based on current theme
  static Color get cardBackgroundColor => _isDarkTheme ? darkCardBackground : lightCardBackground;

  /// Get text color based on current theme
  static Color get textColor => _isDarkTheme ? darkText : lightText;

  /// Get secondary text color based on current theme
  static Color get textSecondaryColor => _isDarkTheme ? darkTextSecondary : lightTextSecondary;
}
