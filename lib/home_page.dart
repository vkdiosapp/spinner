import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'spinner_config_page.dart';
import 'multiplayer_config_page.dart';
// import 'dice_level_page.dart'; // Commented out - will add later
import 'sound_vibration_settings.dart';
import 'language_selection_page.dart';
import 'app_localizations_helper.dart';
import 'app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _adsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Theme toggle method - commented out for future use
  // Future<void> _toggleTheme() async {
  //   await AppTheme.toggleTheme();
  //   // Provide feedback when toggled
  //   try {
  //     SystemSound.play(SystemSoundType.click);
  //     HapticFeedback.mediumImpact();
  //   } catch (e) {
  //     // Ignore errors
  //   }
  // }

  Future<void> _loadSettings() async {
    await SoundVibrationSettings.initialize();
    setState(() {
      _soundEnabled = SoundVibrationSettings.soundEnabled;
      _vibrationEnabled = SoundVibrationSettings.vibrationEnabled;
      _adsEnabled = SoundVibrationSettings.adsEnabled;
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

  Future<void> _toggleAds() async {
    await SoundVibrationSettings.toggleAds();
    setState(() {
      _adsEnabled = SoundVibrationSettings.adsEnabled;
    });
    // Provide feedback when toggled
    try {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);

    final items = [
      {
        'title': l10n.randomPicker,
        'description': l10n.randomPickerDescription,
        'icon': Icons.shuffle,
        'color': const Color(0xFF6C5CE7),
        'route': const SpinnerConfigPage(),
      },
      {
        'title': l10n.multiplayer,
        'description': l10n.multiplayerDescription,
        'icon': Icons.people,
        'color': const Color(0xFFFF6B35),
        'route': const MultiplayerConfigPage(),
      },
      // {
      //   'title': l10n.dice,
      //   'description': l10n.diceDescription,
      //   'icon': Icons.casino,
      //   'color': const Color(0xFF00D2FF),
      //   'route': const DiceLevelPage(),
      // },
      {
        'title': l10n.mathSpinner,
        'description': l10n.mathSpinnerDescription,
        'icon': Icons.calculate,
        'color': const Color(0xFF9B59B6),
        'route': const MultiplayerConfigPage(isMathSpinner: true),
      },
      {
        'title': l10n.whoFirst,
        'description': l10n.whoFirstDescription,
        'icon': Icons.timer,
        'color': const Color(0xFF00B894),
        'route': const MultiplayerConfigPage(isWhoFirst: true),
      },
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                // Language icon - top left
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7),
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
                      icon: const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageSelectionPage(),
                          ),
                        );
                        // Reload page if language changed
                        if (result == true) {
                          setState(() {});
                        }
                      },
                      tooltip: l10n.changeLanguage,
                    ),
                  ),
                ),
                // Theme toggle button - top right (above sound/vibration buttons)
                // Commented out - will use later
                // Positioned(
                //   top: 16,
                //   right: 16,
                //   child: Container(
                //     width: 48,
                //     height: 48,
                //     decoration: BoxDecoration(
                //       color: const Color(0xFF6C5CE7),
                //       shape: BoxShape.circle,
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.3),
                //           blurRadius: 8,
                //           offset: const Offset(0, 2),
                //         ),
                //       ],
                //     ),
                //     child: ValueListenableBuilder<bool>(
                //       valueListenable: AppTheme.themeNotifier,
                //       builder: (context, isDark, _) {
                //         return IconButton(
                //           icon: Icon(
                //             isDark ? Icons.light_mode : Icons.dark_mode,
                //             color: Colors.white,
                //             size: 24,
                //           ),
                //           onPressed: () {}, // _toggleTheme - commented out
                //           tooltip: isDark ? 'Light Theme' : 'Dark Theme',
                //         );
                //       },
                //     ),
                //   ),
                // ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape =
                        constraints.maxWidth > constraints.maxHeight;
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
                              Text(
                                l10n.appTitle,
                                style: TextStyle(
                                  color: AppTheme.textColor,
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
                                      color: AppTheme.cardBackgroundColor,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  item['route'] as Widget,
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: itemSize * 0.35,
                                                height: itemSize * 0.35,
                                                decoration: BoxDecoration(
                                                  color: item['color'] as Color,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  item['icon'] as IconData,
                                                  color: AppTheme.textColor,
                                                  size: itemSize * 0.2,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                item['title'] as String,
                                                style: TextStyle(
                                                  color: AppTheme.textColor,
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
                                                  color: AppTheme
                                                      .textSecondaryColor,
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
                // Sound and Vibration toggle buttons - below theme button
                Positioned(
                  top: 72,
                  right: 16,
                  child: IgnorePointer(
                    ignoring: false,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ads toggle button
                          Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: _adsEnabled
                                  ? const Color(0xFF6C5CE7)
                                  : AppTheme.cardBackgroundColor,
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
                                _adsEnabled
                                    ? Icons.ads_click
                                    : Icons.ads_click_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _toggleAds,
                              tooltip: _adsEnabled ? l10n.adsOn : l10n.adsOff,
                            ),
                          ),
                          // Vibration toggle button
                          Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: _vibrationEnabled
                                  ? const Color(0xFF6C5CE7)
                                  : AppTheme.cardBackgroundColor,
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
                                _vibrationEnabled
                                    ? Icons.vibration
                                    : Icons.vibration_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _toggleVibration,
                              tooltip: _vibrationEnabled
                                  ? l10n.vibrationOn
                                  : l10n.vibrationOff,
                            ),
                          ),
                          // Sound toggle button
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _soundEnabled
                                  ? const Color(0xFF6C5CE7)
                                  : AppTheme.cardBackgroundColor,
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
                                _soundEnabled
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.white,
                              ),
                              onPressed: _toggleSound,
                              tooltip: _soundEnabled
                                  ? l10n.soundOn
                                  : l10n.soundOff,
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
      },
    );
  }
}
