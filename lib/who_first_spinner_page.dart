import 'dart:async';
import 'app_theme.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'ad_helper.dart';
import 'spinner_colors.dart';
import 'sound_vibration_helper.dart';
import 'multiplayer_results_page.dart';
import 'app_localizations_helper.dart';

// Global failure rlity count - change this value to adjust failure probability
const int WhoFirstfailProbalityCount = 5;

class WhoFirstSpinnerPage extends StatefulWidget {
  final List<String> users;
  final int rounds;

  const WhoFirstSpinnerPage({
    super.key,
    required this.users,
    required this.rounds,
  });

  @override
  State<WhoFirstSpinnerPage> createState() => _WhoFirstSpinnerPageState();
}

class _WhoFirstSpinnerPageState extends State<WhoFirstSpinnerPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _revealController;
  double _rotation = 0;
  double _randomOffset = 0;
  bool _isSpinning = false;
  bool _isWaitingForNextTurn = false;

  // Track disabled rounds for each user (userIndex -> Set of disabled round numbers)
  late List<Set<int>> _disabledRounds;
  int _currentUserIndex = 0;
  String? _winner;
  Set<int> _winners =
      {}; // Track user indices who have won (completed all rounds)
  Set<int> _losers =
      {}; // Track user indices who have lost (landed on disabled round)

  // Track completion order and scores for results page
  List<String> _completionOrder = [];
  Map<String, int> _totalScores = {}; // Total rounds completed per user
  Map<int, Map<String, int>> _roundScores =
      {}; // Round scores (1 if completed, 0 if not)

  // Failure probability tracking per user
  Map<String, int> _userFailureCount = {};

  // Single player mode
  late List<String>
  _displayUsers; // Users to display (may include Computer for single player)
  bool _isSinglePlayer = false; // Track if this is single player mode

  // Reveal animation state
  bool _isRevealed = false;
  int? _earnedNumber;

  // Highlight animation state
  bool _isHighlighting = false;
  int? _finalSelectedRound;
  bool _shouldDisableFinalRound = false;
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;

  // Segments for spinner (1 to rounds)
  late List<SegmentInfo> _segments;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Check if single player mode (only "Player" in the list)
    _isSinglePlayer = widget.users.length == 1 && widget.users[0] == 'Player';

    // For single player, change "Player" to "You" and add "Computer"
    if (_isSinglePlayer) {
      _displayUsers = ['You', 'Computer'];
    } else {
      _displayUsers = List.from(widget.users);
    }

    // Initialize disabled rounds for each user
    _disabledRounds = List.generate(_displayUsers.length, (_) => <int>{});

    // Initialize scores
    for (var user in _displayUsers) {
      _totalScores[user] = 0;
      _userFailureCount[user] = 0; // Initialize failure count for each user
    }

    // Initialize round scores
    for (int round = 1; round <= widget.rounds; round++) {
      _roundScores[round] = {};
      for (var user in _displayUsers) {
        _roundScores[round]![user] = 0;
      }
    }

    // Create segments for spinner (1 to rounds)
    _initializeSegments();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Initialize highlight animation
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );
    _highlightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _highlightController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isHighlighting = false;
        });
        _proceedAfterHighlight();
      }
    });

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

    // If single player mode and it's Computer's turn at start, auto-spin
    if (_isSinglePlayer && _displayUsers[_currentUserIndex] == 'Computer') {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isSpinning && !_isRevealed) {
          _spin();
        }
      });
    }
  }

  void _initializeSegments() {
    _segments = [];
    final segmentAngle = 360.0 / widget.rounds;

    for (int i = 0; i < widget.rounds; i++) {
      final roundNumber = i + 1;
      _segments.add(
        SegmentInfo(
          value: roundNumber.toString(),
          startAngle: i * segmentAngle,
          endAngle: (i + 1) * segmentAngle,
        ),
      );
    }
  }

  Color _getSegmentColor(int index) {
    // Always use spinner colors - don't disable anything on spinner
    return SpinnerColors.getColor(index);
  }

  @override
  void dispose() {
    SoundVibrationHelper.stopContinuousSound();
    _controller.dispose();
    _revealController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  void _spin() {
    // Skip if waiting for next turn or already spinning
    if (_isSpinning || _isWaitingForNextTurn) return;

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

    // Skip if current user has already won or lost
    if (_winners.contains(_currentUserIndex) ||
        _losers.contains(_currentUserIndex)) {
      setState(() {
        _isWaitingForNextTurn = true;
      });
      _moveToNextUser();
      return;
    }

    // Check if current user has already completed all rounds
    if (_disabledRounds[_currentUserIndex].length == widget.rounds) {
      // User already completed, mark as winner and move to next
      setState(() {
        _winners.add(_currentUserIndex);
        _isWaitingForNextTurn = true;
      });
      _moveToNextUser();
      return;
    }

    // Get available rounds for current user (not disabled)
    final availableRounds = List.generate(widget.rounds, (index) => index + 1)
        .where((round) => !_disabledRounds[_currentUserIndex].contains(round))
        .toList();

    if (availableRounds.isEmpty) {
      // Current user has no available rounds, mark as winner and move to next
      setState(() {
        _winners.add(_currentUserIndex);
        _isWaitingForNextTurn = true;
      });
      _moveToNextUser();
      return;
    }

    // Check failure probability logic
    final currentUser = _displayUsers[_currentUserIndex];
    final failureCount = _userFailureCount[currentUser] ?? 0;
    final shouldForceRemaining = failureCount >= WhoFirstfailProbalityCount;

    if (shouldForceRemaining && availableRounds.isNotEmpty) {
      // Force spinner to land on one of the remaining (not disabled) boxes
      // Pick a random remaining box
      final targetRound =
          availableRounds[_random.nextInt(availableRounds.length)];

      // Find the segment index for this round (round numbers are 1-based, segments are 0-based)
      final segmentIndex = targetRound - 1;

      // Calculate the angle needed to land on this segment
      final segmentAngle = 360.0 / widget.rounds;
      final targetSegmentStartAngle = segmentIndex * segmentAngle;
      // Add a small offset to land in the middle of the segment
      final targetAngle = targetSegmentStartAngle + (segmentAngle / 2);
      // Convert to rotation offset (accounting for pointer at top)
      _randomOffset = (360 - targetAngle) % 360;
    } else {
      // Random rotation offset (0-360 degrees) to land on a random segment
      _randomOffset = _random.nextDouble() * 360;
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

  // Calculate speed based on animation value (0.0 to 1.0)
  double _calculateSpeed(double animationValue) {
    return (1.0 - animationValue).clamp(0.1, 1.0);
  }

  void _handleSpinComplete() {
    // Stop continuous sound
    SoundVibrationHelper.stopContinuousSound();

    // Normalize rotation to 0-360 range
    final normalizedRotation = _rotation % 360;

    // Find which segment's start angle equals (360 - normalizedRotation) mod 360
    final targetStartAngle = (360 - normalizedRotation) % 360;

    // Find the segment that contains this start angle
    int segmentIndex = 0;
    for (int i = 0; i < _segments.length; i++) {
      final segment = _segments[i];
      final startAngle = segment.startAngle % 360;
      final endAngle = segment.endAngle % 360;

      // Check if targetStartAngle falls within this segment's range
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

    final selectedNumber = int.parse(_segments[segmentIndex].value);

    // Check if this number is already disabled
    final isAlreadyDisabled = _disabledRounds[_currentUserIndex].contains(
      selectedNumber,
    );

    // Show reveal animation - set waiting flag to prevent spinning during reveal/highlight
    setState(() {
      _earnedNumber = selectedNumber;
      _isRevealed = true;
      _isSpinning = false;
      _isWaitingForNextTurn = true; // Disable spin during result processing
      _finalSelectedRound = selectedNumber;
      _shouldDisableFinalRound = !isAlreadyDisabled;
    });

    // Start reveal animation
    _revealController.forward(from: 0).then((_) {
      // After reveal animation completes, start highlight animation
      if (!mounted) return;
      setState(() {
        _isRevealed = false;
        _earnedNumber = null;
        _isHighlighting = true;
      });
      _revealController.reset();

      // Start highlight animation
      _highlightController.forward();
    });
  }

  void _proceedAfterHighlight() {
    if (_finalSelectedRound == null) return;

    final selectedNumber = _finalSelectedRound!;
    final shouldDisable = _shouldDisableFinalRound;

    setState(() {
      _finalSelectedRound = null;
    });

    // Process the result
    _processSpinResult(selectedNumber, !shouldDisable);
  }

  void _processSpinResult(int selectedNumber, bool isAlreadyDisabled) {
    final currentUser = _displayUsers[_currentUserIndex];

    // Set waiting flag immediately to prevent spinning during result processing
    setState(() {
      _isWaitingForNextTurn = true;
    });

    // Only disable if it's not already disabled
    if (!isAlreadyDisabled) {
      // User landed on a remaining box - reset failure count to 0
      setState(() {
        _userFailureCount[currentUser] = 0;
        _disabledRounds[_currentUserIndex].add(selectedNumber);
        _isRevealed = false;
        _earnedNumber = null;
        _isSpinning = false; // Ensure spinning state is reset

        // Update scores
        _totalScores[currentUser] = _disabledRounds[_currentUserIndex].length;
        _roundScores[selectedNumber]![currentUser] = 1;
      });
      _revealController.reset();

      // Check if current user won (all rounds disabled)
      if (_disabledRounds[_currentUserIndex].length == widget.rounds) {
        // Add to completion order if not already added
        if (!_completionOrder.contains(currentUser)) {
          _completionOrder.add(currentUser);
        }

        // Mark this user as a winner
        setState(() {
          _winners.add(_currentUserIndex);
        });

        // Check if all other users have won (last user loses)
        // Game should ONLY end when exactly (total_users - 1) users have won
        if (_winners.length == _displayUsers.length - 1) {
          // All other users won - mark remaining user as loser and end game
          // Find the user who hasn't won yet and mark them as loser
          for (int i = 0; i < _displayUsers.length; i++) {
            if (!_winners.contains(i) && !_losers.contains(i)) {
              _losers.add(i);
              break;
            }
          }
          // All other users won - last user lost, game ends immediately
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _navigateToResults();
            }
          });
          return;
        }

        // Don't end game - continue playing, but skip this user in future turns
        // Move to next user after a delay (waiting flag already set)
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _moveToNextUser();
          }
        });
      } else {
        // Move to next user after a delay (waiting flag already set)
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _moveToNextUser();
          }
        });
      }
    } else {
      // Landed on already disabled round - move to next user (no loser marking)
      setState(() {
        _isRevealed = false;
        _earnedNumber = null;
        _isSpinning = false; // Ensure spinning state is reset
        _isWaitingForNextTurn = true; // Set waiting flag for move to next user
      });
      _revealController.reset();
      _controller.reset(); // Reset spinner rotation

      // Move to next user after a delay (no loser marking, just move turn)
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _moveToNextUser();
        }
      });
    }
  }

  void _moveToNextUser() {
    // Find next user who hasn't won or lost yet
    int attempts = 0;
    int nextUserIndex = (_currentUserIndex + 1) % _displayUsers.length;

    // Skip winners and losers - find next active user
    while ((_winners.contains(nextUserIndex) ||
            _losers.contains(nextUserIndex)) &&
        attempts < _displayUsers.length) {
      nextUserIndex = (nextUserIndex + 1) % _displayUsers.length;
      attempts++;
    }

    // Check if all other users have won (last user loses)
    // Game should ONLY end when exactly (total_users - 1) users have won
    if (_winners.length == _displayUsers.length - 1) {
      // All other users won - mark remaining user as loser and end game
      // Find the user who hasn't won yet and mark them as loser
      for (int i = 0; i < _displayUsers.length; i++) {
        if (!_winners.contains(i) && !_losers.contains(i)) {
          _losers.add(i);
          break;
        }
      }
      // All other users won - last user lost, game ends immediately
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

    // Double-check that nextUserIndex is not a winner or loser (safeguard)
    if (_winners.contains(nextUserIndex) || _losers.contains(nextUserIndex)) {
      // If somehow still a winner/loser, skip to next user recursively
      _moveToNextUser();
      return;
    }

    setState(() {
      _currentUserIndex = nextUserIndex;
      _rotation = 0;
      _randomOffset = 0;
      _isHighlighting = false;
      _finalSelectedRound = null;
      _shouldDisableFinalRound = false;
      _isSpinning = false; // Ensure spinning state is reset
      _isRevealed = false; // Ensure reveal state is reset
      _earnedNumber = null; // Ensure earned number is reset
      _isWaitingForNextTurn =
          false; // Reset waiting flag - next user's turn can start
    });
    _controller.reset();
    _revealController.reset();

    // If single player mode and it's Computer's turn, auto-spin after a short delay
    if (_isSinglePlayer && _displayUsers[_currentUserIndex] == 'Computer') {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted &&
            !_isSpinning &&
            !_isRevealed &&
            !_isHighlighting &&
            !_winners.contains(_currentUserIndex) &&
            !_losers.contains(_currentUserIndex)) {
          _spin();
        }
      });
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
              totalScores: Map<String, int>.from(_totalScores),
            ),
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
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
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
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
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppTheme.textColor,
                              ),
                              onPressed: _goHome,
                            ),
                          ),
                        ),
                        Text(
                          'Who First',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Game content - responsive layout
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isLandscape =
                            constraints.maxWidth > constraints.maxHeight;

                        if (isLandscape) {
                          // Landscape: Users on left, Spinner on right
                          return Row(
                            children: [
                              // Users section - left half
                              Expanded(
                                flex: 1,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final availableHeight =
                                        constraints.maxHeight;
                                    final availableWidth = constraints.maxWidth;

                                    // Detect if mobile (smaller screen)
                                    final isMobile = availableWidth < 600;

                                    // Calculate dynamic sizes (no turn text) - responsive for mobile
                                    final padding = isMobile ? 8.0 : 16.0;
                                    final userNameHeight = isMobile
                                        ? 40.0
                                        : 50.0;
                                    final userNameSpacing = isMobile
                                        ? 4.0
                                        : 8.0;
                                    final roundsAreaHeight =
                                        availableHeight -
                                        userNameHeight -
                                        userNameSpacing -
                                        (padding * 2);

                                    // Calculate tile size based on available space to fit all rounds
                                    final tileSpacing = isMobile ? 1.0 : 2.0;
                                    final totalSpacing =
                                        (widget.rounds - 1) * tileSpacing * 2;
                                    final calculatedTileSize =
                                        (roundsAreaHeight - totalSpacing) /
                                        widget.rounds;
                                    final minTileSize = isMobile ? 25.0 : 30.0;
                                    final maxTileSize = isMobile ? 40.0 : 50.0;
                                    final tileSize = math.max(
                                      minTileSize,
                                      math.min(maxTileSize, calculatedTileSize),
                                    );
                                    final tileFontSize = math.max(
                                      10.0,
                                      math.min(18.0, tileSize * 0.36),
                                    );

                                    // Calculate column width based on available width - more compact on mobile
                                    // Adjust margins based on number of users to prevent overflow
                                    final numUsers = _displayUsers.length;
                                    final horizontalMargin = isMobile
                                        ? (numUsers > 5 ? 2.0 : 4.0)
                                        : (numUsers > 5 ? 4.0 : 8.0);
                                    final totalHorizontalMargin =
                                        (numUsers - 1) * horizontalMargin * 2;
                                    final totalPadding = padding * 2;
                                    final calculatedColumnWidth =
                                        (availableWidth -
                                            totalPadding -
                                            totalHorizontalMargin) /
                                        numUsers;
                                    final minColumnWidth = isMobile
                                        ? (numUsers > 5 ? 35.0 : 45.0)
                                        : (numUsers > 5 ? 50.0 : 60.0);
                                    final maxColumnWidth = isMobile
                                        ? (numUsers > 5 ? 55.0 : 70.0)
                                        : (numUsers > 5 ? 70.0 : 80.0);
                                    final columnWidth = math.max(
                                      minColumnWidth,
                                      math.min(
                                        maxColumnWidth,
                                        calculatedColumnWidth,
                                      ),
                                    );

                                    return Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Users list with rounds
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Users with their rounds - side by side
                                                  ...List.generate(_displayUsers.length, (
                                                    userIndex,
                                                  ) {
                                                    final user =
                                                        _displayUsers[userIndex];
                                                    final isCurrentUser =
                                                        userIndex ==
                                                        _currentUserIndex;
                                                    final isWinner = _winners
                                                        .contains(userIndex);
                                                    final isLoser = _losers
                                                        .contains(userIndex);

                                                    return Opacity(
                                                      opacity:
                                                          (isWinner || isLoser)
                                                          ? 0.5
                                                          : 1.0,
                                                      child: Container(
                                                        width: columnWidth,
                                                        margin: EdgeInsets.only(
                                                          left: userIndex == 0
                                                              ? 0
                                                              : horizontalMargin,
                                                          right:
                                                              userIndex ==
                                                                  _displayUsers
                                                                          .length -
                                                                      1
                                                              ? 0
                                                              : horizontalMargin,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            // Rounds display vertically
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: List.generate(widget.rounds, (
                                                                index,
                                                              ) {
                                                                final roundNumber =
                                                                    index + 1;
                                                                final isDisabled =
                                                                    _disabledRounds[userIndex]
                                                                        .contains(
                                                                          roundNumber,
                                                                        );
                                                                final isHighlighting =
                                                                    _isHighlighting &&
                                                                    userIndex ==
                                                                        _currentUserIndex &&
                                                                    _finalSelectedRound ==
                                                                        roundNumber;
                                                                final isHighlightedAndDisabled =
                                                                    isHighlighting &&
                                                                    isDisabled;

                                                                return AnimatedBuilder(
                                                                  animation:
                                                                      _highlightAnimation,
                                                                  builder:
                                                                      (
                                                                        context,
                                                                        child,
                                                                      ) {
                                                                        final highlightScale =
                                                                            isHighlighting
                                                                            ? 1.0 +
                                                                                  (_highlightAnimation.value *
                                                                                      0.3)
                                                                            : 1.0;
                                                                        final highlightOpacity =
                                                                            isHighlighting
                                                                            ? 0.5 +
                                                                                  (_highlightAnimation.value *
                                                                                      0.5)
                                                                            : 1.0;
                                                                        final highlightColor =
                                                                            isHighlighting
                                                                            ? isHighlightedAndDisabled
                                                                                  ? Color.lerp(
                                                                                      Colors.red,
                                                                                      Colors.redAccent,
                                                                                      _highlightAnimation.value,
                                                                                    )!
                                                                                  : Color.lerp(
                                                                                      const Color(
                                                                                        0xFF00B894,
                                                                                      ),
                                                                                      const Color(
                                                                                        0xFF00B894,
                                                                                      ).withOpacity(
                                                                                        0.8,
                                                                                      ),
                                                                                      _highlightAnimation.value,
                                                                                    )!
                                                                            : null;

                                                                        return Transform.scale(
                                                                          scale:
                                                                              highlightScale,
                                                                          child: Container(
                                                                            margin: EdgeInsets.symmetric(
                                                                              vertical: tileSpacing,
                                                                            ),
                                                                            width:
                                                                                tileSize,
                                                                            height:
                                                                                tileSize,
                                                                            decoration: BoxDecoration(
                                                                              color: isHighlighting
                                                                                  ? highlightColor
                                                                                  : isDisabled
                                                                                  ? Colors.red.withOpacity(
                                                                                      0.7,
                                                                                    )
                                                                                  : const Color(
                                                                                      0xFF00B894,
                                                                                    ).withOpacity(
                                                                                      0.7,
                                                                                    ),
                                                                              borderRadius: BorderRadius.circular(
                                                                                8,
                                                                              ),
                                                                              border: Border.all(
                                                                                color: isHighlighting
                                                                                    ? Colors.white
                                                                                    : isDisabled
                                                                                    ? Colors.red
                                                                                    : const Color(
                                                                                        0xFF00B894,
                                                                                      ),
                                                                                width: isHighlighting
                                                                                    ? 3
                                                                                    : 2,
                                                                              ),
                                                                              boxShadow: isHighlighting
                                                                                  ? [
                                                                                      BoxShadow(
                                                                                        color: highlightColor!.withOpacity(
                                                                                          highlightOpacity,
                                                                                        ),
                                                                                        blurRadius: 15,
                                                                                        spreadRadius: 2,
                                                                                      ),
                                                                                    ]
                                                                                  : null,
                                                                            ),
                                                                            child: Center(
                                                                              child: Text(
                                                                                '$roundNumber',
                                                                                style: TextStyle(
                                                                                  color: isHighlighting
                                                                                      ? Colors.white
                                                                                      : isDisabled
                                                                                      ? Colors.white
                                                                                      : Colors.white,
                                                                                  fontSize: tileFontSize,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  decoration:
                                                                                      isDisabled &&
                                                                                          !isHighlighting
                                                                                      ? TextDecoration.lineThrough
                                                                                      : null,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                );
                                                              }),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  userNameSpacing,
                                                            ),
                                                            // User name
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        isMobile
                                                                        ? 6.0
                                                                        : 8.0,
                                                                    vertical:
                                                                        isMobile
                                                                        ? 6.0
                                                                        : 8.0,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: isWinner
                                                                    ? const Color(
                                                                        0xFF2D2D44,
                                                                      )
                                                                    : (isLoser
                                                                          ? const Color(
                                                                              0xFF2D2D44,
                                                                            )
                                                                          : (isCurrentUser
                                                                                ? const Color(
                                                                                    0xFF6C5CE7,
                                                                                  )
                                                                                : const Color(0xFF3D3D5C))),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                border: Border.all(
                                                                  color:
                                                                      isWinner
                                                                      ? const Color(
                                                                          0xFF4CAF50,
                                                                        )
                                                                      : (isLoser
                                                                            ? const Color(
                                                                                0xFFEF5350,
                                                                              )
                                                                            : (isCurrentUser &&
                                                                                      !isWinner &&
                                                                                      !isLoser
                                                                                  ? Colors.white
                                                                                  : Colors.transparent)),
                                                                  width: 2,
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Expanded(
                                                                    child: FittedBox(
                                                                      fit: BoxFit
                                                                          .scaleDown,
                                                                      child: Text(
                                                                        user,
                                                                        style: TextStyle(
                                                                          color:
                                                                              (isWinner ||
                                                                                  isLoser)
                                                                              ? Colors.white70
                                                                              : Colors.white,
                                                                          fontSize:
                                                                              isMobile
                                                                              ? math.max(
                                                                                  10.0,
                                                                                  math.min(
                                                                                    14.0,
                                                                                    columnWidth *
                                                                                        0.2,
                                                                                  ),
                                                                                )
                                                                              : math.max(
                                                                                  12.0,
                                                                                  math.min(
                                                                                    16.0,
                                                                                    columnWidth *
                                                                                        0.2,
                                                                                  ),
                                                                                ),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        maxLines:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (isLoser)
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                        left:
                                                                            isMobile
                                                                            ? 3.0
                                                                            : 4.0,
                                                                      ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .cancel,
                                                                        color: const Color(
                                                                          0xFFEF5350,
                                                                        ),
                                                                        size:
                                                                            isMobile
                                                                            ? 14.0
                                                                            : 16.0,
                                                                      ),
                                                                    ),
                                                                  if (!isWinner &&
                                                                      !isLoser &&
                                                                      _disabledRounds[userIndex]
                                                                              .length ==
                                                                          widget
                                                                              .rounds)
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                        left:
                                                                            isMobile
                                                                            ? 3.0
                                                                            : 4.0,
                                                                      ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .emoji_events,
                                                                        color: Colors
                                                                            .amber,
                                                                        size:
                                                                            isMobile
                                                                            ? 14.0
                                                                            : 16.0,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Spinner section - right half
                              Expanded(
                                flex: 1,
                                child: LayoutBuilder(
                                  builder: (context, spinnerConstraints) {
                                    final spinnerHeight =
                                        spinnerConstraints.maxHeight;
                                    final spinnerWidth =
                                        spinnerConstraints.maxWidth;
                                    final spinnerSize = math.min(
                                      spinnerHeight * 0.8,
                                      spinnerWidth * 0.8,
                                    );
                                    final finalSize = math.max(
                                      200.0,
                                      spinnerSize,
                                    );

                                    final buttonSize = finalSize * 0.25;

                                    return Center(
                                      child: Container(
                                        height: finalSize,
                                        width: finalSize,
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
                                                painter: WhoFirstWheelPainter(
                                                  segments: _segments,
                                                  getSegmentColor:
                                                      _getSegmentColor,
                                                ),
                                              ),
                                            ),
                                            // Pointer
                                            // Center Spin Button
                                            GestureDetector(
                                              onTap:
                                                  (_isRevealed ||
                                                      _isSpinning ||
                                                      _isWaitingForNextTurn ||
                                                      _isHighlighting ||
                                                      _winner != null ||
                                                      _winners.contains(
                                                        _currentUserIndex,
                                                      ) ||
                                                      _losers.contains(
                                                        _currentUserIndex,
                                                      ) ||
                                                      (_isSinglePlayer &&
                                                          _displayUsers[_currentUserIndex] ==
                                                              'Computer'))
                                                  ? null
                                                  : _spin,
                                              child: Opacity(
                                                opacity:
                                                    (_isRevealed ||
                                                        _isSpinning ||
                                                        _isWaitingForNextTurn ||
                                                        _isHighlighting ||
                                                        _winner != null ||
                                                        _winners.contains(
                                                          _currentUserIndex,
                                                        ) ||
                                                        _losers.contains(
                                                          _currentUserIndex,
                                                        ) ||
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
                                            // Reveal animation overlay
                                            if (_isRevealed &&
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
                                                          gradient:
                                                              RadialGradient(
                                                                colors: [
                                                                  const Color(
                                                                    0xFFFFF9C4,
                                                                  ).withOpacity(
                                                                    0.95,
                                                                  ),
                                                                  const Color(
                                                                    0xFFFFF59D,
                                                                  ).withOpacity(
                                                                    0.9,
                                                                  ),
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
                                                                  'SELECTED',
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
                                                                  _earnedNumber
                                                                      .toString(),
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
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Portrait: Users on top, Spinner on bottom
                          return Column(
                            children: [
                              // Users section - top half
                              Expanded(
                                flex: 1,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final availableHeight =
                                        constraints.maxHeight;
                                    final availableWidth = constraints.maxWidth;

                                    // Detect if mobile (smaller screen)
                                    final isMobile = availableWidth < 600;

                                    // Calculate dynamic sizes (no turn text) - responsive for mobile
                                    final padding = isMobile ? 8.0 : 16.0;
                                    final userNamePadding = isMobile
                                        ? 6.0
                                        : 8.0;
                                    final userNameHeight =
                                        (isMobile ? 40.0 : 50.0) +
                                        (userNamePadding *
                                            2); // Include padding
                                    final userNameSpacing = isMobile
                                        ? 4.0
                                        : 8.0;

                                    // Reserve space for username and spacing, then calculate rounds area
                                    final reservedSpace =
                                        userNameHeight +
                                        userNameSpacing +
                                        (padding * 2);
                                    final roundsAreaHeight = math.max(
                                      0,
                                      availableHeight - reservedSpace,
                                    );

                                    // Calculate tile size based on available space to fit all rounds
                                    final tileSpacing = isMobile ? 1.0 : 2.0;
                                    final totalSpacing =
                                        (widget.rounds - 1) * tileSpacing * 2;
                                    final calculatedTileSize =
                                        roundsAreaHeight > 0
                                        ? (roundsAreaHeight - totalSpacing) /
                                              widget.rounds
                                        : 0.0;
                                    final minTileSize = isMobile ? 25.0 : 30.0;
                                    final maxTileSize = isMobile ? 40.0 : 50.0;
                                    final tileSize = math.max(
                                      minTileSize,
                                      math.min(maxTileSize, calculatedTileSize),
                                    );
                                    final tileFontSize = math.max(
                                      10.0,
                                      math.min(18.0, tileSize * 0.36),
                                    );

                                    // Calculate column width based on available width - more compact on mobile
                                    // Adjust margins based on number of users to prevent overflow
                                    final numUsers = _displayUsers.length;
                                    final horizontalMargin = isMobile
                                        ? (numUsers > 5 ? 2.0 : 4.0)
                                        : (numUsers > 5 ? 4.0 : 8.0);
                                    final totalHorizontalMargin =
                                        (numUsers - 1) * horizontalMargin * 2;
                                    final totalPadding = padding * 2;
                                    final calculatedColumnWidth =
                                        (availableWidth -
                                            totalPadding -
                                            totalHorizontalMargin) /
                                        numUsers;
                                    final minColumnWidth = isMobile
                                        ? (numUsers > 5 ? 35.0 : 45.0)
                                        : (numUsers > 5 ? 50.0 : 60.0);
                                    final maxColumnWidth = isMobile
                                        ? (numUsers > 5 ? 55.0 : 70.0)
                                        : (numUsers > 5 ? 70.0 : 80.0);
                                    final columnWidth = math.max(
                                      minColumnWidth,
                                      math.min(
                                        maxColumnWidth,
                                        calculatedColumnWidth,
                                      ),
                                    );

                                    return Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Users list with rounds
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Users with their rounds - side by side
                                                  ...List.generate(_displayUsers.length, (
                                                    userIndex,
                                                  ) {
                                                    final user =
                                                        _displayUsers[userIndex];
                                                    final isCurrentUser =
                                                        userIndex ==
                                                        _currentUserIndex;
                                                    final isWinner = _winners
                                                        .contains(userIndex);
                                                    final isLoser = _losers
                                                        .contains(userIndex);

                                                    return Opacity(
                                                      opacity:
                                                          (isWinner || isLoser)
                                                          ? 0.5
                                                          : 1.0,
                                                      child: Container(
                                                        width: columnWidth,
                                                        margin: EdgeInsets.only(
                                                          left: userIndex == 0
                                                              ? 0
                                                              : horizontalMargin,
                                                          right:
                                                              userIndex ==
                                                                  _displayUsers
                                                                          .length -
                                                                      1
                                                              ? 0
                                                              : horizontalMargin,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            // Rounds display vertically - use Flexible to prevent overflow
                                                            Flexible(
                                                              child: SingleChildScrollView(
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: List.generate(
                                                                    widget
                                                                        .rounds,
                                                                    (index) {
                                                                      final roundNumber =
                                                                          index +
                                                                          1;
                                                                      final isDisabled =
                                                                          _disabledRounds[userIndex].contains(
                                                                            roundNumber,
                                                                          );
                                                                      final isHighlighting =
                                                                          _isHighlighting &&
                                                                          userIndex ==
                                                                              _currentUserIndex &&
                                                                          _finalSelectedRound ==
                                                                              roundNumber;
                                                                      final isHighlightedAndDisabled =
                                                                          isHighlighting &&
                                                                          isDisabled;

                                                                      return AnimatedBuilder(
                                                                        animation:
                                                                            _highlightAnimation,
                                                                        builder:
                                                                            (
                                                                              context,
                                                                              child,
                                                                            ) {
                                                                              final highlightScale = isHighlighting
                                                                                  ? 1.0 +
                                                                                        (_highlightAnimation.value *
                                                                                            0.3)
                                                                                  : 1.0;
                                                                              final highlightOpacity = isHighlighting
                                                                                  ? 0.5 +
                                                                                        (_highlightAnimation.value *
                                                                                            0.5)
                                                                                  : 1.0;
                                                                              final highlightColor = isHighlighting
                                                                                  ? isHighlightedAndDisabled
                                                                                        ? Color.lerp(
                                                                                            Colors.red,
                                                                                            Colors.redAccent,
                                                                                            _highlightAnimation.value,
                                                                                          )!
                                                                                        : Color.lerp(
                                                                                            const Color(
                                                                                              0xFF00B894,
                                                                                            ),
                                                                                            const Color(
                                                                                              0xFF00B894,
                                                                                            ).withOpacity(
                                                                                              0.8,
                                                                                            ),
                                                                                            _highlightAnimation.value,
                                                                                          )!
                                                                                  : null;

                                                                              return Transform.scale(
                                                                                scale: highlightScale,
                                                                                child: Container(
                                                                                  margin: EdgeInsets.symmetric(
                                                                                    vertical: tileSpacing,
                                                                                  ),
                                                                                  width: tileSize,
                                                                                  height: tileSize,
                                                                                  decoration: BoxDecoration(
                                                                                    color: isHighlighting
                                                                                        ? highlightColor
                                                                                        : isDisabled
                                                                                        ? Colors.red.withOpacity(
                                                                                            0.7,
                                                                                          )
                                                                                        : const Color(
                                                                                            0xFF00B894,
                                                                                          ).withOpacity(
                                                                                            0.7,
                                                                                          ),
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      8,
                                                                                    ),
                                                                                    border: Border.all(
                                                                                      color: isHighlighting
                                                                                          ? Colors.white
                                                                                          : isDisabled
                                                                                          ? Colors.red
                                                                                          : const Color(
                                                                                              0xFF00B894,
                                                                                            ),
                                                                                      width: isHighlighting
                                                                                          ? 3
                                                                                          : 2,
                                                                                    ),
                                                                                    boxShadow: isHighlighting
                                                                                        ? [
                                                                                            BoxShadow(
                                                                                              color: highlightColor!.withOpacity(
                                                                                                highlightOpacity,
                                                                                              ),
                                                                                              blurRadius: 15,
                                                                                              spreadRadius: 2,
                                                                                            ),
                                                                                          ]
                                                                                        : null,
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      '$roundNumber',
                                                                                      style: TextStyle(
                                                                                        color: isHighlighting
                                                                                            ? Colors.white
                                                                                            : isDisabled
                                                                                            ? Colors.white
                                                                                            : Colors.white,
                                                                                        fontSize: tileFontSize,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        decoration:
                                                                                            isDisabled &&
                                                                                                !isHighlighting
                                                                                            ? TextDecoration.lineThrough
                                                                                            : null,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  userNameSpacing,
                                                            ),
                                                            // User name
                                                            Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                    maxHeight:
                                                                        userNameHeight -
                                                                        (userNamePadding *
                                                                            2),
                                                                  ),
                                                              padding: EdgeInsets.symmetric(
                                                                horizontal:
                                                                    userNamePadding,
                                                                vertical:
                                                                    userNamePadding,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: isWinner
                                                                    ? const Color(
                                                                        0xFF2D2D44,
                                                                      )
                                                                    : (isLoser
                                                                          ? const Color(
                                                                              0xFF2D2D44,
                                                                            )
                                                                          : (isCurrentUser
                                                                                ? const Color(
                                                                                    0xFF6C5CE7,
                                                                                  )
                                                                                : const Color(0xFF3D3D5C))),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                border: Border.all(
                                                                  color:
                                                                      isWinner
                                                                      ? const Color(
                                                                          0xFF4CAF50,
                                                                        )
                                                                      : (isLoser
                                                                            ? const Color(
                                                                                0xFFEF5350,
                                                                              )
                                                                            : (isCurrentUser &&
                                                                                      !isWinner &&
                                                                                      !isLoser
                                                                                  ? Colors.white
                                                                                  : Colors.transparent)),
                                                                  width: 2,
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Expanded(
                                                                    child: FittedBox(
                                                                      fit: BoxFit
                                                                          .scaleDown,
                                                                      child: Text(
                                                                        user,
                                                                        style: TextStyle(
                                                                          color:
                                                                              (isWinner ||
                                                                                  isLoser)
                                                                              ? Colors.white70
                                                                              : Colors.white,
                                                                          fontSize:
                                                                              isMobile
                                                                              ? math.max(
                                                                                  10.0,
                                                                                  math.min(
                                                                                    14.0,
                                                                                    columnWidth *
                                                                                        0.2,
                                                                                  ),
                                                                                )
                                                                              : math.max(
                                                                                  12.0,
                                                                                  math.min(
                                                                                    16.0,
                                                                                    columnWidth *
                                                                                        0.2,
                                                                                  ),
                                                                                ),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        maxLines:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (isLoser)
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                        left:
                                                                            isMobile
                                                                            ? 3.0
                                                                            : 4.0,
                                                                      ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .cancel,
                                                                        color: const Color(
                                                                          0xFFEF5350,
                                                                        ),
                                                                        size:
                                                                            isMobile
                                                                            ? 14.0
                                                                            : 16.0,
                                                                      ),
                                                                    ),
                                                                  if (!isWinner &&
                                                                      !isLoser &&
                                                                      _disabledRounds[userIndex]
                                                                              .length ==
                                                                          widget
                                                                              .rounds)
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                        left:
                                                                            isMobile
                                                                            ? 3.0
                                                                            : 4.0,
                                                                      ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .emoji_events,
                                                                        color: Colors
                                                                            .amber,
                                                                        size:
                                                                            isMobile
                                                                            ? 14.0
                                                                            : 16.0,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Spinner section - bottom half
                              Expanded(
                                flex: 1,
                                child: LayoutBuilder(
                                  builder: (context, spinnerConstraints) {
                                    final spinnerHeight =
                                        spinnerConstraints.maxHeight;
                                    final spinnerWidth =
                                        spinnerConstraints.maxWidth;
                                    final spinnerSize = math.min(
                                      spinnerHeight * 0.8,
                                      spinnerWidth * 0.8,
                                    );
                                    final finalSize = math.max(
                                      200.0,
                                      spinnerSize,
                                    );

                                    final buttonSize = finalSize * 0.25;

                                    return Center(
                                      child: Container(
                                        height: finalSize,
                                        width: finalSize,
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
                                                painter: WhoFirstWheelPainter(
                                                  segments: _segments,
                                                  getSegmentColor:
                                                      _getSegmentColor,
                                                ),
                                              ),
                                            ),
                                            // Pointer
                                            // Center Spin Button
                                            GestureDetector(
                                              onTap:
                                                  (_isRevealed ||
                                                      _isSpinning ||
                                                      _isWaitingForNextTurn ||
                                                      _isHighlighting ||
                                                      _winner != null ||
                                                      _winners.contains(
                                                        _currentUserIndex,
                                                      ) ||
                                                      _losers.contains(
                                                        _currentUserIndex,
                                                      ) ||
                                                      (_isSinglePlayer &&
                                                          _displayUsers[_currentUserIndex] ==
                                                              'Computer'))
                                                  ? null
                                                  : _spin,
                                              child: Opacity(
                                                opacity:
                                                    (_isRevealed ||
                                                        _isSpinning ||
                                                        _isWaitingForNextTurn ||
                                                        _isHighlighting ||
                                                        _winner != null ||
                                                        _winners.contains(
                                                          _currentUserIndex,
                                                        ) ||
                                                        _losers.contains(
                                                          _currentUserIndex,
                                                        ) ||
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
                                            // Reveal animation overlay
                                            if (_isRevealed &&
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
                                                          gradient:
                                                              RadialGradient(
                                                                colors: [
                                                                  const Color(
                                                                    0xFFFFF9C4,
                                                                  ).withOpacity(
                                                                    0.95,
                                                                  ),
                                                                  const Color(
                                                                    0xFFFFF59D,
                                                                  ).withOpacity(
                                                                    0.9,
                                                                  ),
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
                                                                  'SELECTED',
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
                                                                  _earnedNumber
                                                                      .toString(),
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
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  // Banner Ad at bottom
                  const BannerAdWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Segment info for WhoFirst wheel
class SegmentInfo {
  final String value;
  final double startAngle; // in degrees
  final double endAngle; // in degrees

  SegmentInfo({
    required this.value,
    required this.startAngle,
    required this.endAngle,
  });
}

// Custom painter for WhoFirst wheel
class WhoFirstWheelPainter extends CustomPainter {
  final List<SegmentInfo> segments;
  final Color Function(int) getSegmentColor;

  WhoFirstWheelPainter({required this.segments, required this.getSegmentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final borderWidth = 4.0;
    final radius = (size.width / 2) - (borderWidth / 2);

    // Draw segments
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final paint = Paint()
        ..color = getSegmentColor(i)
        ..style = PaintingStyle.fill;

      final startAngle = (segment.startAngle - 90) * math.pi / 180;
      final sweepAngle =
          (segment.endAngle - segment.startAngle) * math.pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border between segments
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw text in center of segment
      final textAngle = (segment.startAngle + segment.endAngle) / 2 - 90;
      final textRadius = radius * 0.7;
      final textX =
          center.dx + textRadius * math.cos(textAngle * math.pi / 180);
      final textY =
          center.dy + textRadius * math.sin(textAngle * math.pi / 180);

      final textPainter = TextPainter(
        text: TextSpan(
          text: segment.value,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.15,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // Draw outer border
    final outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawCircle(center, radius, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pointer painter (same as random picker spinner)
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
