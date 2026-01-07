import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'spinner_config_page.dart';
import 'multiplayer_config_page.dart';
import 'dice_page.dart';
import 'truth_dare_config_page.dart';
import 'sound_vibration_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await SoundVibrationSettings.initialize();
    setState(() {
      _soundEnabled = SoundVibrationSettings.soundEnabled;
      _vibrationEnabled = SoundVibrationSettings.vibrationEnabled;
    });
  }

  Future<void> _toggleSound() async {
    await SoundVibrationSettings.toggleSound();
    setState(() {
      _soundEnabled = SoundVibrationSettings.soundEnabled;
    });
    // Play maximum sound feedback when toggled
    try {
      // Use alert sound (louder) for maximum capability
      SystemSound.play(SystemSoundType.alert);
      // Also use strong haptic feedback for additional feedback
      HapticFeedback.heavyImpact();
    } catch (e) {
      try {
        // Fallback to click sound
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.mediumImpact();
      } catch (e2) {
        try {
          // Final fallback to haptic only
          HapticFeedback.mediumImpact();
        } catch (e3) {
          // Ignore errors
        }
      }
    }
  }

  Future<void> _toggleVibration() async {
    await SoundVibrationSettings.toggleVibration();
    setState(() {
      _vibrationEnabled = SoundVibrationSettings.vibrationEnabled;
    });
    // Provide maximum vibration feedback when toggled
    try {
      // Check if device has vibrator
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Use longer duration for maximum vibration
        await Vibration.vibrate(duration: 200);
        // Also add haptic feedback for additional strength
        HapticFeedback.heavyImpact();
      } else {
        // Fallback to strongest haptic feedback
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Fallback to strongest haptic feedback
      try {
        HapticFeedback.heavyImpact();
      } catch (e2) {
        try {
          HapticFeedback.mediumImpact();
        } catch (e3) {
          // Ignore errors
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Random Picker',
        'description': 'Create a custom spinner with your own items',
        'icon': Icons.shuffle,
        'color': const Color(0xFF6C5CE7),
        'route': const SpinnerConfigPage(),
      },
      {
        'title': 'Multiplayer',
        'description': 'Play with friends and compete in rounds',
        'icon': Icons.people,
        'color': const Color(0xFFFF6B35),
        'route': const MultiplayerConfigPage(),
      },
      {
        'title': 'Dice',
        'description': 'Roll two dice and see the total',
        'icon': Icons.casino,
        'color': const Color(0xFF00D2FF),
        'route': const DicePage(),
      },
      {
        'title': 'Truth & Dare',
        'description': 'Play truth and dare with friends',
        'icon': Icons.celebration,
        'color': const Color(0xFFFF1493),
        'route': const TruthDareConfigPage(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;
                final itemSize = isLandscape
                    ? constraints.maxWidth / 5
                    : constraints.maxWidth / 2.5;
                
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Spinner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: items.map((item) {
                          return SizedBox(
                            width: itemSize,
                            height: itemSize,
                            child: Card(
                              color: const Color(0xFF3D3D5C),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => item['route'] as Widget,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: itemSize * 0.35,
                                        height: itemSize * 0.35,
                                        decoration: BoxDecoration(
                                          color: item['color'] as Color,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          item['icon'] as IconData,
                                          color: Colors.white,
                                          size: itemSize * 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['title'] as String,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: itemSize * 0.08,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['description'] as String,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: itemSize * 0.055,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Sound and Vibration toggle buttons - top right (above all UI)
            Positioned(
              top: 16,
              right: 16,
              child: IgnorePointer(
                ignoring: false,
                child: Material(
                  color: Colors.transparent,
                  elevation: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Vibration toggle button
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: _vibrationEnabled 
                              ? const Color(0xFF6C5CE7)
                              : const Color(0xFF3D3D5C),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _vibrationEnabled ? Icons.vibration : Icons.vibration_outlined,
                            color: Colors.white,
                          ),
                          onPressed: _toggleVibration,
                          tooltip: _vibrationEnabled ? 'Vibration On' : 'Vibration Off',
                        ),
                      ),
                      // Sound toggle button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _soundEnabled 
                              ? const Color(0xFF6C5CE7)
                              : const Color(0xFF3D3D5C),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _soundEnabled ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                          ),
                          onPressed: _toggleSound,
                          tooltip: _soundEnabled ? 'Sound On' : 'Sound Off',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

