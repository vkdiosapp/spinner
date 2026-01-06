import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'sound_vibration_settings.dart';

class SoundVibrationHelper {
  // Play sound and vibration when spinner spins
  static Future<void> playSpinEffects() async {
    if (!SoundVibrationSettings.soundEnabled && !SoundVibrationSettings.vibrationEnabled) {
      return;
    }

    // Play system sound if enabled
    if (SoundVibrationSettings.soundEnabled) {
      try {
        // Use system sound feedback
        HapticFeedback.mediumImpact();
      } catch (e) {
        // Ignore sound errors
      }
    }

    // Vibrate if enabled
    if (SoundVibrationSettings.vibrationEnabled) {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          // Short vibration pulse
          Vibration.vibrate(duration: 50);
        }
      } catch (e) {
        // Ignore vibration errors
      }
    }
  }
}

