import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'home_page.dart';

class MultiplayerSpinnerPage extends StatefulWidget {
  final List<String> users;
  final int rounds;

  const MultiplayerSpinnerPage({
    super.key,
    required this.users,
    required this.rounds,
  });

  @override
  State<MultiplayerSpinnerPage> createState() => _MultiplayerSpinnerPageState();
}

class _MultiplayerSpinnerPageState extends State<MultiplayerSpinnerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotation = 0;
  double _randomOffset = 0;
  bool _isSpinning = false;
  final List<String> _items = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  final math.Random _random = math.Random();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  // Game state
  int _currentRound = 1;
  int _currentUserIndex = 0;
  Map<String, int> _scores = {};
  bool _gameCompleted = false;
  String? _winner;

  @override
  void initState() {
    super.initState();
    // Initialize scores
    for (var user in widget.users) {
      _scores[user] = 0;
    }

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        final curvedValue = Curves.decelerate.transform(_controller.value);
        _rotation = (curvedValue * 360 * 6) + _randomOffset;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _handleSpinComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSpinComplete() {
    // Calculate which segment the pointer is pointing to (0-9)
    // The pointer is at the top, pointing down (-90 degrees or 270 degrees)
    // Segments are drawn starting from -90 degrees (top), each segment is 36 degrees
    // When the wheel rotates clockwise by R degrees, we need to find which segment is at the top
    
    // Normalize rotation to 0-360 range
    final normalizedRotation = _rotation % 360;
    
    // The wheel rotates clockwise. Segment 0 starts at -90 degrees (top).
    // After rotating by R degrees, segment 0 is at (-90 + R) degrees.
    // The pointer is fixed at -90 degrees (top).
    // We need to find which segment is now at -90 degrees after rotation.
    // 
    // If segment i starts at (-90 + i*36) degrees, after rotation it's at (-90 + i*36 + R) degrees.
    // We want: -90 + i*36 + R = -90 (mod 360)
    // So: i*36 + R = 0 (mod 360)
    // So: i*36 = -R (mod 360) = (360 - R) (mod 360)
    // So: i = (360 - R) / 36 (mod 10)
    
    final segmentIndex = ((360 - normalizedRotation) / 36).floor() % 10;
    final points = int.parse(_items[segmentIndex]);

    // Add points to current user
    final currentUser = widget.users[_currentUserIndex];
    _scores[currentUser] = (_scores[currentUser] ?? 0) + points;

    // Move to next user or next round
    if (_currentUserIndex < widget.users.length - 1) {
      // Next user in same round
      setState(() {
        _currentUserIndex++;
      });
    } else {
      // Round complete, move to next round
      if (_currentRound < widget.rounds) {
        setState(() {
          _currentRound++;
          _currentUserIndex = 0;
        });
      } else {
        // Game complete - find winner
        _determineWinner();
      }
    }
  }

  void _determineWinner() {
    setState(() {
      _gameCompleted = true;
      // Find user with highest score
      var maxScore = -1;
      String? winner;
      for (var entry in _scores.entries) {
        if (entry.value > maxScore) {
          maxScore = entry.value;
          winner = entry.key;
        }
      }
      _winner = winner;
    });
  }

  void _spin() {
    if (_isSpinning || _gameCompleted) return;

    _randomOffset = _random.nextDouble() * 360;

    setState(() {
      _isSpinning = true;
      _rotation = 0;
    });

    _controller.reset();
    _controller.forward();
  }

  void _resetGame() {
    setState(() {
      _currentRound = 1;
      _currentUserIndex = 0;
      _scores.clear();
      for (var user in widget.users) {
        _scores[user] = 0;
      }
      _gameCompleted = false;
      _winner = null;
      _rotation = 0;
      _randomOffset = 0;
      _isSpinning = false;
    });
    _controller.reset();
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
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
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Check out my multiplayer spinner result!');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
    }
  }

  Color _getSegmentColor(int index) {
    final colors = [
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
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44),
      body: SafeArea(
        child: Stack(
          children: [
            // Back button - top left
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
                  onPressed: _goHome,
                ),
              ),
            ),
            // Share button - top right
            Positioned(
              top: 16,
              right: 16,
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
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _shareSpinner,
                ),
              ),
            ),
            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;
                final margin = 20.0;
                final arrowHeight = 40.0;

                final availableWidth = maxWidth - (margin * 2);
                final availableHeight = maxHeight - (margin * 2) - arrowHeight;

                final spinnerSize = math.min(availableWidth, availableHeight) * 0.98;
                final finalSize = math.max(250.0, spinnerSize);

                final arrowWidth = finalSize * 0.22;
                final arrowHeightSize = finalSize * 0.18;
                final buttonSize = finalSize * 0.27;

                return Screenshot(
                  controller: _screenshotController,
                  child: Column(
                    children: [
                    // Round info
                    Padding(
                      padding: const EdgeInsets.only(top: 80, bottom: 12),
                      child: Text(
                        'Round $_currentRound / ${widget.rounds}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Users and scores - Wrap to show all users at once
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: widget.users.asMap().entries.map((entry) {
                          final index = entry.key;
                          final user = entry.value;
                          final score = _scores[user] ?? 0;
                          final isCurrentUser = index == _currentUserIndex && !_gameCompleted;
                          return Container(
                            width: (maxWidth - 60) / (widget.users.length > 3 ? 3 : widget.users.length) - 8,
                            constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? const Color(0xFF6C5CE7)
                                  : const Color(0xFF3D3D5C),
                              borderRadius: BorderRadius.circular(12),
                              border: isCurrentUser
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Score: $score',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Current user turn text below user grid
                    Text(
                      _gameCompleted
                          ? 'Game Complete!'
                          : '${widget.users[_currentUserIndex]}' "'s Turn",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Spinner Wheel
                    Expanded(
                      child: Center(
                        child: Container(
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
                              // Pointer
                              Positioned(
                                top: -25,
                                child: Container(
                                  width: arrowWidth,
                                  height: arrowHeightSize,
                                  child: Image.asset(
                                    'assets/images/arrow_pointer.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return CustomPaint(
                                        size: Size(arrowWidth, arrowHeightSize),
                                        painter: PointerPainter(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Center Spin Button
                              if (!_gameCompleted)
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
                      ),
                    ),
                    // Winner announcement or buttons
                    if (_gameCompleted)
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5CE7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '🏆 Winner! 🏆',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _winner ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Score: ${_scores[_winner]}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _resetGame,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6B35),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Text(
                                      'Play Again',
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
                                    onPressed: _goHome,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C5CE7),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Text(
                                      'Home',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reuse WheelPainter and PointerPainter from spinner_wheel_page
class WheelPainter extends CustomPainter {
  final List<String> items;
  final Color Function(int) getSegmentColor;

  WheelPainter({required this.items, required this.getSegmentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final borderWidth = 4.0;
    final radius = (size.width / 2) - (borderWidth / 2);
    final anglePerSegment = 2 * math.pi / items.length;

    for (int i = 0; i < items.length; i++) {
      final startAngle = i * anglePerSegment - math.pi / 2;
      final endAngle = (i + 1) * anglePerSegment - math.pi / 2;

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

      final textAngle = startAngle + anglePerSegment / 2;
      final textRadius = radius * 0.82;
      final text = items[i];

      final textPainter = TextPainter(
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

