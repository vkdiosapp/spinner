import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'sound_vibration_helper.dart';

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  double _rotation1 = 0;
  double _rotation2 = 0;
  double _randomOffset1 = 0;
  double _randomOffset2 = 0;
  bool _isSpinning = false;
  int? _diceValue1;
  int? _diceValue2;
  final math.Random _random = math.Random();
  late List<DiceSegmentInfo> _segments1;
  late List<DiceSegmentInfo> _segments2;

  @override
  void initState() {
    super.initState();

    // Create segments for both dice (1-6)
    _segments1 = _createDiceSegments();
    _segments2 = _createDiceSegments();

    _controller1 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _controller2 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _controller1.addListener(() {
      setState(() {
        final curvedValue = Curves.decelerate.transform(_controller1.value);
        _rotation1 = (curvedValue * 360 * 6) + _randomOffset1;
      });
    });

    _controller2.addListener(() {
      setState(() {
        final curvedValue = Curves.decelerate.transform(_controller2.value);
        _rotation2 = (curvedValue * 360 * 6) + _randomOffset2;
      });
    });

    _controller1.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _calculateDiceValue1();
        _checkBothComplete();
      }
    });

    _controller2.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _calculateDiceValue2();
        _checkBothComplete();
      }
    });
  }

  List<DiceSegmentInfo> _createDiceSegments() {
    // Create list of dice values (1-6) and shuffle them randomly
    final diceValues = ['1', '2', '3', '4', '5', '6']..shuffle(_random);
    
    final segments = <DiceSegmentInfo>[];
    final segmentAngle = 360.0 / 6; // 60 degrees per segment
    double currentAngle = 0;

    for (int i = 0; i < 6; i++) {
      segments.add(DiceSegmentInfo(
        value: diceValues[i],
        startAngle: currentAngle,
        endAngle: currentAngle + segmentAngle,
      ));
      currentAngle += segmentAngle;
    }
    return segments;
  }

  Color _getSegmentColor(int index) {
    final colors = [
      const Color(0xFFFF6B35), // Orange
      const Color(0xFF6C5CE7), // Purple
      const Color(0xFF74B9FF), // Light Blue
      const Color(0xFF00D2D3), // Cyan
      const Color(0xFFFFC312), // Yellow
      const Color(0xFFEE5A6F), // Pink
    ];
    return colors[index % colors.length];
  }

  void _calculateDiceValue1() {
    final normalizedRotation = _rotation1 % 360;
    final targetStartAngle = (360 - normalizedRotation) % 360;
    
    int segmentIndex = 0;
    for (int i = 0; i < _segments1.length; i++) {
      final segment = _segments1[i];
      final startAngle = segment.startAngle % 360;
      final endAngle = segment.endAngle % 360;
      
      if (startAngle <= endAngle) {
        if (targetStartAngle >= startAngle && targetStartAngle < endAngle) {
          segmentIndex = i;
          break;
        }
      } else {
        if (targetStartAngle >= startAngle || targetStartAngle < endAngle) {
          segmentIndex = i;
          break;
        }
      }
    }
    
    setState(() {
      _diceValue1 = int.parse(_segments1[segmentIndex].value);
    });
  }

  void _calculateDiceValue2() {
    final normalizedRotation = _rotation2 % 360;
    final targetStartAngle = (360 - normalizedRotation) % 360;
    
    int segmentIndex = 0;
    for (int i = 0; i < _segments2.length; i++) {
      final segment = _segments2[i];
      final startAngle = segment.startAngle % 360;
      final endAngle = segment.endAngle % 360;
      
      if (startAngle <= endAngle) {
        if (targetStartAngle >= startAngle && targetStartAngle < endAngle) {
          segmentIndex = i;
          break;
        }
      } else {
        if (targetStartAngle >= startAngle || targetStartAngle < endAngle) {
          segmentIndex = i;
          break;
        }
      }
    }
    
    setState(() {
      _diceValue2 = int.parse(_segments2[segmentIndex].value);
    });
  }

  void _checkBothComplete() {
    if (_controller1.status == AnimationStatus.completed &&
        _controller2.status == AnimationStatus.completed) {
      setState(() {
        _isSpinning = false;
      });
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning) return;

    // Generate random offsets for both spinners
    _randomOffset1 = _random.nextDouble() * 360;
    _randomOffset2 = _random.nextDouble() * 360;

    // Play sound and vibration
    SoundVibrationHelper.playSpinEffects();

    setState(() {
      _isSpinning = true;
      _rotation1 = 0;
      _rotation2 = 0;
      _diceValue1 = null;
      _diceValue2 = null;
    });

    _controller1.reset();
    _controller2.reset();
    _controller1.forward();
    _controller2.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final spinnerSize = isLargeScreen 
        ? math.min(screenWidth * 0.35, 300.0)
        : (screenWidth - 60) / 2;
    final buttonSize = spinnerSize * 0.25;
    final arrowWidth = spinnerSize * 0.3;
    final arrowHeight = spinnerSize * 0.18; // Match multiplayer spinner (finalSize * 0.18)

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header with back button and title
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
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  // Title - centered on screen
                  const Text(
                    'Dice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Two dice spinners side by side
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Dice 1
                          _buildDiceSpinner(
                            size: spinnerSize,
                            rotation: _rotation1,
                            segments: _segments1,
                            value: _diceValue1,
                            label: 'Dice 1',
                            buttonSize: buttonSize,
                            arrowWidth: arrowWidth,
                            arrowHeight: arrowHeight,
                          ),
                          // Dice 2
                          _buildDiceSpinner(
                            size: spinnerSize,
                            rotation: _rotation2,
                            segments: _segments2,
                            value: _diceValue2,
                            label: 'Dice 2',
                            buttonSize: buttonSize,
                            arrowWidth: arrowWidth,
                            arrowHeight: arrowHeight,
                          ),
                        ],
                      ),
                    const SizedBox(height: 40),
                    // Single Spin Button
                    SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isSpinning ? null : _startSpin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            _isSpinning ? 'Spinning...' : 'Spin',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    // Results display (always visible)
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D3D5C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildResultCard('Dice 1', _diceValue1),
                                _buildResultCard('Dice 2', _diceValue2),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5CE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _diceValue1 != null && _diceValue2 != null
                                    ? 'Total: ${_diceValue1! + _diceValue2!}'
                                    : 'Total: ?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceSpinner({
    required double size,
    required double rotation,
    required List<DiceSegmentInfo> segments,
    int? value,
    required String label,
    required double buttonSize,
    required double arrowWidth,
    required double arrowHeight,
  }) {
    return Column(
      children: [
        Container(
          height: size + 50,
          width: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wheel
              Transform.rotate(
                angle: rotation * math.pi / 180,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: DiceWheelPainter(
                    segments: segments,
                    getSegmentColor: _getSegmentColor,
                  ),
                ),
              ),
              // Pointer (same as Truth & Dare spinner)
              Positioned(
                top: 10,
                child: CustomPaint(
                  size: Size(arrowWidth, arrowHeight),
                  painter: DicePointerPainter(),
                ),
              ),
              // Center Button (non-tappable, same UI as multiplayer spinner)
              IgnorePointer(
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
                      Icons.casino,
                      color: Colors.white,
                      size: buttonSize * 0.44,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(String label, int? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // Show dice image with value
          value != null ? _buildDiceFace(value) : const Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceFace(int value) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: _buildDiceDots(value),
      ),
    );
  }

  Widget _buildDiceDots(int value) {
    // Dice dot patterns for values 1-6
    switch (value) {
      case 1:
        return Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// Segment info for dice wheel
class DiceSegmentInfo {
  final String value;
  final double startAngle; // in degrees
  final double endAngle; // in degrees

  DiceSegmentInfo({
    required this.value,
    required this.startAngle,
    required this.endAngle,
  });
}

// Custom painter for dice wheel (same style as multiplayer)
class DiceWheelPainter extends CustomPainter {
  final List<DiceSegmentInfo> segments;
  final Color Function(int) getSegmentColor;

  DiceWheelPainter({required this.segments, required this.getSegmentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final borderWidth = 4.0;
    final radius = (size.width / 2) - (borderWidth / 2);

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      // Convert degrees to radians and adjust for top start (-90 degrees)
      final startAngle = (segment.startAngle - 90) * math.pi / 180;
      final endAngle = (segment.endAngle - 90) * math.pi / 180;
      final segmentAngle = endAngle - startAngle;

      final paint = Paint()
        ..color = getSegmentColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.82;
      final text = segment.value;

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();

      // Draw stars
      final starRadius = radius * 0.5;
      final starX = center.dx + starRadius * math.cos(textAngle);
      final starY = center.dy + starRadius * math.sin(textAngle);
      _drawStar(canvas, Offset(starX, starY), 8, Colors.white.withOpacity(0.6));
    }

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

// Pointer painter (same as Truth & Dare)
class DicePointerPainter extends CustomPainter {
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
