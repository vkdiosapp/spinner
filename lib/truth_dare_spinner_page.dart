import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'sound_vibration_helper.dart';

class TruthDareSpinnerPage extends StatefulWidget {
  final String level;
  final List<String> users;

  const TruthDareSpinnerPage({
    super.key,
    required this.level,
    required this.users,
  });

  @override
  State<TruthDareSpinnerPage> createState() => _TruthDareSpinnerPageState();
}

class _TruthDareSpinnerPageState extends State<TruthDareSpinnerPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _revealController;
  double _rotation = 0;
  double _randomOffset = 0;
  bool _isSpinning = false;
  bool _isRevealed = false;
  String? _selectedType; // 'truth' or 'dare'
  String? _selectedMessage;
  List<String> _truthItems = [];
  List<String> _dareItems = [];
  Set<int> _usedTruthIndices = {};
  Set<int> _usedDareIndices = {};
  final math.Random _random = math.Random();
  
  // User turn management
  int _currentUserIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTruthDareData();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
        _handleSpinComplete();
      }
    });
  }

  Future<void> _loadTruthDareData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/truth_dare.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final levelKey = widget.level.toLowerCase();
      if (jsonData.containsKey(levelKey)) {
        final levelData = jsonData[levelKey] as Map<String, dynamic>;
        setState(() {
          _truthItems = List<String>.from(levelData['truth'] ?? []);
          _dareItems = List<String>.from(levelData['dare'] ?? []);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || _isRevealed) return;
    
    // Only allow current user to spin
    // This check is handled in the UI by disabling the button, but keep as safety

    // Check if all items are used
    if (_usedTruthIndices.length >= _truthItems.length &&
        _usedDareIndices.length >= _dareItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All truth and dare items have been used!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _randomOffset = _random.nextDouble() * 360;

    // Play sound and vibration
    SoundVibrationHelper.playSpinEffects();

    setState(() {
      _isSpinning = true;
      _isRevealed = false;
      _rotation = 0;
      _selectedType = null;
      _selectedMessage = null;
    });

    _controller.reset();
    _controller.forward();
  }

  void _handleSpinComplete() {
    // Calculate which segment the pointer is pointing to
    final normalizedRotation = _rotation % 360;
    final totalItems = _truthItems.length + _dareItems.length;
    final segmentAngle = 360.0 / totalItems;
    final targetStartAngle = (360 - normalizedRotation) % 360;
    
    int segmentIndex = 0;
    for (int i = 0; i < totalItems; i++) {
      final startAngle = (i * segmentAngle) % 360;
      final endAngle = ((i + 1) * segmentAngle) % 360;
      
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

    // Determine if it's truth or dare (alternating)
    final isTruth = segmentIndex % 2 == 0;

    setState(() {
      _isSpinning = false;
    });

    // Get available items
    List<int> availableIndices;
    if (isTruth) {
      availableIndices = List.generate(
        _truthItems.length,
        (index) => index,
      ).where((index) => !_usedTruthIndices.contains(index)).toList();
    } else {
      availableIndices = List.generate(
        _dareItems.length,
        (index) => index,
      ).where((index) => !_usedDareIndices.contains(index)).toList();
    }

    if (availableIndices.isEmpty) {
      // Try the other type if current type is exhausted
      if (isTruth) {
        availableIndices = List.generate(
          _dareItems.length,
          (index) => index,
        ).where((index) => !_usedDareIndices.contains(index)).toList();
        if (availableIndices.isNotEmpty) {
          final selectedIndex = availableIndices[_random.nextInt(availableIndices.length)];
          _usedDareIndices.add(selectedIndex);
          _selectedType = 'dare';
          _selectedMessage = _dareItems[selectedIndex];
        }
      } else {
        availableIndices = List.generate(
          _truthItems.length,
          (index) => index,
        ).where((index) => !_usedTruthIndices.contains(index)).toList();
        if (availableIndices.isNotEmpty) {
          final selectedIndex = availableIndices[_random.nextInt(availableIndices.length)];
          _usedTruthIndices.add(selectedIndex);
          _selectedType = 'truth';
          _selectedMessage = _truthItems[selectedIndex];
        }
      }
    } else {
      final selectedIndex = availableIndices[_random.nextInt(availableIndices.length)];
      if (isTruth) {
        _usedTruthIndices.add(selectedIndex);
        _selectedType = 'truth';
        _selectedMessage = _truthItems[selectedIndex];
      } else {
        _usedDareIndices.add(selectedIndex);
        _selectedType = 'dare';
        _selectedMessage = _dareItems[selectedIndex];
      }
    }

    if (_selectedMessage != null) {
      // Start reveal animation
      _revealController.forward(from: 0);
      setState(() {
        _isRevealed = true;
      });
    }
  }

  void _resetReveal() {
    setState(() {
      _isRevealed = false;
      _selectedType = null;
      _selectedMessage = null;
    });
    _revealController.reset();
    
    // Move to next user after closing reveal
    _moveToNextUser();
  }
  
  void _moveToNextUser() {
    setState(() {
      _currentUserIndex = (_currentUserIndex + 1) % widget.users.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create segments list alternating between truth and dare
    final segments = <String>[];
    final maxCount = math.max(_truthItems.length, _dareItems.length);
    for (int i = 0; i < maxCount; i++) {
      if (i < _truthItems.length) segments.add('Truth');
      if (i < _dareItems.length) segments.add('Dare');
    }

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
                  Text(
                    '${widget.level} Level',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final maxHeight = constraints.maxHeight;
                  final screenSize = math.min(maxWidth, maxHeight);
                  final isLargeScreen = screenSize > 600;
                  final margin = isLargeScreen ? 20.0 : 12.0;
                  final arrowHeight = isLargeScreen ? 40.0 : 28.0;

                  // Calculate available space
                  final availableWidth = maxWidth - (margin * 2);
                  final availableHeight = maxHeight - arrowHeight - (margin * 2);

                  // Use more of the screen for better coverage
                  final widthMultiplier = isLargeScreen ? 0.8 : 0.95;
                  final heightMultiplier = isLargeScreen ? 0.8 : 0.95;
                  
                  final spinnerSize = math.min(
                    availableWidth * widthMultiplier,
                    availableHeight * heightMultiplier,
                  );
                  final finalSize = math.max(230.0, spinnerSize);

                  final buttonSize = finalSize * 0.25;
                  final arrowWidth = finalSize * 0.22;
                  final arrowHeightSize = finalSize * 0.18;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 80 : 16,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                      // Users list - similar to multiplayer
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
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Current user turn text
                      Text(
                        '${widget.users[_currentUserIndex]}' "'s Turn",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Spinner with reveal overlay - centered
                      Center(
                        child: Container(
                          height: finalSize + 50,
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
                                painter: TruthDareWheelPainter(segments: segments),
                              ),
                            ),
                            // Pointer
                            Positioned(
                              top: 10,
                              child: Container(
                                width: arrowWidth,
                                height: arrowHeightSize,
                                child: CustomPaint(
                                  size: Size(arrowWidth, arrowHeightSize),
                                  painter: TruthDarePointerPainter(),
                                ),
                              ),
                            ),
                            // Center Button - only enabled for current user when not spinning/revealed
                            GestureDetector(
                              onTap: (_isSpinning || _isRevealed) ? null : _spin,
                              child: Opacity(
                                opacity: (_isSpinning || _isRevealed) ? 0.5 : 1.0,
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
                            ),
                            // Reveal animation overlay on spinner
                            if (_isRevealed && _selectedMessage != null)
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
                                      child: Container(
                                          width: finalSize * 1.2,
                                          height: finalSize * 1.2,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                (_selectedType == 'truth'
                                                        ? const Color(0xFF00B894)
                                                        : const Color(0xFFFF6B35))
                                                    .withOpacity(0.95),
                                                (_selectedType == 'truth'
                                                        ? const Color(0xFF00B894)
                                                        : const Color(0xFFFF6B35))
                                                    .withOpacity(0.8),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (_selectedType == 'truth'
                                                        ? const Color(0xFF00B894)
                                                        : const Color(0xFFFF6B35))
                                                    .withOpacity(0.5),
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
                                                    _selectedType == 'truth' ? '💚' : '🧡',
                                                    style: TextStyle(fontSize: finalSize * 0.15),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Type text with animation
                                                FadeTransition(
                                                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                                    CurvedAnimation(
                                                      parent: _revealController,
                                                      curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _selectedType == 'truth' ? 'TRUTH' : 'DARE',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: finalSize * 0.12,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 3,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black.withOpacity(0.5),
                                                          blurRadius: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                // Message with animation
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
                                                      _selectedMessage!,
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
                                                          'Close',
                                                          style: TextStyle(
                                                            color: _selectedType == 'truth'
                                                                ? const Color(0xFF00B894)
                                                                : const Color(0xFFFF6B35),
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
                                    );
                                  },
                                ),
                          ],
                        ),
                      ),
                    ),
                      const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TruthDareWheelPainter extends CustomPainter {
  final List<String> segments;

  TruthDareWheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final borderWidth = 4.0;
    final radius = (size.width / 2) - (borderWidth / 2);

    if (segments.isEmpty) return;

    final segmentAngle = 360.0 / segments.length;

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final startAngle = (i * segmentAngle - 90) * math.pi / 180;
      final endAngle = ((i + 1) * segmentAngle - 90) * math.pi / 180;
      final sweepAngle = endAngle - startAngle;

      final paint = Paint()
        ..color = segment == 'Truth'
            ? const Color(0xFF00B894)
            : const Color(0xFFFF6B35)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
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
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.82;
      final text = segment;

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
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
    }

    // Outer circle border
    final circleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, circleBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TruthDarePointerPainter extends CustomPainter {
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

