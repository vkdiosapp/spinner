import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:screenshot/screenshot.dart';
import 'spinner_edit_page.dart';
import 'spinner_config_page.dart';
import 'sound_vibration_helper.dart';
import 'ad_helper.dart';
import 'spinner_colors.dart';
import 'app_localizations_helper.dart';

class SpinnerWheelPage extends StatefulWidget {
  final List<String> items;
  final String title;

  const SpinnerWheelPage({
    super.key,
    this.items = const [],
    this.title = 'Random Picker',
  });

  @override
  State<SpinnerWheelPage> createState() => _SpinnerWheelPageState();
}

class _SpinnerWheelPageState extends State<SpinnerWheelPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _revealController;
  double _rotation = 0;
  double _randomOffset = 0;
  bool _isSpinning = false;
  bool _isRevealed = false;
  String? _selectedItem;
  late List<String> _items;
  late String _currentTitle;
  late List<Color> _segmentColors; // Store assigned colors to avoid duplicates
  final math.Random _random = math.Random();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _items = widget.items.isEmpty
        ? ['100', '20', '15', '5', '50', '20', '10', '2']
        : List.from(widget.items);
    _currentTitle = widget.title;
    
    // Initialize colors without duplicates
    _initializeColors();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        // Use a decelerate curve for smooth spinning
        final curvedValue = Curves.decelerate.transform(_controller.value);
        // 6 full rotations + random offset for random stopping position
        _rotation = (curvedValue * 360 * 6) + _randomOffset;
        
        // Calculate speed based on curve derivative (rate of change)
        // Decelerate curve: starts fast, ends slow
        // Speed is proportional to the derivative of the curve
        final speed = _calculateSpeed(_controller.value);
        SoundVibrationHelper.updateSpeed(speed);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        // Stop continuous sound when animation completes
        SoundVibrationHelper.stopContinuousSound();
        // Calculate selected item and show reveal popup
        _handleSpinComplete();
      }
    });
  }

  @override
  void dispose() {
    // Stop continuous sound when disposing
    SoundVibrationHelper.stopContinuousSound();
    _controller.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _handleSpinComplete() {
    // Calculate which segment the pointer is pointing to
    final normalizedRotation = _rotation % 360;
    final segmentAngle = 360.0 / _items.length;
    final targetStartAngle = (360 - normalizedRotation) % 360;
    
    // Find the segment index
    int segmentIndex = ((targetStartAngle / segmentAngle).floor()) % _items.length;

    // Show reveal animation
    setState(() {
      _selectedItem = _items[segmentIndex];
      _isRevealed = true;
    });
    _revealController.forward(from: 0);
  }

  void _resetReveal() {
    setState(() {
      _isRevealed = false;
      _selectedItem = null;
      // Reset spinner rotation
      _rotation = 0;
      _randomOffset = 0;
      _isSpinning = false;
    });
    _revealController.reset();
    _controller.reset();
  }

  void _spin() {
    if (_isSpinning) return;

    // Generate random offset (0 to 360 degrees) for random stopping position
    _randomOffset = _random.nextDouble() * 360;

    // Play initial sound and vibration, then start continuous sound
    SoundVibrationHelper.playSpinEffects();
    SoundVibrationHelper.startContinuousSound();

    setState(() {
      _isSpinning = true;
      _rotation = 0;
    });

    _controller.reset();
    _controller.forward();
  }

  // Calculate speed based on animation value (0.0 to 1.0)
  // For decelerate curve: speed decreases as value increases
  double _calculateSpeed(double animationValue) {
    // Decelerate curve derivative approximation
    // At value 0.0, speed is 1.0 (fastest)
    // At value 1.0, speed is near 0.0 (slowest)
    // Using a simple approximation: speed = 1.0 - animationValue
    // But we want it to decelerate more smoothly, so we use a curve
    return (1.0 - animationValue).clamp(0.1, 1.0);
  }

  Future<void> _editSpinner() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) =>
            SpinnerEditPage(title: _currentTitle, items: List.from(_items)),
      ),
    );

    if (result != null) {
      setState(() {
        _currentTitle = result['title'] as String;
        _items = List<String>.from(result['items'] as List);
        // Reinitialize colors when items change
        _initializeColors();
        // Reset spinner when items change
        _rotation = 0;
        _randomOffset = 0;
        _isSpinning = false;
      });
      _controller.reset();
    }
  }

  void _initializeColors() {
    _segmentColors = [];
    
    // Assign colors sequentially (line-wise) from SpinnerColors
    // Colors repeat if there are more segments than available colors
    for (int i = 0; i < _items.length; i++) {
      // Get color by index, which will cycle through the color list
      Color assignedColor = SpinnerColors.getColor(i);
      
      // Ensure no adjacent duplicates (including circular - last to first)
      if (i > 0) {
        final prevColor = _segmentColors[i - 1];
        // If current color matches previous, get next color
        if (assignedColor == prevColor) {
          assignedColor = SpinnerColors.getColor(i + 1);
        }
      }
      
      _segmentColors.add(assignedColor);
    }
    
    // Ensure last segment doesn't match first (circular adjacency)
    if (_segmentColors.length > 1) {
      final lastIndex = _segmentColors.length - 1;
      if (_segmentColors[0] == _segmentColors[lastIndex]) {
        // Find a different color for the last segment
        final firstColor = _segmentColors[0];
        final secondToLastColor = _segmentColors[lastIndex - 1];
        
        // Try to find a color that's different from both first and second-to-last
        for (int i = 0; i < SpinnerColors.segmentColors.length; i++) {
          final candidateColor = SpinnerColors.segmentColors[i];
          if (candidateColor != firstColor && candidateColor != secondToLastColor) {
            _segmentColors[lastIndex] = candidateColor;
            break;
          }
        }
      }
    }
  }

  Color _getSegmentColor(int index) {
    // Return pre-assigned color for this segment
    return _segmentColors[index % _segmentColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44), // Dark purple background
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header with back button, title, and share button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back button - left aligned
                  Align(
                    alignment: Alignment.centerLeft,
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => BackArrowAd.handleBackButton(
                          context: context,
                          onBack: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const SpinnerConfigPage(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // Title - centered on screen
                  Text(
                    _currentTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Edit button - right aligned
                  Align(
                    alignment: Alignment.centerRight,
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
                        icon: const Icon(Icons.edit, color: Colors.white, size: 24),
                        onPressed: _editSpinner,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Spinner content - no scrolling
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Get screen orientation
                  final screenSize = MediaQuery.of(context).size;
                  final isLandscape = screenSize.width > screenSize.height;
                  
                  // Calculate available space
                  final availableHeight = constraints.maxHeight;
                  final availableWidth = constraints.maxWidth;
                  
                  // Account for popup size (can be 1.2x spinner size) and minimal padding
                  final popupMultiplier = 1.2;
                  final padding = 20.0; // 10px padding on each side
                  
                  // Calculate maximum spinner size that fits
                  // Account for popup overflow in calculations
                  final maxSpinnerWidth = (availableWidth - padding) / popupMultiplier;
                  final maxSpinnerHeight = (availableHeight - padding) / popupMultiplier;
                  
                  // Use more aggressive sizing to fill available space
                  final widthMultiplier = isLandscape ? 0.9 : 0.95;
                  final heightMultiplier = isLandscape ? 0.9 : 0.95;
                  
                  final maxSpinnerSize = math.min(
                    maxSpinnerWidth * widthMultiplier,
                    maxSpinnerHeight * heightMultiplier,
                  );
                  
                  // Ensure minimum size but use more of available space
                  final finalSize = math.max(200.0, maxSpinnerSize);

                  // Calculate button size proportionally
                  final buttonSize = finalSize * 0.27;

                  return Screenshot(
                    controller: _screenshotController,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                              // Wheel
                              Transform.rotate(
                                angle: _rotation * math.pi / 180,
                                child: CustomPaint(
                                  size: Size(finalSize, finalSize),
                                  painter: WheelPainter(
                                    items: _items,
                                    getSegmentColor: _getSegmentColor,
                                  ),
                                ),
                              ),
                              // Center Spin Button
                              GestureDetector(
                                onTap: (_isSpinning || _isRevealed) ? null : _spin,
                                child: Opacity(
                                  opacity: (_isSpinning || _isRevealed) ? 0.5 : 1.0,
                                  child: Image.asset(
                                    'assets/images/spin_logo.png',
                                    width: buttonSize,
                                    height: buttonSize,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Reveal animation overlay on spinner (copied from Truth and Dare)
                              if (_isRevealed && _selectedItem != null)
                                AnimatedBuilder(
                                  animation: _revealController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity: _revealController,
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                                          CurvedAnimation(
                                            parent: _revealController,
                                            curve: Curves.elasticOut,
                                          ),
                                        ),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: math.min(finalSize * 1.2, availableWidth - padding),
                                            maxHeight: math.min(finalSize * 1.2, availableHeight - padding),
                                          ),
                                          child: Container(
                                            width: math.min(finalSize * 1.2, availableWidth - padding),
                                            height: math.min(finalSize * 1.2, availableHeight - padding),
                                            decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                SpinnerColors.segmentColors[0].withOpacity(0.95),
                                                SpinnerColors.segmentColors[0].withOpacity(0.8),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: SpinnerColors.segmentColors[0].withOpacity(0.5),
                                                blurRadius: 30,
                                                spreadRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // Animated emoji
                                                ScaleTransition(
                                                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                                                    CurvedAnimation(
                                                      parent: _revealController,
                                                      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '🎯',
                                                    style: TextStyle(fontSize: finalSize * 0.15),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Selected item text with animation
                                                FadeTransition(
                                                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                                    CurvedAnimation(
                                                      parent: _revealController,
                                                      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                                    child: Text(
                                                      _selectedItem!,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: finalSize * 0.06,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Close button
                                                FadeTransition(
                                                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                                    CurvedAnimation(
                                                      parent: _revealController,
                                                      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                                                    ),
                                                  ),
                                                  child: Material(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(20),
                                                    child: InkWell(
                                                      onTap: _resetReveal,
                                                      borderRadius: BorderRadius.circular(20),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 10,
                                                        ),
                                                        child: Text(
                                                          l10n.close,
                                                          style: TextStyle(
                                                            color: SpinnerColors.segmentColors[0],
                                                            fontSize: finalSize * 0.05,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  },
                                ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Banner Ad at bottom
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

// Painter for the wheel
class WheelPainter extends CustomPainter {
  final List<String> items;
  final Color Function(int) getSegmentColor;

  WheelPainter({required this.items, required this.getSegmentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Reduce radius to account for 4px border (half stroke width on each side)
    final borderWidth = 4.0;
    final radius = (size.width / 2) - (borderWidth / 2);
    final anglePerSegment = 2 * math.pi / items.length;

    // Draw segments
    for (int i = 0; i < items.length; i++) {
      final startAngle = i * anglePerSegment - math.pi / 2;
      final endAngle = (i + 1) * anglePerSegment - math.pi / 2;

      // Draw segment
      final paint = Paint()
        ..color = getSegmentColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
        paint,
      );

      // Draw segment border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
        borderPaint,
      );

      // Draw curved text - ensure it stays within segment boundaries
      final textAngle = startAngle + anglePerSegment / 2;
      final textRadius = radius * 0.82; // Same radius as before
      String text = items[i];

      // Calculate maximum arc length available for text (with padding)
      final maxArcLength =
          (anglePerSegment - 0.1) * textRadius; // Leave small padding

      // Measure text width
      final measurePainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      measurePainter.layout();
      var totalTextWidth = measurePainter.width;

      // If text is too long, truncate with ellipsis
      if (totalTextWidth > maxArcLength) {
        final ellipsis = '...';
        final ellipsisPainter = TextPainter(
          text: TextSpan(
            text: ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        ellipsisPainter.layout();
        final ellipsisWidth = ellipsisPainter.width;
        final availableWidth = maxArcLength - ellipsisWidth;

        // Find how many characters fit
        String truncatedText = text;
        while (truncatedText.isNotEmpty) {
          final testPainter = TextPainter(
            text: TextSpan(
              text: truncatedText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          testPainter.layout();
          if (testPainter.width <= availableWidth) {
            text = truncatedText + ellipsis;
            totalTextWidth = testPainter.width + ellipsisWidth;
            break;
          }
          truncatedText = truncatedText.substring(0, truncatedText.length - 1);
        }
      }

      // Calculate the arc span for the text (in radians)
      final textArcSpan = totalTextWidth / textRadius;

      // Draw each character along the curve, centered at textAngle
      final startCharAngle = textAngle - textArcSpan / 2;
      double currentCharPosition = 0;

      for (int j = 0; j < text.length; j++) {
        // Measure current character width
        final charPainter = TextPainter(
          text: TextSpan(
            text: text[j],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        charPainter.layout();
        final charWidth = charPainter.width;

        // Calculate angle for this character (center of character)
        final charAngle =
            startCharAngle + (currentCharPosition + charWidth / 2) / textRadius;
        final charX = center.dx + textRadius * math.cos(charAngle);
        final charY = center.dy + textRadius * math.sin(charAngle);

        canvas.save();
        canvas.translate(charX, charY);
        // Rotate character to follow the curve
        canvas.rotate(charAngle + math.pi / 2);

        charPainter.paint(
          canvas,
          Offset(-charPainter.width / 2, -charPainter.height / 2),
        );
        canvas.restore();

        currentCharPosition += charWidth;
      }

      // Draw stars on all segments
      final starRadius = radius * 0.5;
      final starX = center.dx + starRadius * math.cos(textAngle);
      final starY = center.dy + starRadius * math.sin(textAngle);

      _drawStar(canvas, Offset(starX, starY), 8, Colors.white.withOpacity(0.6));
    }

    // Draw white border around the entire spinner circle
    final circleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, circleBorderPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final numPoints = 5;
    final angleStep = 2 * math.pi / numPoints;

    for (int i = 0; i < numPoints * 2; i++) {
      final angle = i * angleStep / 2 - math.pi / 2;
      final r = i.isEven ? radius : radius * 0.4;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter for the pointer
class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final arrowHeight = size.height;
    final arrowWidth = size.width;

    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - arrowWidth * 0.3,
          0,
          arrowWidth * 0.6,
          arrowHeight * 0.6,
        ),
        const Radius.circular(4),
      ),
    );

    path.moveTo(centerX - arrowWidth * 0.3, arrowHeight * 0.6);
    path.lineTo(centerX, arrowHeight);
    path.lineTo(centerX + arrowWidth * 0.3, arrowHeight * 0.6);
    path.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF69B4),
          const Color(0xFFFF1493),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, gradientPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
