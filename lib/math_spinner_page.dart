import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_page.dart';
import 'sound_vibration_helper.dart';
import 'ad_helper.dart';
import 'spinner_colors.dart';
import 'app_localizations_helper.dart';
import 'multiplayer_results_page.dart';

// Global failure probability count - change this value to adjust failure probability
const int _failProbabilityCount = 0;

class MathSpinnerPage extends StatefulWidget {
  final List<String> users;

  const MathSpinnerPage({super.key, required this.users});

  @override
  State<MathSpinnerPage> createState() => _MathSpinnerPageState();
}

class _MathSpinnerPageState extends State<MathSpinnerPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _revealController;
  double _rotation = 0; // in degrees
  double _randomOffset = 0;
  bool _isSpinning = false;
  bool _isWaitingForNextTurn = false;
  late List<SegmentInfo> _segments;
  late List<Color> _segmentColors;
  final math.Random _random = math.Random();

  // Reveal animation state
  bool _isRevealed = false;
  int? _selectedNumber;
  bool _isCorrectAnswer = false;

  // Game state
  int _currentUserIndex = 0;
  late List<String> _displayUsers;
  bool _isSinglePlayer = false;
  Set<int> _winners = {}; // Track users who got correct answers (by index)

  // Score tracking
  Map<String, int> _scores = {}; // Total scores per user
  Map<int, Map<String, int>> _roundScores = {}; // Scores per round
  int _currentRound = 1;

  // Failure probability tracking per user
  Map<String, int> _userFailureCount = {};

  // Math question
  String _mathQuestion = '';
  int _correctAnswer = 0;
  int _num1 = 0;
  int _num2 = 0;
  String _operator = '+';

  @override
  void initState() {
    super.initState();

    // Check if single player mode
    _isSinglePlayer = widget.users.length == 1 && widget.users[0] == 'Player';

    // For single player, change "Player" to "You" and add "Computer"
    if (_isSinglePlayer) {
      _displayUsers = ['You', 'Computer'];
    } else {
      _displayUsers = List.from(widget.users);
    }

    // Initialize failure count for all users
    for (var user in _displayUsers) {
      _userFailureCount[user] = 0;
      _scores[user] = 0;
    }
    // Initialize round scores
    _roundScores[1] = {};
    for (var user in _displayUsers) {
      _roundScores[1]![user] = 0;
    }

    // Initialize animation controllers
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Add listener to update rotation smoothly during animation
    _controller.addListener(() {
      setState(() {
        final curvedValue = Curves.decelerate.transform(_controller.value);
        _rotation = (curvedValue * 360 * 6) + _randomOffset; // 6 full rotations

        // Calculate speed based on curve derivative (rate of change)
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
        if (mounted) {
          _onSpinComplete();
        }
      }
    });

    // Generate math question and spinner
    _generateMathQuestion();
    _generateSpinnerSegments();

    // Preload interstitial ad for leave game
    InterstitialAdHelper.loadInterstitialAd();
    // Preload rewarded ad for game results
    RewardedAdHelper.loadRewardedAd();

    // If single player and it's Computer's turn, auto-spin
    if (_isSinglePlayer && _displayUsers[_currentUserIndex] == 'Computer') {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isSpinning && !_isRevealed && !_isWaitingForNextTurn) {
          _spin(isAutoSpin: true);
        }
      });
    }
  }

  void _generateMathQuestion() {
    // Generate random math question with result between 1-100
    while (true) {
      final operation = _random.nextInt(4); // 0: +, 1: -, 2: *, 3: /

      if (operation == 0) {
        // Addition
        _num1 = _random.nextInt(90) + 1; // 1-90
        _num2 = _random.nextInt(100 - _num1) + 1; // 1 to (100 - num1)
        _correctAnswer = _num1 + _num2;
        _operator = '+';
      } else if (operation == 1) {
        // Subtraction
        _num1 = _random.nextInt(99) + 2; // 2-100
        _num2 = _random.nextInt(_num1 - 1) + 1; // 1 to (num1 - 1)
        _correctAnswer = _num1 - _num2;
        _operator = '-';
      } else if (operation == 2) {
        // Multiplication
        _num1 = _random.nextInt(10) + 1; // 1-10
        _num2 = _random.nextInt(10) + 1; // 1-10
        _correctAnswer = _num1 * _num2;
        if (_correctAnswer > 100) continue; // Retry if result > 100
        _operator = '*';
      } else {
        // Division
        _num2 = _random.nextInt(10) + 1; // 1-10
        _correctAnswer = _random.nextInt(10) + 1; // 1-10
        _num1 = _correctAnswer * _num2; // Ensure integer result
        if (_num1 > 100) continue; // Retry if num1 > 100
        _operator = '/';
      }

      // Ensure result is between 1-100
      if (_correctAnswer >= 1 && _correctAnswer <= 100) {
        break;
      }
    }

    _mathQuestion = '$_num1 $_operator $_num2 = ?';
  }

  void _generateSpinnerSegments() {
    _segments = [];
    _segmentColors = [];

    // Create list of numbers: 1 correct answer + 9 random numbers
    final numbers = <int>[_correctAnswer];

    // Generate 9 random numbers that look similar to the answer
    // Make them within a range of ±20 from the correct answer, but ensure they're different
    while (numbers.length < 10) {
      int candidate;
      final range = 20; // Range around the correct answer
      final minVal = math.max(1, _correctAnswer - range);
      final maxVal = math.min(100, _correctAnswer + range);

      // Generate candidate in the range
      candidate = _random.nextInt(maxVal - minVal + 1) + minVal;

      // If we're running out of options, expand the range
      int attempts = 0;
      while ((candidate == _correctAnswer || numbers.contains(candidate)) &&
          attempts < 50) {
        candidate = _random.nextInt(maxVal - minVal + 1) + minVal;
        attempts++;
      }

      // If still can't find unique, try any number in 1-100
      if (numbers.contains(candidate) || candidate == _correctAnswer) {
        candidate = _random.nextInt(100) + 1;
        while (numbers.contains(candidate) || candidate == _correctAnswer) {
          candidate = _random.nextInt(100) + 1;
        }
      }

      numbers.add(candidate);
    }

    // Shuffle the numbers
    numbers.shuffle(_random);

    // Create segments
    for (int i = 0; i < 10; i++) {
      final number = numbers[i];
      final isCorrect = number == _correctAnswer;

      // Assign color
      Color segmentColor;
      if (isCorrect) {
        // Use a distinct color for correct answer (green-ish)
        segmentColor = const Color(0xFF4CAF50);
      } else {
        // Use random color from spinner colors
        segmentColor =
            SpinnerColors.segmentColors[i % SpinnerColors.segmentColors.length];
      }

      _segmentColors.add(segmentColor);
      _segments.add(
        SegmentInfo(
          value: number.toString(),
          color: segmentColor,
          isCorrect: isCorrect,
        ),
      );
    }
  }

  // Calculate speed based on animation value (0.0 to 1.0)
  double _calculateSpeed(double animationValue) {
    // Use the derivative of the decelerate curve to determine speed
    // At the start (0.0), speed is high (1.0)
    // At the end (1.0), speed is low (0.0)
    // We approximate the derivative by checking the rate of change
    if (animationValue < 0.1) {
      return 1.0; // Maximum speed at start
    } else if (animationValue < 0.3) {
      return 0.8; // Fast
    } else if (animationValue < 0.6) {
      return 0.5; // Medium
    } else if (animationValue < 0.8) {
      return 0.3; // Slow
    } else {
      return 0.1; // Very slow near end
    }
  }

  @override
  void dispose() {
    // Stop continuous sound when disposing
    SoundVibrationHelper.stopContinuousSound();
    _controller.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _spin({bool isAutoSpin = false}) {
    if (_isSpinning || _isRevealed || _isWaitingForNextTurn) return;

    // Skip if current user is already a winner
    if (_winners.contains(_currentUserIndex)) {
      _moveToNextUser();
      return;
    }

    // Only allow current user to spin (unless it's an auto-spin for computer)
    if (!isAutoSpin &&
        _isSinglePlayer &&
        _displayUsers[_currentUserIndex] == 'Computer') {
      // Computer's turn - should be handled by auto-spin only
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    // Play initial sound and vibration, then start continuous sound
    SoundVibrationHelper.playSpinEffects();
    SoundVibrationHelper.startContinuousSound();

    // Check failure probability logic
    final currentUser = _displayUsers[_currentUserIndex];
    final failureCount = _userFailureCount[currentUser] ?? 0;
    final shouldForceCorrect = failureCount >= _failProbabilityCount;

    if (shouldForceCorrect) {
      // Force spinner to land on correct answer
      // Find the correct answer segment index
      int correctSegmentIndex = -1;
      for (int i = 0; i < _segments.length; i++) {
        if (_segments[i].isCorrect) {
          correctSegmentIndex = i;
          break;
        }
      }

      if (correctSegmentIndex != -1) {
        // Calculate the angle needed to land on the correct segment
        final segmentAngle = 360.0 / _segments.length;
        final correctSegmentStartAngle = correctSegmentIndex * segmentAngle;
        // Add a small offset to land in the middle of the segment
        final targetAngle = correctSegmentStartAngle + (segmentAngle / 2);
        // Convert to rotation offset (accounting for pointer at top)
        _randomOffset = (360 - targetAngle) % 360;
      } else {
        // Fallback to random if correct segment not found
        _randomOffset = _random.nextDouble() * 360;
      }
    } else {
      // Random rotation offset (0-360 degrees) to land on a random segment
      _randomOffset = _random.nextDouble() * 360;
    }

    _controller.reset();
    _controller.forward();
  }

  void _onSpinComplete() {
    // Calculate which segment the pointer is pointing to
    // The pointer is at the top, pointing down (-90 degrees in canvas coordinates)
    // Normalize rotation to 0-360 range
    final normalizedRotation = _rotation % 360;

    // Find which segment's start angle equals (360 - normalizedRotation) mod 360
    // This is the segment that is now at the top after rotation
    final targetStartAngle = (360 - normalizedRotation) % 360;

    // Find the segment that contains this start angle
    int segmentIndex = 0;
    final segmentAngle = 360.0 / _segments.length;

    for (int i = 0; i < _segments.length; i++) {
      final startAngle = i * segmentAngle;
      final endAngle = (i + 1) * segmentAngle;

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

    final selectedSegment = _segments[segmentIndex];
    final selectedValue = int.tryParse(selectedSegment.value) ?? 0;
    final isCorrect = selectedSegment.isCorrect;

    // Show reveal animation first
    setState(() {
      _selectedNumber = selectedValue;
      _isCorrectAnswer = isCorrect;
      _isRevealed = true;
    });

    // Start reveal animation
    _revealController.forward(from: 0).then((_) {
      // After reveal animation completes, wait a bit then check result
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        // Check if correct answer
        final currentUser = _displayUsers[_currentUserIndex];
        if (isCorrect) {
          // Reset failure count to 0 when user gets correct answer
          _userFailureCount[currentUser] = 0;

          // Add user to winners set (skip them in future turns)
          _winners.add(_currentUserIndex);

          // Update scores
          _scores[currentUser] = (_scores[currentUser] ?? 0) + 1;
          _roundScores[_currentRound]![currentUser] =
              (_roundScores[_currentRound]![currentUser] ?? 0) + 1;

          // Check if all other users have won (last user loses)
          if (_winners.length == _displayUsers.length - 1) {
            // All other users won - last user lost, game ends immediately
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _navigateToResults();
              }
            });
            return;
          }

          // Generate new math question when user wins
          _generateMathQuestion();
          _generateSpinnerSegments();

          // Continue game - move to next user (winner will be skipped)
          _moveToNextUser();
        } else {
          // Wrong answer - increment failure count for this user
          _userFailureCount[currentUser] =
              (_userFailureCount[currentUser] ?? 0) + 1;

          // Game ends when user gets wrong answer - navigate to results
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _navigateToResults();
            }
          });
        }
      });
    });
  }

  void _moveToNextUser() {
    // Reset all states first, including spinner rotation
    setState(() {
      _isRevealed = false;
      _selectedNumber = null;
      _isCorrectAnswer = false;
      _isWaitingForNextTurn = true;
      _isSpinning = false; // Ensure spinning is reset
      _rotation = 0; // Reset spinner rotation visually
      _randomOffset = 0; // Reset random offset
    });
    _revealController.reset();
    _controller.reset(); // Reset animation controller

    // Move to next user after a delay to ensure state is updated
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      // Find next user who hasn't won yet
      int attempts = 0;
      int nextUserIndex = (_currentUserIndex + 1) % _displayUsers.length;

      // Skip winners - find next non-winner user
      while (_winners.contains(nextUserIndex) &&
          attempts < _displayUsers.length) {
        nextUserIndex = (nextUserIndex + 1) % _displayUsers.length;
        attempts++;
      }

      // If all other users have won, the last user automatically loses
      if (_winners.length == _displayUsers.length - 1) {
        // All other users won - last user lost, game ends
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _navigateToResults();
          }
        });
        return;
      }

      // If all users have won (shouldn't happen, but handle it)
      if (_winners.contains(nextUserIndex) &&
          _winners.length == _displayUsers.length) {
        // All users won - navigate to results
        _navigateToResults();
        return;
      }

      setState(() {
        _currentUserIndex = nextUserIndex;
        _isWaitingForNextTurn = false;
        _isRevealed = false; // Ensure revealed is false
        _isSpinning = false; // Ensure spinning is false
        _rotation = 0; // Ensure spinner is reset to 0 position
        _randomOffset = 0; // Reset offset for next spin
      });

      // If single player and it's Computer's turn, auto-spin
      if (_isSinglePlayer && _displayUsers[_currentUserIndex] == 'Computer') {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted &&
              !_isSpinning &&
              !_isRevealed &&
              !_isWaitingForNextTurn) {
            _spin(isAutoSpin: true);
          }
        });
      }
      // If single player and it's "You"'s turn, wait for manual spin (no auto-spin)
    });
  }

  Future<void> _navigateToResults() async {
    // Show rewarded ad before navigating to results page
    await RewardedAdHelper.showRewardedAd(
      onRewarded: () {
        // User earned reward (ad was watched)
        debugPrint('User earned reward - viewing results');
      },
      onAdClosed: () {
        // Navigate after ad is closed
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MultiplayerResultsPage(
              users: _displayUsers,
              rounds: _currentRound,
              roundScores: _roundScores,
              totalScores: Map<String, int>.from(_scores),
            ),
          ),
        );
      },
    );
  }

  Future<void> _goHome() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final dialogL10n = AppLocalizationsHelper.of(context);
        return AlertDialog(
          backgroundColor: const Color(0xFF3D3D5C),
          title: Text(
            dialogL10n.leaveGame,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            dialogL10n.leaveGameMessage,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                dialogL10n.cancel,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE5A6F),
                foregroundColor: Colors.white,
              ),
              child: Text(
                dialogL10n.leave,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Only navigate if user confirmed
    if (shouldLeave == true && mounted) {
      // Show interstitial ad before leaving
      await InterstitialAdHelper.showInterstitialAd(
        onAdClosed: () {
          // Navigate after ad is closed
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goHome();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2D2D44),
        body: SafeArea(
          child: Column(
            children: [
              // Fixed header with back button and title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => BackArrowAd.handleBackButton(
                            context: context,
                            onBack: () => _goHome(),
                          ),
                        ),
                      ),
                    ),
                    // Title - centered on screen
                    Text(
                      l10n.mathSpinner,
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
              // Main content
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final maxHeight = constraints.maxHeight;
                    final isLargeScreen = maxWidth > 600;

                    // Calculate spinner size
                    final availableWidth =
                        maxWidth - (isLargeScreen ? 160 : 32);
                    final availableHeight =
                        maxHeight - 200; // Reserve space for UI

                    final spinnerSize = math.min(
                      availableWidth * 0.9,
                      availableHeight * 0.6,
                    );
                    final finalSize = math.max(230.0, spinnerSize);
                    final buttonSize = finalSize * 0.27;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 80 : 16,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Users list - without score
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: _displayUsers.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final user = entry.value;
                                final isCurrentUser =
                                    index == _currentUserIndex;

                                return Container(
                                  width:
                                      (maxWidth - 60) /
                                          (_displayUsers.length > 3
                                              ? 3
                                              : _displayUsers.length) -
                                      8,
                                  constraints: const BoxConstraints(
                                    minWidth: 100,
                                    maxWidth: 200,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? const Color(0xFF6C5CE7)
                                        : const Color(0xFF3D3D5C),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isCurrentUser
                                        ? Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user == 'You'
                                            ? l10n.you
                                            : (user == 'Computer'
                                                  ? l10n.computer
                                                  : user),
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
                            l10n.turn(
                              _displayUsers[_currentUserIndex] == 'You'
                                  ? l10n.you
                                  : (_displayUsers[_currentUserIndex] ==
                                            'Computer'
                                        ? l10n.computer
                                        : _displayUsers[_currentUserIndex]),
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Math Question Section
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D3D5C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF6C5CE7),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _mathQuestion,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Spinner Wheel
                          Center(
                            child: Container(
                              height: finalSize + 40,
                              width: finalSize + 40,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Spinner wheel
                                  AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle:
                                            _rotation *
                                            math.pi /
                                            180, // Convert degrees to radians
                                        child: CustomPaint(
                                          size: Size(finalSize, finalSize),
                                          painter: _MathWheelPainter(
                                            segments: _segments,
                                            colors: _segmentColors,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Center button
                                  GestureDetector(
                                    onTap:
                                        (_isRevealed ||
                                            _isSpinning ||
                                            _isWaitingForNextTurn ||
                                            (_isSinglePlayer &&
                                                _displayUsers[_currentUserIndex] ==
                                                    'Computer'))
                                        ? null
                                        : _spin,
                                    child: Opacity(
                                      opacity:
                                          (_isWaitingForNextTurn ||
                                              _isRevealed ||
                                              _isSpinning ||
                                              (_isSinglePlayer &&
                                                  _displayUsers[_currentUserIndex] ==
                                                      'Computer'))
                                          ? 0.5
                                          : 1.0,
                                      child: Image.asset(
                                        'assets/images/spin_logo.png',
                                        width: buttonSize,
                                        height: buttonSize,
                                      ),
                                    ),
                                  ),
                                  // Reveal animation overlay (same as multiplayer)
                                  if (_isRevealed && _selectedNumber != null)
                                    AnimatedBuilder(
                                      animation: _revealController,
                                      builder: (context, child) {
                                        return FadeTransition(
                                          opacity: _revealController,
                                          child: ScaleTransition(
                                            scale:
                                                Tween<double>(
                                                  begin: 0.0,
                                                  end: 1.0,
                                                ).animate(
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
                                                  colors: _isCorrectAnswer
                                                      ? [
                                                          const Color(
                                                            0xFFFFF9C4,
                                                          ).withOpacity(
                                                            0.95,
                                                          ), // Light yellow for correct
                                                          const Color(
                                                            0xFFFFF59D,
                                                          ).withOpacity(
                                                            0.9,
                                                          ), // Slightly darker yellow
                                                        ]
                                                      : [
                                                          const Color(
                                                            0xFFEF5350,
                                                          ).withOpacity(
                                                            0.95,
                                                          ), // Light red for wrong
                                                          const Color(
                                                            0xFFE53935,
                                                          ).withOpacity(
                                                            0.9,
                                                          ), // Darker red
                                                        ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        (_isCorrectAnswer
                                                                ? const Color(
                                                                    0xFFFFF59D,
                                                                  )
                                                                : const Color(
                                                                    0xFFE53935,
                                                                  ))
                                                            .withOpacity(0.5),
                                                    blurRadius: 30,
                                                    spreadRadius: 10,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Label with animation
                                                    FadeTransition(
                                                      opacity:
                                                          Tween<double>(
                                                            begin: 0.0,
                                                            end: 1.0,
                                                          ).animate(
                                                            CurvedAnimation(
                                                              parent:
                                                                  _revealController,
                                                              curve:
                                                                  const Interval(
                                                                    0.0,
                                                                    0.5,
                                                                    curve: Curves
                                                                        .easeIn,
                                                                  ),
                                                            ),
                                                          ),
                                                      child: Text(
                                                        _isCorrectAnswer
                                                            ? l10n.earned
                                                            : l10n.selected,
                                                        style: TextStyle(
                                                          color:
                                                              _isCorrectAnswer
                                                              ? Colors.black87
                                                              : Colors.white,
                                                          fontSize:
                                                              finalSize * 0.08,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 3,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    // Number with animation
                                                    ScaleTransition(
                                                      scale:
                                                          Tween<double>(
                                                            begin: 0.0,
                                                            end: 1.0,
                                                          ).animate(
                                                            CurvedAnimation(
                                                              parent:
                                                                  _revealController,
                                                              curve: const Interval(
                                                                0.2,
                                                                0.7,
                                                                curve: Curves
                                                                    .elasticOut,
                                                              ),
                                                            ),
                                                          ),
                                                      child: Text(
                                                        '$_selectedNumber',
                                                        style: TextStyle(
                                                          color:
                                                              _isCorrectAnswer
                                                              ? Colors.black
                                                              : Colors.white,
                                                          fontSize:
                                                              finalSize * 0.25,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          shadows: [
                                                            Shadow(
                                                              color:
                                                                  (_isCorrectAnswer
                                                                          ? Colors.black
                                                                          : Colors.black)
                                                                      .withOpacity(
                                                                        0.2,
                                                                      ),
                                                              blurRadius: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // Status text with animation
                                                    FadeTransition(
                                                      opacity:
                                                          Tween<double>(
                                                            begin: 0.0,
                                                            end: 1.0,
                                                          ).animate(
                                                            CurvedAnimation(
                                                              parent:
                                                                  _revealController,
                                                              curve:
                                                                  const Interval(
                                                                    0.5,
                                                                    0.8,
                                                                    curve: Curves
                                                                        .easeIn,
                                                                  ),
                                                            ),
                                                          ),
                                                      child: Text(
                                                        _isCorrectAnswer
                                                            ? 'Correct!'
                                                            : 'Wrong Answer',
                                                        style: TextStyle(
                                                          color:
                                                              _isCorrectAnswer
                                                              ? Colors.black87
                                                              : Colors.white,
                                                          fontSize:
                                                              finalSize * 0.07,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                          const SizedBox(height: 40),
                        ],
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
      ),
    );
  }
}

// Custom painter for math spinner wheel
class _MathWheelPainter extends CustomPainter {
  final List<SegmentInfo> segments;
  final List<Color> colors;

  _MathWheelPainter({required this.segments, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * math.pi / segments.length;

    for (int i = 0; i < segments.length; i++) {
      final startAngle = i * segmentAngle - math.pi / 2;
      final endAngle = (i + 1) * segmentAngle - math.pi / 2;

      // Draw segment
      final paint = Paint()
        ..color = segments[i].color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + (endAngle - startAngle) / 2;
      final textRadius = radius * 0.82;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: segments[i].value,
          style: TextStyle(
            color: segments[i].isCorrect ? Colors.black : Colors.white,
            fontSize: radius * 0.15,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();

      // Draw stars on all segments
      final starRadius = radius * 0.5;
      final starX = center.dx + starRadius * math.cos(textAngle);
      final starY = center.dy + starRadius * math.sin(textAngle);
      _drawStar(canvas, Offset(starX, starY), 8, Colors.white.withOpacity(0.6));
    }

    // Draw outer circle border
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
  bool shouldRepaint(_MathWheelPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

// Segment info class
class SegmentInfo {
  final String value;
  final Color color;
  final bool isCorrect;

  SegmentInfo({
    required this.value,
    required this.color,
    required this.isCorrect,
  });
}
