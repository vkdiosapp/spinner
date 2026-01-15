import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _adsEnabled = true;
  bool _showSettingsPopup = false;
  late AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Initialize spinner animation controller
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    super.dispose();
  }

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

  // Create colorful spinner wheel
  Widget _buildSpinnerWheel(double size) {
    return AnimatedBuilder(
      animation: _spinnerController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _spinnerController.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(size, size),
            painter: ColorfulWheelPainter(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);

    // Map items to match the design
    final items = [
      {
        'title': l10n.randomPicker, // "Decision Spinner"
        'description': l10n.randomPickerDescription,
        'icon': Icons.filter_tilt_shift,
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF472B6), Color(0xFFF43F5E)], // Pink to Rose
        ),
        'route': const SpinnerConfigPage(),
      },
      {
        'title': l10n.multiplayer, // "Spin Battle"
        'description': l10n.multiplayerDescription,
        'icon': Icons.flash_on, // Lightning bolt for battle/versus mode
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60A5FA), Color(0xFF4F46E5)], // Blue to Indigo
        ),
        'route': const MultiplayerConfigPage(),
      },
      {
        'title': l10n.mathSpinner, // "Math Challenge"
        'description': l10n.mathSpinnerDescription,
        'icon': Icons.calculate,
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34D399), Color(0xFF0D9488)], // Emerald to Teal
        ),
        'route': const MultiplayerConfigPage(isMathSpinner: true),
      },
      {
        'title': l10n.whoFirst, // "Race to 10"
        'description': l10n.whoFirstDescription,
        'icon': Icons.timer,
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBBF24), Color(0xFFF97316)], // Amber to Orange
        ),
        'route': const MultiplayerConfigPage(isWhoFirst: true),
      },
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor:
              Colors.transparent, // Transparent so gradient shows through
          body: SafeArea(
            child: Stack(
              children: [
                // Main content - no scrolling, fixed layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive spinner size
                    final screenHeight = constraints.maxHeight;
                    final spinnerSize = (screenHeight * 0.35).clamp(
                      200.0,
                      280.0,
                    );

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        // Decision Hub Title
                        Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                              ).createShader(bounds),
                              child: const Text(
                                'Decision Hub',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MODE SELECTION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Spinner Wheel Section - responsive size
                        SizedBox(
                          width: spinnerSize,
                          height: spinnerSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Spinner wheel container
                              Container(
                                width: spinnerSize * 0.91,
                                height: spinnerSize * 0.91,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFBBF24,
                                    ), // Amber/Yellow
                                    width: 8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white,
                                    child: _buildSpinnerWheel(
                                      spinnerSize * 0.86,
                                    ),
                                  ),
                                ),
                              ),
                              // Red pointer at top
                              Positioned(
                                top: 0,
                                child: Container(
                                  width: 24,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444), // Red
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Center play button
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFF6366F1,
                                    ), // Primary color
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Spacing between spinner and cards
                        const SizedBox(height: 24),
                        // Game Mode Cards Grid - Always 2x2 layout using Row/Column
                        Flexible(
                          child: LayoutBuilder(
                            builder: (context, cardConstraints) {
                              // Calculate available space
                              final availableWidth =
                                  cardConstraints.maxWidth -
                                  48; // 24px padding each side
                              final availableHeight = cardConstraints.maxHeight;

                              final spacing = 16.0;

                              // Always use smaller dimension for 2x2 grid
                              final isHeightSmaller =
                                  availableHeight < availableWidth;
                              final smallerDimension = isHeightSmaller
                                  ? availableHeight
                                  : availableWidth;

                              // For 2x2 grid: 2 columns, 2 rows
                              // We need: 2 cards + 1 spacing between them
                              // cardSize = (smallerDimension - spacing) / 2
                              double cardSize =
                                  (smallerDimension - spacing) / 2;

                              // Ensure cardSize is positive and reasonable
                              if (cardSize <= 0) {
                                cardSize = 100.0; // Fallback minimum size
                              }

                              // Calculate exact width needed for 2 columns
                              final gridWidth = (2 * cardSize) + spacing;

                              // Always 2x2 grid using Row/Column
                              return Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: gridWidth,
                                    minWidth: gridWidth,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // ROW 1: Only 2 items
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: gridWidth,
                                          minWidth: gridWidth,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Item 0
                                            SizedBox(
                                              width: cardSize,
                                              height: cardSize,
                                              child: _buildGameModeCard(
                                                context,
                                                items[0]['title'] as String,
                                                items[0]['description']
                                                    as String,
                                                items[0]['icon'] as IconData,
                                                items[0]['gradient']
                                                    as Gradient,
                                                items[0]['route'] as Widget,
                                                cardSize: cardSize,
                                              ),
                                            ),
                                            SizedBox(width: spacing),
                                            // Item 1
                                            SizedBox(
                                              width: cardSize,
                                              height: cardSize,
                                              child: _buildGameModeCard(
                                                context,
                                                items[1]['title'] as String,
                                                items[1]['description']
                                                    as String,
                                                items[1]['icon'] as IconData,
                                                items[1]['gradient']
                                                    as Gradient,
                                                items[1]['route'] as Widget,
                                                cardSize: cardSize,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: spacing),
                                      // ROW 2: Only 2 items
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: gridWidth,
                                          minWidth: gridWidth,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Item 2
                                            SizedBox(
                                              width: cardSize,
                                              height: cardSize,
                                              child: _buildGameModeCard(
                                                context,
                                                items[2]['title'] as String,
                                                items[2]['description']
                                                    as String,
                                                items[2]['icon'] as IconData,
                                                items[2]['gradient']
                                                    as Gradient,
                                                items[2]['route'] as Widget,
                                                cardSize: cardSize,
                                              ),
                                            ),
                                            SizedBox(width: spacing),
                                            // Item 3
                                            SizedBox(
                                              width: cardSize,
                                              height: cardSize,
                                              child: _buildGameModeCard(
                                                context,
                                                items[3]['title'] as String,
                                                items[3]['description']
                                                    as String,
                                                items[3]['icon'] as IconData,
                                                items[3]['gradient']
                                                    as Gradient,
                                                items[3]['route'] as Widget,
                                                cardSize: cardSize,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
                // Language icon - top left (glassmorphic style)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.language,
                        color: Color(0xFF6366F1),
                        size: 20,
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
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // Settings icon button - top right (glassmorphic style)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSettingsPopup = !_showSettingsPopup;
                        });
                      },
                      tooltip: 'Settings',
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // Tap outside to close popup
                if (_showSettingsPopup)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _showSettingsPopup = false;
                        });
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                // Settings popup - top right corner
                if (_showSettingsPopup)
                  Positioned(
                    top: 64,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        // Prevent tap from closing popup when tapping inside
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Ads toggle button: DO NOT REMOVE THIS COMMENT
                              Container(
                                width: 48,
                                height: 48,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: _adsEnabled
                                      ? const Color(0xFF6366F1)
                                      : Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _adsEnabled
                                        ? Icons.ads_click
                                        : Icons.ads_click_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleAds,
                                  tooltip: _adsEnabled
                                      ? l10n.adsOn
                                      : l10n.adsOff,
                                ),
                              ),
                              // Vibration toggle button
                              Container(
                                width: 48,
                                height: 48,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: _vibrationEnabled
                                      ? const Color(0xFF6366F1)
                                      : Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
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
                                      ? const Color(0xFF6366F1)
                                      : Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameModeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Gradient gradient,
    Widget route, {
    double? cardSize,
  }) {
    // Calculate responsive sizes based on card size
    // If cardSize is provided, use it; otherwise use default
    final effectiveCardSize = cardSize ?? 120.0; // Default fallback
    final iconSize =
        effectiveCardSize * 0.35; // Icon container is 35% of card size
    final iconIconSize =
        effectiveCardSize * 0.2; // Icon itself is 20% of card size
    final titleFontSize = (effectiveCardSize * 0.12).clamp(12.0, 16.0);
    final descriptionFontSize = (effectiveCardSize * 0.08).clamp(9.0, 12.0);
    final padding = (effectiveCardSize * 0.13).clamp(12.0, 20.0);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(
                    iconSize * 0.29,
                  ), // ~16px for default
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: iconIconSize),
              ),
              SizedBox(height: iconSize * 0.21), // Responsive spacing
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: iconSize * 0.07), // Responsive spacing
              Text(
                description,
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  color: Colors.black.withOpacity(0.6),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for colorful spinner wheel
class ColorfulWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create colorful segments
    final segments = 36; // Number of segments
    final segmentAngle = 2 * math.pi / segments;

    // Color palette matching the design
    final colors = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF10B981), // Green
      const Color(0xFF84CC16), // Lime
      const Color(0xFFEAB308), // Yellow
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFFEC4899), // Pink
    ];

    for (int i = 0; i < segments; i++) {
      final startAngle = i * segmentAngle - math.pi / 2;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );
    }

    // Add white inner ring
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius * 0.85, whitePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
