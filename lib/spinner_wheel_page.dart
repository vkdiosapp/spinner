import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'spinner_edit_page.dart';
import 'spinner_config_page.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotation = 0;
  double _randomOffset = 0;
  bool _isSpinning = false;
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

    _controller.addListener(() {
      setState(() {
        // Use a decelerate curve for smooth spinning
        final curvedValue = Curves.decelerate.transform(_controller.value);
        // 6 full rotations + random offset for random stopping position
        _rotation = (curvedValue * 360 * 6) + _randomOffset;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;

    // Generate random offset (0 to 360 degrees) for random stopping position
    _randomOffset = _random.nextDouble() * 360;

    setState(() {
      _isSpinning = true;
      _rotation = 0;
    });

    _controller.reset();
    _controller.forward();
  }

  void _resetSpinner() {
    setState(() {
      _rotation = 0;
      _randomOffset = 0;
      _isSpinning = false;
    });
    _controller.reset();
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
    // 12 basic colors to use repeatedly
    final basicColors = [
      const Color(0xFFFF6B35), // Orange
      const Color(0xFF6C5CE7), // Purple
      const Color(0xFF74B9FF), // Light Blue
      const Color(0xFF00D2D3), // Cyan
      const Color(0xFFFFC312), // Yellow
      const Color(0xFFEE5A6F), // Pink
      const Color(0xFF5F27CD), // Dark Purple
      const Color(0xFF00B894), // Green
      const Color(0xFFFF6348), // Red Orange
      const Color(0xFF0984E3), // Blue
      const Color(0xFFFD79A8), // Light Pink
      const Color(0xFFFDCB6E), // Light Yellow
    ];
    
    _segmentColors = [];
    
    // Assign colors sequentially, ensuring no adjacent duplicates
    for (int i = 0; i < _items.length; i++) {
      Color assignedColor;
      
      if (i == 0) {
        // First segment - use first color
        assignedColor = basicColors[0];
      } else {
        // For subsequent segments, find a color that's different from the previous one
        final prevColor = _segmentColors[i - 1];
        
        // Start from the next sequential color index
        int colorIndex = (i % basicColors.length);
        
        // Find a color that's different from the previous segment
        int attempts = 0;
        while (basicColors[colorIndex] == prevColor && attempts < basicColors.length) {
          colorIndex = (colorIndex + 1) % basicColors.length;
          attempts++;
        }
        
        assignedColor = basicColors[colorIndex];
      }
      
      _segmentColors.add(assignedColor);
    }
    
    // Final check: ensure last segment doesn't match first (circular)
    if (_segmentColors.length > 1) {
      final lastIndex = _segmentColors.length - 1;
      final firstColor = _segmentColors[0];
      final secondToLastColor = _segmentColors[lastIndex - 1];
      
      if (_segmentColors[lastIndex] == firstColor) {
        // Find a different color for the last segment that's not first or second-to-last
        for (int i = 0; i < basicColors.length; i++) {
          final candidateColor = basicColors[i];
          if (candidateColor != firstColor && candidateColor != secondToLastColor) {
            _segmentColors[lastIndex] = candidateColor;
            break;
          }
        }
      }
    }
    
    // Double-check all adjacent pairs to ensure no duplicates
    for (int i = 0; i < _segmentColors.length; i++) {
      final nextIndex = (i + 1) % _segmentColors.length;
      if (_segmentColors[i] == _segmentColors[nextIndex]) {
        // Find a replacement color
        final prevIndex = (i - 1 + _segmentColors.length) % _segmentColors.length;
        final prevColor = _segmentColors[prevIndex];
        final nextColor = _segmentColors[nextIndex];
        
        for (int j = 0; j < basicColors.length; j++) {
          final candidateColor = basicColors[j];
          if (candidateColor != prevColor && candidateColor != nextColor) {
            _segmentColors[i] = candidateColor;
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

  Future<void> _shareSpinner() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/spinner_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(image);
        final screenSize = MediaQuery.of(context).size;
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out my spinner result!',
          sharePositionOrigin: Rect.fromLTWH(
            0,
            0,
            screenSize.width,
            screenSize.height,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44), // Dark purple background
      body: SafeArea(
        child: Stack(
          children: [
            // Main content (behind buttons)
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate spinner size to fit screen with margins
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;
                final margin = 20.0;
                final arrowHeight = 40.0; // Space for arrow at top
                final titleHeight = 100.0; // Space for title and padding

                // Calculate available space
                final availableWidth = maxWidth - (margin * 2);
                final availableHeight = maxHeight - titleHeight - arrowHeight - (margin * 2);

                // Use more of the screen for better coverage, especially on iPad
                final screenSize = math.min(maxWidth, maxHeight);
                final isLargeScreen = screenSize > 600; // iPad and larger devices
                
                // For large screens, use up to 75% of available space
                // For smaller screens, use up to 85% of available space
                final widthMultiplier = isLargeScreen ? 0.75 : 0.85;
                final heightMultiplier = isLargeScreen ? 0.75 : 0.85;
                
                final spinnerSize = math.min(
                  availableWidth * widthMultiplier,
                  availableHeight * heightMultiplier,
                );
                // Ensure minimum size but allow dynamic growth
                final finalSize = math.max(250.0, spinnerSize);

                // Calculate arrow size proportionally
                final arrowWidth = finalSize * 0.22;
                final arrowHeightSize = finalSize * 0.18;

                // Calculate button size proportionally
                final buttonSize = finalSize * 0.27;

                return Screenshot(
                  controller: _screenshotController,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Title above spinner
                        Padding(
                          padding: const EdgeInsets.only(top: 80, bottom: 20),
                          child: Text(
                            _currentTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Spinner Wheel with Arrow (centered)
                        Container(
                          height: finalSize + 50, // Fixed height to prevent cropping
                          margin: const EdgeInsets.all(20),
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
                              // Pointer on spinner
                              Positioned(
                                top: 10,
                                child: CustomPaint(
                                  size: Size(arrowWidth, arrowHeightSize),
                                  painter: PointerPainter(),
                                ),
                              ),
                              // Center Spin Button
                              GestureDetector(
                                onTap: _spin,
                                child: Container(
                                  width: buttonSize,
                                  height: buttonSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF6C5CE7),
                                        Color(0xFF5A4FCF),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.all(buttonSize * 0.1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF8B7ED8),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                      size: buttonSize * 0.44,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Reset and Edit buttons at bottom
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _resetSpinner,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFFF6B35,
                                    ), // Orange
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _editSpinner,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C5CE7),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
            // Back button - top left (on top of content)
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
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
            // Share button - top right (on top of content)
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _shareSpinner,
                  borderRadius: BorderRadius.circular(24),
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
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 24,
                    ),
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
