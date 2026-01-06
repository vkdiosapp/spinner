import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'home_page.dart';
import 'multiplayer_results_page.dart';

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
  bool _isWaitingForNextTurn = false;
  late List<SegmentInfo> _segments; // Track segment info including jackpot
  final math.Random _random = math.Random();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  // Game state
  int _currentRound = 1;
  int _currentUserIndex = 0;
  Map<String, int> _scores = {};
  Map<int, Map<String, int>> _roundScores = {}; // Track scores per round

  @override
  void initState() {
    super.initState();
    // Initialize scores
    for (var user in widget.users) {
      _scores[user] = 0;
    }
    // Initialize round scores
    _roundScores[1] = {};
    for (var user in widget.users) {
      _roundScores[1]![user] = 0;
    }

    // Shuffle items randomly
    final regularItems = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']..shuffle(_random);
    
    // Create segments with jackpot (10 degrees width - 1/3 of previous 30 degrees)
    // Regular segment angle: (360 - 10) / 10 = 35 degrees each
    final jackpotAngle = 10.0; // Fixed 10 degrees (1/3 of 30)
    final regularAngle = (360.0 - jackpotAngle) / 10; // 35 degrees each
    
    _segments = [];
    double currentAngle = 0;
    
    // Add jackpot at a random position
    final jackpotPosition = _random.nextInt(11); // Position 0-10
    
    for (int i = 0; i < 11; i++) {
      if (i == jackpotPosition) {
        // Add jackpot segment (10 degrees - very thin!)
        _segments.add(SegmentInfo(
          value: '20',
          isJackpot: true,
          startAngle: currentAngle,
          endAngle: currentAngle + jackpotAngle,
        ));
        currentAngle += jackpotAngle;
      } else {
        // Add regular segment (35 degrees)
        final itemIndex = i > jackpotPosition ? i - 1 : i;
        _segments.add(SegmentInfo(
          value: regularItems[itemIndex],
          isJackpot: false,
          startAngle: currentAngle,
          endAngle: currentAngle + regularAngle,
        ));
        currentAngle += regularAngle;
      }
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
    // Calculate which segment the pointer is pointing to
    // The pointer is at the top, pointing down (-90 degrees in canvas coordinates)
    // Segments are stored with angles starting from 0, but drawn starting from -90 degrees
    // When the wheel rotates clockwise by R degrees:
    //   - A segment stored at angle A is drawn at (A - 90) degrees (canvas)
    //   - After rotation, it's drawn at (A - 90 + R) degrees (canvas)
    // The pointer is fixed at -90 degrees (canvas)
    // We need: A - 90 + R = -90, so A + R = 0, so A = -R (mod 360) = 360 - R
    
    // Normalize rotation to 0-360 range
    final normalizedRotation = _rotation % 360;
    
    // Find which segment's start angle equals (360 - normalizedRotation) mod 360
    // This is the segment that is now at the top after rotation
    final targetStartAngle = (360 - normalizedRotation) % 360;
    
    // Find the segment that contains this start angle
    int segmentIndex = 0;
    for (int i = 0; i < _segments.length; i++) {
      final segment = _segments[i];
      final startAngle = segment.startAngle % 360;
      final endAngle = segment.endAngle % 360;
      
      // Check if targetStartAngle falls within this segment's range
      if (startAngle <= endAngle) {
        // Normal case: segment doesn't cross 0
        if (targetStartAngle >= startAngle && targetStartAngle < endAngle) {
          segmentIndex = i;
          break;
        }
      } else {
        // Segment crosses 0 degrees (wraps around)
        if (targetStartAngle >= startAngle || targetStartAngle < endAngle) {
          segmentIndex = i;
          break;
        }
      }
    }
    
    final points = int.parse(_segments[segmentIndex].value);

    // Add points to current user
    final currentUser = widget.users[_currentUserIndex];
    _scores[currentUser] = (_scores[currentUser] ?? 0) + points;
    // Track round score
    _roundScores[_currentRound]![currentUser] = 
        (_roundScores[_currentRound]![currentUser] ?? 0) + points;

    // Wait a moment to show the result before moving to next turn
    setState(() {
      _isWaitingForNextTurn = true;
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      
      // Move to next user or next round
      if (_currentUserIndex < widget.users.length - 1) {
        // Next user in same round - reset spinner first
        _resetSpinnerForNextTurn();
        setState(() {
          _currentUserIndex++;
          _isWaitingForNextTurn = false;
        });
      } else {
        // Round complete, move to next round
        if (_currentRound < widget.rounds) {
          _resetSpinnerForNextTurn();
          setState(() {
            _currentRound++;
            _currentUserIndex = 0;
            _isWaitingForNextTurn = false;
            // Initialize next round scores
            _roundScores[_currentRound] = {};
            for (var user in widget.users) {
              _roundScores[_currentRound]![user] = 0;
            }
          });
        } else {
          // Game complete - navigate to results page
          _navigateToResults();
        }
      }
    });
  }

  void _navigateToResults() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MultiplayerResultsPage(
          users: widget.users,
          rounds: widget.rounds,
          roundScores: _roundScores,
          totalScores: Map<String, int>.from(_scores),
        ),
      ),
    );
  }

  void _resetSpinnerForNextTurn() {
    // Reset spinner rotation and offset for next turn
    setState(() {
      _rotation = 0;
      _randomOffset = 0;
      _isSpinning = false;
      _isWaitingForNextTurn = false;
    });
    _controller.reset();
  }

  void _spin() {
    if (_isSpinning || _isWaitingForNextTurn) return;

    _randomOffset = _random.nextDouble() * 360;

    setState(() {
      _isSpinning = true;
      _rotation = 0;
    });

    _controller.reset();
    _controller.forward();
  }

  void _goHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    }
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
          text: 'Check out my multiplayer spinner result!',
          sharePositionOrigin: Rect.fromLTWH(
            0,
            0,
            screenSize.width,
            screenSize.height,
          ),
        );
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _goHome,
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
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
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

                // Calculate available space dynamically
                // Use more of the screen for larger devices
                final screenSize = math.min(maxWidth, maxHeight);
                final isLargeScreen = screenSize > 600; // iPad and larger devices
                
                // Calculate user section height dynamically
                final userRows = (widget.users.length / 3).ceil();
                final userSectionHeight = userRows * 70.0 + 40.0; // Approximate height per row
                final turnTextHeight = 40.0;
                final topPadding = 20.0; // Reduced padding
                final bottomPadding = 20.0;
                
                final availableWidth = maxWidth - (margin * 2);
                final availableHeight = maxHeight - topPadding - userSectionHeight - turnTextHeight - bottomPadding - arrowHeight;

                // Use more aggressive spinner size calculation for better screen coverage
                // For large screens (iPad), use up to 75% of available space
                // For smaller screens, use up to 85% of available space
                final widthMultiplier = isLargeScreen ? 0.75 : 0.85;
                final heightMultiplier = isLargeScreen ? 0.75 : 0.85;
                
                final spinnerSize = math.min(availableWidth * widthMultiplier, availableHeight * heightMultiplier);
                // Remove max size limit for large screens, allow spinner to grow dynamically
                final finalSize = math.max(250.0, spinnerSize);

                final arrowWidth = finalSize * 0.22;
                final arrowHeightSize = finalSize * 0.18;
                final buttonSize = finalSize * 0.27;

                return Screenshot(
                  controller: _screenshotController,
                  child: SingleChildScrollView(
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
                          final isCurrentUser = index == _currentUserIndex;
                          
                          // Get current round score for this user
                          final currentRoundScore = _roundScores[_currentRound]?[user] ?? 0;
                          
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
                                  'Score: $currentRoundScore',
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
                      '${widget.users[_currentUserIndex]}' "'s Turn",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Spinner Wheel
                    Center(
                      child: Container(
                        height: finalSize + 50, // Fixed height to prevent cropping
                        width: finalSize,
                        margin: const EdgeInsets.all(20),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Wheel
                            Transform.rotate(
                              angle: _rotation * math.pi / 180,
                              child: CustomPaint(
                                size: Size(finalSize, finalSize),
                                painter: MultiplayerWheelPainter(
                                  segments: _segments,
                                  getSegmentColor: _getSegmentColor,
                                ),
                              ),
                            ),
                            // Pointer
                            Positioned(
                              top: 10,
                              child: CustomPaint(
                                size: Size(arrowWidth, arrowHeightSize),
                                painter: PointerPainter(),
                              ),
                            ),
                              // Center Spin Button
                              GestureDetector(
                                  onTap: _isWaitingForNextTurn ? null : _spin,
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
                    const SizedBox(height: 20),
                      ],
                    ),
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

// Segment info for multiplayer wheel with jackpot
class SegmentInfo {
  final String value;
  final bool isJackpot;
  final double startAngle; // in degrees
  final double endAngle; // in degrees

  SegmentInfo({
    required this.value,
    required this.isJackpot,
    required this.startAngle,
    required this.endAngle,
  });
}

// Custom painter for multiplayer wheel with variable segment sizes
class MultiplayerWheelPainter extends CustomPainter {
  final List<SegmentInfo> segments;
  final Color Function(int) getSegmentColor;

  MultiplayerWheelPainter({required this.segments, required this.getSegmentColor});

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

      // Use gold color for jackpot, regular color for others
      final paint = Paint()
        ..color = segment.isJackpot 
            ? const Color(0xFFFFD700) // Gold for jackpot
            : getSegmentColor(i % 10)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw border - thicker for jackpot
      final borderPaint = Paint()
        ..color = segment.isJackpot 
            ? Colors.white 
            : Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = segment.isJackpot ? 3 : 2;

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
            color: segment.isJackpot ? Colors.black : Colors.white,
            fontSize: segment.isJackpot ? 20 : 24,
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

      // Draw stars - more prominent for jackpot
      if (!segment.isJackpot) {
        final starRadius = radius * 0.5;
        final starX = center.dx + starRadius * math.cos(textAngle);
        final starY = center.dy + starRadius * math.sin(textAngle);
        _drawStar(canvas, Offset(starX, starY), 8, Colors.white.withOpacity(0.6));
      } else {
        // Draw sparkle effect for jackpot
        final sparkleRadius = radius * 0.5;
        final sparkleX = center.dx + sparkleRadius * math.cos(textAngle);
        final sparkleY = center.dy + sparkleRadius * math.sin(textAngle);
        _drawStar(canvas, Offset(sparkleX, sparkleY), 12, Colors.yellow.withOpacity(0.8));
        // Draw additional sparkles around jackpot
        for (int j = 0; j < 3; j++) {
          final offsetAngle = textAngle + (j - 1) * segmentAngle * 0.3;
          final offsetX = center.dx + sparkleRadius * math.cos(offsetAngle);
          final offsetY = center.dy + sparkleRadius * math.sin(offsetAngle);
          _drawStar(canvas, Offset(offsetX, offsetY), 6, Colors.yellow.withOpacity(0.6));
        }
      }
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

