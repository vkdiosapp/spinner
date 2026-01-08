import 'package:shared_preferences/shared_preferences.dart';

class SoundVibrationSettings {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _adsEnabledKey = 'ads_enabled';
  
  static bool _soundEnabled = true;
  static bool _vibrationEnabled = true;
  static bool _adsEnabled = true; // Ads enabled by default
  static bool _initialized = false;

  // Initialize settings from shared preferences
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
      _vibrationEnabled = prefs.getBool(_vibrationEnabledKey) ?? true;
      _adsEnabled = prefs.getBool(_adsEnabledKey) ?? true;
      _initialized = true;
    } catch (e) {
      // If initialization fails, use defaults
      _soundEnabled = true;
      _vibrationEnabled = true;
      _initialized = true;
    }
  }

  // Get sound enabled state
  static bool get soundEnabled => _soundEnabled;

  // Get vibration enabled state
  static bool get vibrationEnabled => _vibrationEnabled;

  // Get ads enabled state
  static bool get adsEnabled => _adsEnabled;

  // Toggle sound
  static Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, _soundEnabled);
  }

  // Toggle vibration
  static Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, _vibrationEnabled);
  }

  // Toggle ads
  static Future<void> toggleAds() async {
    _adsEnabled = !_adsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsEnabledKey, _adsEnabled);
  }

  // Toggle both (for single button)
  static Future<void> toggleBoth() async {
    _soundEnabled = !_soundEnabled;
    _vibrationEnabled = !_vibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, _soundEnabled);
    await prefs.setBool(_vibrationEnabledKey, _vibrationEnabled);
  }
}

