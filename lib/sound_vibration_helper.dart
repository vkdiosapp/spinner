import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'sound_vibration_settings.dart';

class SoundVibrationHelper {
  static Timer? _soundTimer;
  static Timer? _vibrationTimer;
  static bool _isPlayingContinuous = false;
  static double _currentSpeed = 1.0; // 0.0 to 1.0, where 1.0 is fastest
  static DateTime? _lastSoundTime;
  static DateTime? _lastVibrationTime;

  // Play continuous sound while spinner is spinning with dynamic speed
  static void startContinuousSound() {
    // Ensure settings are initialized (fire and forget for non-blocking)
    SoundVibrationSettings.initialize();
    
    // Stop any existing timers
    stopContinuousSound();

    _isPlayingContinuous = true;
    _currentSpeed = 1.0; // Start at maximum speed
    _lastSoundTime = DateTime.now();
    _lastVibrationTime = DateTime.now();

    // Play sound immediately
    _playSpinSound();
    _playSpinVibration();

    // Use a fast timer that checks speed and plays accordingly
    _soundTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPlayingContinuous) {
        timer.cancel();
        return;
      }
      
      // Check if sound is enabled before playing
      if (!SoundVibrationSettings.soundEnabled) {
        // Stop if sound is disabled
        timer.cancel();
        _isPlayingContinuous = false;
        return;
      }

      // Calculate interval based on speed (faster speed = shorter interval)
      // Speed 1.0 (fast) = 50ms, Speed 0.1 (slow) = 500ms
      final intervalMs = 50 + (500 - 50) * (1.0 - _currentSpeed);
      final now = DateTime.now();
      
      if (_lastSoundTime != null) {
        final elapsed = now.difference(_lastSoundTime!).inMilliseconds;
        if (elapsed >= intervalMs) {
          _playSpinSound();
          _lastSoundTime = now;
        }
      } else {
        _playSpinSound();
        _lastSoundTime = now;
      }
    });

    // Vibration timer
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPlayingContinuous) {
        timer.cancel();
        return;
      }
      
      // Check if vibration is enabled before playing
      if (!SoundVibrationSettings.vibrationEnabled) {
        return;
      }

      // Calculate interval based on speed (faster speed = shorter interval)
      final intervalMs = 50 + (500 - 50) * (1.0 - _currentSpeed);
      final now = DateTime.now();
      
      if (_lastVibrationTime != null) {
        final elapsed = now.difference(_lastVibrationTime!).inMilliseconds;
        if (elapsed >= intervalMs) {
          _playSpinVibration();
          _lastVibrationTime = now;
        }
      } else {
        _playSpinVibration();
        _lastVibrationTime = now;
      }
    });
  }

  // Update the speed of sound/vibration (0.0 to 1.0, where 1.0 is fastest)
  static void updateSpeed(double speed) {
    _currentSpeed = speed.clamp(0.0, 1.0);
  }

  // Stop continuous sound
  static void stopContinuousSound() {
    _isPlayingContinuous = false;
    _soundTimer?.cancel();
    _soundTimer = null;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    _currentSpeed = 1.0;
    _lastSoundTime = null;
    _lastVibrationTime = null;
  }

  // Play a single spin vibration
  static void _playSpinVibration() {
    if (!SoundVibrationSettings.vibrationEnabled) {
      return;
    }

    try {
      // Use haptic feedback with intensity based on speed
      if (_currentSpeed > 0.7) {
        HapticFeedback.mediumImpact();
      } else if (_currentSpeed > 0.3) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      // Ignore vibration errors
    }
  }

  // Play a single spin sound
  static void _playSpinSound() {
    if (!SoundVibrationSettings.soundEnabled) {
      return;
    }

    try {
      // Use click sound for continuous playback (less jarring than alert)
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      try {
        // Fallback to haptic feedback
        HapticFeedback.selectionClick();
      } catch (e2) {
        // Ignore sound errors
      }
    }
  }

  // Play sound and vibration when spinner spins (initial trigger)
  static Future<void> playSpinEffects() async {
    // Ensure settings are initialized
    await SoundVibrationSettings.initialize();
    
    if (!SoundVibrationSettings.soundEnabled && !SoundVibrationSettings.vibrationEnabled) {
      return;
    }

    // Play system sound if enabled - maximum capability
    if (SoundVibrationSettings.soundEnabled) {
      try {
        // Use alert sound (louder) for maximum capability
        SystemSound.play(SystemSoundType.alert);
        // Also use haptic feedback for additional audio feedback on iOS
        HapticFeedback.mediumImpact();
      } catch (e) {
        try {
          // Fallback to click sound
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
        } catch (e2) {
          try {
            // Final fallback to haptic only
            HapticFeedback.mediumImpact();
          } catch (e3) {
            // Ignore sound errors
          }
        }
      }
    }

    // Vibrate if enabled - maximum capability
    if (SoundVibrationSettings.vibrationEnabled) {
      try {
        // Check if device has vibrator
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          // Use longer duration for maximum vibration
          await Vibration.vibrate(duration: 150);
          // Also add haptic feedback for additional strength
          HapticFeedback.mediumImpact();
        } else {
          // Fallback to strong haptic feedback if vibration package doesn't work
          HapticFeedback.heavyImpact();
        }
      } catch (e) {
        // Fallback to haptic feedback
        try {
          HapticFeedback.heavyImpact();
        } catch (e2) {
          try {
            HapticFeedback.mediumImpact();
          } catch (e3) {
            // Ignore vibration errors
          }
        }
      }
    }
  }
}

