import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'home_page.dart';
import 'multiplayer_results_page.dart';
import 'sound_vibration_helper.dart';
import 'ad_helper.dart';
import 'spinner_colors.dart';
import 'app_localizations_helper.dart';
import 'app_theme.dart';
import 'package:confetti/confetti.dart';
import 'animated_gradient_background.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _revealController;
  double _rotation = 0;
  double _randomOffset = 0;
  bool _isSpinning = false;
  bool _isWaitingForNextTurn = false;
  late List<SegmentInfo> _segments; // Track segment info including jackpot
  late List<Color> _segmentColors; // Store assigned colors to avoid duplicates
  final math.Random _random = math.Random();

  // Reveal animation state
  bool _isRevealed = false;
  int? _earnedPoints;
  String? _earnedNumber;

  // Game state
  int _currentRound = 1;
  int _currentUserIndex = 0;
  Map<String, int> _scores = {};
  Map<int, Map<String, int>> _roundScores = {}; // Track scores per round
  late List<String>
  _displayUsers; // Users to display (may include Bot for single player)
  bool _isSinglePlayer = false; // Track if this is single player mode

  // Confetti controller for jackpot celebration
  late ConfettiController _confettiController;
  bool _showJackpotPopup = false;

  // Jackpot probability tracking
  int _randomJackpotCount =
      0; // Random number 1-10, resets when jackpot appears
  int _jackpotNotShowedCount =
      0; // Count of turns without jackpot, resets when jackpot appears

  @override
  void initState() {
    super.initState();

    // Check if single player mode (only "Player" in the list)
    _isSinglePlayer = widget.users.length == 1 && widget.users[0] == 'Player';

    // For single player, change "Player" to "You" and add "Computer"
    // Note: We'll use localized strings when displaying, but keep English keys for logic
    if (_isSinglePlayer) {
      _displayUsers = ['You', 'Computer'];
    } else {
      _displayUsers = List.from(widget.users);
    }

    // Initialize scores
    for (var user in _displayUsers) {
      _scores[user] = 0;
    }
    // Initialize round scores
    _roundScores[1] = {};
    for (var user in _displayUsers) {
      _roundScores[1]![user] = 0;
    }

    // Initialize jackpot probability tracking
    _randomJackpotCount = _random.nextInt(10) + 1; // Random 1-10
    _jackpotNotShowedCount = 0;

    // Generate random two-digit numbers from specific ranges
    final twoDigitNumbers = <String>[];

    // First: 1-9 (formatted as 01-09)
    final firstNumber = _random.nextInt(9) + 1; // 1-9
    twoDigitNumbers.add(firstNumber.toString().padLeft(2, '0'));

    // Second: 11-19
    final secondNumber = _random.nextInt(9) + 11; // 11-19
    twoDigitNumbers.add(secondNumber.toString());

    // Third: 21-29
    final thirdNumber = _random.nextInt(9) + 21; // 21-29
    twoDigitNumbers.add(thirdNumber.toString());

    // Fourth: 31-39
    final fourthNumber = _random.nextInt(9) + 31; // 31-39
    twoDigitNumbers.add(fourthNumber.toString());

    // Fifth: 41-49
    final fifthNumber = _random.nextInt(9) + 41; // 41-49
    twoDigitNumbers.add(fifthNumber.toString());

    // Sixth: 51-59
    final sixthNumber = _random.nextInt(9) + 51; // 51-59
    twoDigitNumbers.add(sixthNumber.toString());

    // Seventh: 61-69
    final seventhNumber = _random.nextInt(9) + 61; // 61-69
    twoDigitNumbers.add(seventhNumber.toString());

    // Eighth: 71-79
    final eighthNumber = _random.nextInt(9) + 71; // 71-79
    twoDigitNumbers.add(eighthNumber.toString());

    // Ninth: 81-89
    final ninthNumber = _random.nextInt(9) + 81; // 81-89
    twoDigitNumbers.add(ninthNumber.toString());

    // Tenth: 91-99
    final tenthNumber = _random.nextInt(9) + 91; // 91-99
    twoDigitNumbers.add(tenthNumber.toString());

    // Shuffle the two-digit numbers
    twoDigitNumbers.shuffle(_random);

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
        // Add jackpot segment (10 degrees - very thin!) - worth 100 points
        _segments.add(
          SegmentInfo(
            value: '100',
            isJackpot: true,
            startAngle: currentAngle,
            endAngle: currentAngle + jackpotAngle,
          ),
        );
        currentAngle += jackpotAngle;
      } else {
        // Add regular segment (35 degrees) with two-digit number
        final itemIndex = i > jackpotPosition ? i - 1 : i;
        _segments.add(
          SegmentInfo(
            value: twoDigitNumbers[itemIndex],
            isJackpot: false,
            startAngle: currentAngle,
            endAngle: currentAngle + regularAngle,
          ),
        );
        currentAngle += regularAngle;
      }
    }

    // Initialize colors without duplicates (11 segments: 10 regular + 1 jackpot)
    _initializeColors();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Initialize confetti controller - longer duration for celebration
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );

    _controller.addListener(() {
      setState(() {
        final curvedValue = Curves.decelerate.transform(_controller.value);
        _rotation = (curvedValue * 360 * 6) + _randomOffset;

        // Calculate speed based on curve derivative (rate of change)
        final speed = _calculateSpeed(_controller.value);
        SoundVibrationHelper.updateSpeed(speed);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _handleSpinComplete();
        });
        // Stop continuous sound when animation completes
        SoundVibrationHelper.stopContinuousSound();
      }
    });

    // Preload interstitial ad for leave game
    InterstitialAdHelper.loadInterstitialAd();
    // Preload rewarded ad for game results
    RewardedAdHelper.loadRewardedAd();
  }

  @override
  void dispose() {
    // Stop continuous sound when disposing
    SoundVibrationHelper.stopContinuousSound();
    _controller.dispose();
    _revealController.dispose();
    _confettiController.dispose();
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
    final selectedNumber = _segments[segmentIndex].value;
    final isJackpot = _segments[segmentIndex].isJackpot;

    // Show reveal animation first
    setState(() {
      _earnedPoints = points;
      _earnedNumber = selectedNumber;
      _isRevealed = true;
    });

    // Update jackpot probability tracking
    if (isJackpot) {
      // Jackpot appeared: reset both counters
      final newRandomCount = _random.nextInt(10) + 1; // New random 1-10
      setState(() {
        _randomJackpotCount = newRandomCount;
        _jackpotNotShowedCount = 0; // Reset to 0
      });
      debugPrint(
        'JACKPOT APPEARED! Resetting: randomJackpotCount = $newRandomCount, jackpotNotShowedCount = 0',
      );
    } else {
      // Jackpot didn't appear: increment counter
      setState(() {
        _jackpotNotShowedCount++;
      });
      debugPrint(
        'No jackpot. Incrementing: jackpotNotShowedCount = $_jackpotNotShowedCount (target: $_randomJackpotCount)',
      );
    }

    // Start reveal animation
    _revealController.forward(from: 0).then((_) {
      // If jackpot, show celebration confetti animation
      if (isJackpot) {
        setState(() {
          _showJackpotPopup = true;
        });
        _confettiController.play();
        // Auto-hide confetti after animation completes
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showJackpotPopup = false;
            });
            _confettiController.stop();
            // Continue with normal flow
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              _autoHideRevealAndFly();
            });
          }
        });
      } else {
        // After reveal animation completes, wait a bit then automatically show flying animation
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          _autoHideRevealAndFly();
        });
      }
    });
  }

  void _autoHideRevealAndFly() {
    // After reveal is closed, add points and move to next turn
    if (_earnedNumber != null && _earnedPoints != null) {
      final points = _earnedPoints!;
      final currentUser = _displayUsers[_currentUserIndex];
      _scores[currentUser] = (_scores[currentUser] ?? 0) + points;
      // Track round score
      _roundScores[_currentRound]![currentUser] =
          (_roundScores[_currentRound]![currentUser] ?? 0) + points;

      // Move to next turn
      setState(() {
        _isRevealed = false;
        _earnedPoints = null;
        _earnedNumber = null;
        _isWaitingForNextTurn = true;
      });
      _revealController.reset();

      // Move to next user or next round
      if (!mounted) return;

      if (_currentUserIndex < _displayUsers.length - 1) {
        // Next user in same round - reset spinner first
        _resetSpinnerForNextTurn();
        setState(() {
          _currentUserIndex++;
          _isWaitingForNextTurn = false;
        });

        // If single player mode and it's Bot's turn, auto-spin after a short delay
        if (_isSinglePlayer && _displayUsers[_currentUserIndex] == 'Computer') {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_isSpinning && !_isWaitingForNextTurn) {
              _spin();
            }
          });
        }
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
            for (var user in _displayUsers) {
              _roundScores[_currentRound]![user] = 0;
            }
          });

          // If single player mode and it's Bot's turn at start of round, auto-spin
          if (_isSinglePlayer &&
              _displayUsers[_currentUserIndex] == 'Computer') {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && !_isSpinning && !_isWaitingForNextTurn) {
                _spin();
              }
            });
          }
        } else {
          // Game complete - navigate to results page
          _navigateToResults();
        }
      }
    } else {
      setState(() {
        _isRevealed = false;
        _earnedPoints = null;
        _earnedNumber = null;
      });
      _revealController.reset();
    }
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
              rounds: widget.rounds,
              roundScores: _roundScores,
              totalScores: Map<String, int>.from(_scores),
            ),
          ),
        );
      },
    );
  }

  // Calculate speed based on animation value (0.0 to 1.0)
  double _calculateSpeed(double animationValue) {
    return (1.0 - animationValue).clamp(0.1, 1.0);
  }

  void _resetSpinnerForNextTurn() {
    // Hide reveal animation if still showing
    if (_isRevealed) {
      setState(() {
        _isRevealed = false;
        _earnedPoints = null;
        _earnedNumber = null;
      });
      _revealController.reset();
    }

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

    // Check if we need to force jackpot (jackpotNotShowedCount reached RandomJackpotCount)
    bool shouldForceJackpot = _jackpotNotShowedCount >= _randomJackpotCount;

    if (shouldForceJackpot) {
      debugPrint(
        'FORCING JACKPOT: jackpotNotShowedCount ($_jackpotNotShowedCount) >= randomJackpotCount ($_randomJackpotCount)',
      );
      // Force spinner to land on jackpot segment
      // Find the jackpot segment index
      int jackpotSegmentIndex = -1;
      for (int i = 0; i < _segments.length; i++) {
        if (_segments[i].isJackpot) {
          jackpotSegmentIndex = i;
          break;
        }
      }

      if (jackpotSegmentIndex != -1) {
        // Calculate the angle needed to land on the jackpot segment
        final segment = _segments[jackpotSegmentIndex];
        final segmentAngle = segment.endAngle - segment.startAngle;
        // Add a small offset to land in the middle of the segment
        final targetAngle = segment.startAngle + (segmentAngle / 2);
        // Convert to rotation offset (accounting for pointer at top)
        _randomOffset = (360 - targetAngle) % 360;
        debugPrint(
          'Jackpot segment found at index $jackpotSegmentIndex, targetAngle: $targetAngle, randomOffset: $_randomOffset',
        );
      } else {
        // Fallback to random if jackpot segment not found
        debugPrint('ERROR: Jackpot segment not found! Using random offset.');
        _randomOffset = _random.nextDouble() * 360;
      }
    } else {
      // Random rotation offset (0-360 degrees) to land on a random segment
      _randomOffset = _random.nextDouble() * 360;
      debugPrint(
        'Random spin: jackpotNotShowedCount ($_jackpotNotShowedCount) < randomJackpotCount ($_randomJackpotCount)',
      );
    }

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

  Future<void> _goHome() async {
    // Show confirmation dialog before leaving
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
    if (shouldLeave == true) {
      // Show interstitial ad before leaving
      await InterstitialAdHelper.showInterstitialAd(
        onAdClosed: () {
          // Navigate after ad is closed
          if (!mounted) return;
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          }
        },
      );
    }
  }

  void _initializeColors() {
    _segmentColors = [];

    // Assign colors sequentially (line-wise) from SpinnerColors
    // Skip jackpot segments (they use gold color in the painter)
    int colorIndex = 0;

    for (int i = 0; i < _segments.length; i++) {
      // Jackpot segments use gold color (handled in painter), so skip them here
      // For regular segments, assign colors sequentially
      if (!_segments[i].isJackpot) {
        Color assignedColor = SpinnerColors.getColor(colorIndex);

        // Ensure no adjacent duplicates
        if (i > 0 && _segmentColors.isNotEmpty) {
          final prevColor = _segmentColors[i - 1];
          // If current color matches previous, get next color
          if (assignedColor == prevColor) {
            colorIndex++;
            assignedColor = SpinnerColors.getColor(colorIndex);
          }
        }

        _segmentColors.add(assignedColor);
        colorIndex++;
      } else {
        // For jackpot, we still add a color to maintain index alignment
        // but it won't be used (painter uses gold for jackpot)
        _segmentColors.add(
          const Color(0xFFFFD700),
        ); // Gold (not used, but maintains alignment)
      }
    }

    // Ensure last segment doesn't match first (circular adjacency)
    if (_segmentColors.length > 1) {
      final lastIndex = _segmentColors.length - 1;
      // Only check if both are non-jackpot segments
      if (!_segments[0].isJackpot && !_segments[lastIndex].isJackpot) {
        if (_segmentColors[0] == _segmentColors[lastIndex]) {
          // Find a different color for the last segment
          final firstColor = _segmentColors[0];
          final secondToLastColor = _segmentColors[lastIndex - 1];

          // Try to find a color that's different from both first and second-to-last
          for (int i = 0; i < SpinnerColors.segmentColors.length; i++) {
            final candidateColor = SpinnerColors.segmentColors[i];
            if (candidateColor != firstColor &&
                candidateColor != secondToLastColor) {
              _segmentColors[lastIndex] = candidateColor;
              break;
            }
          }
        }
      }
    }
  }

  Color _getSegmentColor(int index) {
    // Return pre-assigned color for this segment
    return _segmentColors[index % _segmentColors.length];
  }

  // Helper widget for glossy card effect
  Widget _buildGlossyCard({
    required Widget child,
    double borderRadius = 16,
    Color? backgroundColor,
    Border? border,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(borderRadius),
            border:
                border ??
                Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F2687).withOpacity(0.07),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              child,
              // Glossy overlay effect
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Show confirmation dialog when user tries to swipe back
          _goHome();
        }
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: AppTheme.themeNotifier,
        builder: (context, isDark, _) {
          return AnimatedGradientBackground(
            child: Scaffold(
              backgroundColor:
                  Colors.transparent, // Transparent so gradient shows through
              body: Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Back button - left aligned with frosted glass effect
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: _goHome,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.6),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.8),
                                          blurRadius: 1,
                                          offset: const Offset(0, 1),
                                          blurStyle: BlurStyle.inner,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 16,
                                          sigmaY: 16,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Color(0xFF475569),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Title - centered
                              Text(
                                'Round $_currentRound / ${widget.rounds}',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              // Spacer for balance
                              const SizedBox(width: 40),
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
                              final availableHeight =
                                  maxHeight - arrowHeight - (margin * 2);

                              // Use more of the screen for better coverage
                              final widthMultiplier = isLargeScreen
                                  ? 0.8
                                  : 0.95;
                              final heightMultiplier = isLargeScreen
                                  ? 0.8
                                  : 0.95;

                              final spinnerSize = math.min(
                                availableWidth * widthMultiplier,
                                availableHeight * heightMultiplier,
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
                                    // Users list - similar to multiplayer
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
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

                                          // Get current round score for this user
                                          final currentRoundScore =
                                              _roundScores[_currentRound]?[user] ??
                                              0;

                                          return _buildGlossyCard(
                                            borderRadius: 16,
                                            backgroundColor: isCurrentUser
                                                ? const Color(
                                                    0xFF6366F1,
                                                  ).withOpacity(0.7)
                                                : Colors.white.withOpacity(0.3),
                                            border: isCurrentUser
                                                ? Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  )
                                                : Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.6),
                                                    width: 1,
                                                  ),
                                            child: Container(
                                              width:
                                                  (maxWidth - 60) /
                                                      (_displayUsers.length > 3
                                                          ? 3
                                                          : _displayUsers
                                                                .length) -
                                                  8,
                                              constraints: const BoxConstraints(
                                                minWidth: 100,
                                                maxWidth: 150,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    user == 'You'
                                                        ? l10n.you
                                                        : (user == 'Computer'
                                                              ? l10n.computer
                                                              : user),
                                                    style: const TextStyle(
                                                      color: Color(0xFF1E293B),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    l10n.score(
                                                      currentRoundScore
                                                          .toString(),
                                                    ),
                                                    style: const TextStyle(
                                                      color: Color(0xFF475569),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Current user turn text
                                    Text(
                                      l10n.turn(
                                        _displayUsers[_currentUserIndex] ==
                                                'You'
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
                                    // Spinner Wheel
                                    Center(
                                      child: Container(
                                        height:
                                            finalSize +
                                            50, // Fixed height to prevent cropping
                                        width: finalSize,
                                        margin: const EdgeInsets.all(20),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Wheel
                                            Transform.rotate(
                                              angle: _rotation * math.pi / 180,
                                              child: CustomPaint(
                                                size: Size(
                                                  finalSize,
                                                  finalSize,
                                                ),
                                                painter:
                                                    MultiplayerWheelPainter(
                                                      segments: _segments,
                                                      getSegmentColor:
                                                          _getSegmentColor,
                                                    ),
                                              ),
                                            ),
                                            // Center Spin Button
                                            GestureDetector(
                                              onTap:
                                                  (_isWaitingForNextTurn ||
                                                      _isRevealed ||
                                                      _isSpinning ||
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
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            // Reveal animation overlay on spinner
                                            if (_isRevealed &&
                                                _earnedPoints != null &&
                                                _earnedNumber != null)
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
                                                              parent:
                                                                  _revealController,
                                                              curve: Curves
                                                                  .elasticOut,
                                                            ),
                                                          ),
                                                      child: Container(
                                                        width: finalSize * 1.2,
                                                        height: finalSize * 1.2,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient: RadialGradient(
                                                            colors: [
                                                              const Color(
                                                                0xFFFFF9C4,
                                                              ).withOpacity(
                                                                0.95,
                                                              ), // Light yellow
                                                              const Color(
                                                                0xFFFFF59D,
                                                              ).withOpacity(
                                                                0.9,
                                                              ), // Slightly darker yellow
                                                            ],
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  const Color(
                                                                    0xFFFFF59D,
                                                                  ).withOpacity(
                                                                    0.5,
                                                                  ),
                                                              blurRadius: 30,
                                                              spreadRadius: 10,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              // Points label with animation
                                                              FadeTransition(
                                                                opacity:
                                                                    Tween<double>(
                                                                      begin:
                                                                          0.0,
                                                                      end: 1.0,
                                                                    ).animate(
                                                                      CurvedAnimation(
                                                                        parent:
                                                                            _revealController,
                                                                        curve: const Interval(
                                                                          0.0,
                                                                          0.5,
                                                                          curve:
                                                                              Curves.easeIn,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                child: Text(
                                                                  l10n.earned,
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize:
                                                                        finalSize *
                                                                        0.08,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    letterSpacing:
                                                                        3,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              // Number with animation
                                                              ScaleTransition(
                                                                scale:
                                                                    Tween<double>(
                                                                      begin:
                                                                          0.0,
                                                                      end: 1.0,
                                                                    ).animate(
                                                                      CurvedAnimation(
                                                                        parent:
                                                                            _revealController,
                                                                        curve: const Interval(
                                                                          0.2,
                                                                          0.7,
                                                                          curve:
                                                                              Curves.elasticOut,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                child: Text(
                                                                  _earnedNumber!,
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        finalSize *
                                                                        0.25,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    shadows: [
                                                                      Shadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(
                                                                              0.2,
                                                                            ),
                                                                        blurRadius:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              // Points text with animation
                                                              FadeTransition(
                                                                opacity:
                                                                    Tween<double>(
                                                                      begin:
                                                                          0.0,
                                                                      end: 1.0,
                                                                    ).animate(
                                                                      CurvedAnimation(
                                                                        parent:
                                                                            _revealController,
                                                                        curve: const Interval(
                                                                          0.5,
                                                                          0.8,
                                                                          curve:
                                                                              Curves.easeIn,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                child: Text(
                                                                  '${_earnedPoints} Points',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize:
                                                                        finalSize *
                                                                        0.07,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
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
                  // Banner Ad at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: const BannerAdWidget(),
                  ),
                  // Confetti overlay - starts from spinner center
                  if (_showJackpotPopup)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.center,
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirection:
                                0, // Start from center, will blast in all directions
                            blastDirectionality: BlastDirectionality
                                .explosive, // Blast in all directions
                            maxBlastForce: 10,
                            minBlastForce: 5,
                            emissionFrequency: 0.02,
                            numberOfParticles: 50,
                            gravity: 0.2,
                            shouldLoop: false,
                            colors: [
                              const Color(0xFFFFD700), // Gold
                              Colors.orange,
                              Colors.yellow,
                              Colors.amber,
                              Colors.deepOrange,
                              Colors.red,
                              Colors.pink,
                              Colors.purple,
                              Colors.blue,
                              Colors.cyan,
                              Colors.green,
                              Colors.lime,
                              Colors.teal,
                              Colors.indigo,
                              Colors.brown,
                              Colors.white,
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

  MultiplayerWheelPainter({
    required this.segments,
    required this.getSegmentColor,
  });

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
            : getSegmentColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw border - same thickness for all segments
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

      // Calculate appropriate font size for jackpot to fit in small segment
      double fontSize = segment.isJackpot ? 16 : 24;
      if (segment.isJackpot) {
        // Try to fit "100" in the small jackpot segment
        final testPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        testPainter.layout();
        // If text is too wide for the segment, reduce font size
        final segmentWidth = radius * segmentAngle;
        if (testPainter.width > segmentWidth * 0.8) {
          fontSize = (segmentWidth * 0.8 / text.length).clamp(10.0, 16.0);
        }
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: segment.isJackpot ? Colors.black : Colors.white,
            fontSize: fontSize,
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
        _drawStar(
          canvas,
          Offset(starX, starY),
          8,
          Colors.white.withOpacity(0.6),
        );
      } else {
        // Draw sparkle effect for jackpot
        final sparkleRadius = radius * 0.5;
        final sparkleX = center.dx + sparkleRadius * math.cos(textAngle);
        final sparkleY = center.dy + sparkleRadius * math.sin(textAngle);
        _drawStar(
          canvas,
          Offset(sparkleX, sparkleY),
          12,
          Colors.yellow.withOpacity(0.8),
        );
        // Draw additional sparkles around jackpot
        for (int j = 0; j < 3; j++) {
          final offsetAngle = textAngle + (j - 1) * segmentAngle * 0.3;
          final offsetX = center.dx + sparkleRadius * math.cos(offsetAngle);
          final offsetY = center.dy + sparkleRadius * math.sin(offsetAngle);
          _drawStar(
            canvas,
            Offset(offsetX, offsetY),
            6,
            Colors.yellow.withOpacity(0.6),
          );
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
        colors: [const Color(0xFFFF69B4), const Color(0xFFFF1493)],
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
