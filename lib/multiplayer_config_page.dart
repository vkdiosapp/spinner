import 'package:flutter/material.dart';
import 'dart:ui';
import 'multiplayer_spinner_page.dart';
import 'who_first_spinner_page.dart';
import 'math_spinner_page.dart';
import 'ad_helper.dart';
import 'app_localizations_helper.dart';
import 'app_theme.dart';
import 'animated_gradient_background.dart';

class MultiplayerConfigPage extends StatefulWidget {
  final bool isWhoFirst;
  final bool isMathSpinner;

  const MultiplayerConfigPage({
    super.key,
    this.isWhoFirst = false,
    this.isMathSpinner = false,
  });

  @override
  State<MultiplayerConfigPage> createState() => _MultiplayerConfigPageState();
}

class _MultiplayerConfigPageState extends State<MultiplayerConfigPage> {
  final List<TextEditingController> _userControllers = [];
  final List<FocusNode> _userFocusNodes = [];
  final List<String> _users = [];
  int _rounds = 3;
  String _gameMode = 'multiplayer'; // 'single' or 'multiplayer'
  int _playerCount = 2; // Default to 2P

  @override
  void initState() {
    super.initState();
    // Initialize with default 2 players for multiplayer mode
    _initializeUsers();
  }

  void _initializeUsers() {
    // Clear existing controllers and focus nodes
    for (var controller in _userControllers) {
      controller.dispose();
    }
    for (var focusNode in _userFocusNodes) {
      focusNode.dispose();
    }
    _userControllers.clear();
    _userFocusNodes.clear();
    _users.clear();

    // If multiplayer mode, populate based on player count
    if (_gameMode == 'multiplayer') {
      for (int i = 0; i < _playerCount; i++) {
        final playerName = 'Player ${i + 1}';
        _users.add(playerName);
        _userControllers.add(TextEditingController(text: playerName));
        _userFocusNodes.add(FocusNode());
      }
    } else {
      // Single player mode - add one empty field
      _users.add('');
      _userControllers.add(TextEditingController());
      _userFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _userControllers) {
      controller.dispose();
    }
    for (var focusNode in _userFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _updatePlayerCount(int count) {
    setState(() {
      _playerCount = count;
      _initializeUsers();
    });
  }

  void _startMultiplayer() {
    final l10n = AppLocalizationsHelper.of(context);

    // For Math Spinner
    if (widget.isMathSpinner) {
      // For single player mode, use a default user
      if (_gameMode == 'single') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MathSpinnerPage(users: ['Player']),
          ),
        );
        return;
      }

      // For multiplayer mode, validate users
      // Update users from controllers
      final updatedUsers = <String>[];
      for (int i = 0; i < _userControllers.length; i++) {
        final controller = _userControllers[i];
        final text = controller.text.trim();
        if (text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pleaseAddAtLeastOneUser),
              backgroundColor: Colors.red,
            ),
          );
          // Focus on the empty field
          _userFocusNodes[i].requestFocus();
          return;
        }
        if (text.length > 15) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Player name must be 15 characters or less'),
              backgroundColor: Colors.red,
            ),
          );
          _userFocusNodes[i].requestFocus();
          return;
        }
        updatedUsers.add(text);
      }

      if (updatedUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseAddAtLeastOneUser),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check for duplicate names (case-insensitive)
      final seenNames = <String>{};
      for (var user in updatedUsers) {
        final lowerUser = user.toLowerCase();
        if (seenNames.contains(lowerUser)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.duplicateUserName(user)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
        seenNames.add(lowerUser);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MathSpinnerPage(users: updatedUsers),
        ),
      );
      return;
    }

    // For single player mode, use a default user
    if (_gameMode == 'single') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => widget.isWhoFirst
              ? WhoFirstSpinnerPage(users: ['Player'], rounds: 10)
              : MultiplayerSpinnerPage(users: ['Player'], rounds: _rounds),
        ),
      );
      return;
    }

    // For multiplayer mode, validate users
    // Update users from controllers
    final updatedUsers = <String>[];
    for (int i = 0; i < _userControllers.length; i++) {
      final controller = _userControllers[i];
      final text = controller.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseAddAtLeastOneUser),
            backgroundColor: Colors.red,
          ),
        );
        // Focus on the empty field
        _userFocusNodes[i].requestFocus();
        return;
      }
      if (text.length > 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Player name must be 15 characters or less'),
            backgroundColor: Colors.red,
          ),
        );
        _userFocusNodes[i].requestFocus();
        return;
      }
      updatedUsers.add(text);
    }

    if (updatedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAddAtLeastOneUser),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check for duplicate names (case-insensitive)
    final seenNames = <String>{};
    for (var user in updatedUsers) {
      final lowerUser = user.toLowerCase();
      if (seenNames.contains(lowerUser)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.duplicateUserName(user)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      seenNames.add(lowerUser);
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => widget.isWhoFirst
            ? WhoFirstSpinnerPage(users: updatedUsers, rounds: 10)
            : MultiplayerSpinnerPage(users: updatedUsers, rounds: _rounds),
      ),
    );
  }

  // Helper widget for glossy card effect
  Widget _buildGlossyCard({
    required Widget child,
    double borderRadius = 24,
    EdgeInsets? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
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
              // Glossy overlay effect - ignore pointer events so taps pass through
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

  // Helper widget for vibrant button
  Widget _buildVibrantButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Shine effect
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for player item (NO profile pic, NO drag icon)
  Widget _buildPlayerItem({
    required int index,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool isInvite = false,
  }) {
    final playerColors = [
      const Color(0xFFFCE7F3), // Pink
      const Color(0xFFDBEAFE), // Blue
      const Color(0xFFD1FAE5), // Emerald
      const Color(0xFFE5E7EB), // Slate
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Colored circle (NO profile picture)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isInvite
                  ? const Color(0xFFF3F4F6)
                  : playerColors[index % playerColors.length],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: isInvite
                ? Icon(Icons.person_add, color: Colors.grey[400], size: 20)
                : null,
          ),
          const SizedBox(width: 16),
          // Player name text field - styled like a proper text field
          Expanded(
            child: isInvite
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      hintText,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 15,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: const Color(0xFF6366F1).withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
          ),
          // NO drag indicator here
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return AnimatedGradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
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
                            onTap: () => BackArrowAd.handleBackButton(
                              context: context,
                              onBack: () => Navigator.of(context).pop(),
                            ),
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
                          widget.isMathSpinner
                              ? l10n.mathSpinner
                              : (widget.isWhoFirst
                                    ? l10n.whoFirst
                                    : l10n.multiplayer),
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        // Start button - right aligned
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildVibrantButton(
                            text: l10n.start,
                            onTap: _startMultiplayer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Game Mode Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 12,
                                ),
                                child: Text(
                                  l10n.gameMode.toUpperCase(),
                                  style: TextStyle(
                                    color: const Color(0xFF475569),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              _buildGlossyCard(
                                borderRadius: 28,
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  children: [
                                    // Single Player
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            _gameMode = 'single';
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _gameMode == 'single'
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            boxShadow: _gameMode == 'single'
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 3,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: _gameMode == 'single'
                                                    ? const Color(0xFF6366F1)
                                                    : Colors.grey[500],
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                l10n.singlePlayer,
                                                style: TextStyle(
                                                  color: _gameMode == 'single'
                                                      ? const Color(0xFF1E293B)
                                                      : const Color(0xFF475569),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Multiplayer
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            _gameMode = 'multiplayer';
                                            _initializeUsers();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _gameMode == 'multiplayer'
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            boxShadow:
                                                _gameMode == 'multiplayer'
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 3,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.group,
                                                color:
                                                    _gameMode == 'multiplayer'
                                                    ? const Color(0xFF6366F1)
                                                    : Colors.grey[500],
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                l10n.multiplayerMode,
                                                style: TextStyle(
                                                  color:
                                                      _gameMode == 'multiplayer'
                                                      ? const Color(0xFF1E293B)
                                                      : const Color(0xFF475569),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Rounds Selection (for Spin Battle game - both single and multiplayer, not WhoFirst or Math)
                          if (!widget.isWhoFirst && !widget.isMathSpinner) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    bottom: 12,
                                  ),
                                  child: Text(
                                    l10n.howManyRounds.toUpperCase(),
                                    style: TextStyle(
                                      color: const Color(0xFF475569),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                _buildGlossyCard(
                                  borderRadius: 24,
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    children: List.generate(10, (index) {
                                      final roundNumber = index + 1;
                                      final isSelected = _rounds == roundNumber;
                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              setState(() {
                                                _rounds = roundNumber;
                                              });
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          offset: const Offset(
                                                            0,
                                                            1,
                                                          ),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$roundNumber',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF6366F1,
                                                          )
                                                        : const Color(
                                                            0xFF475569,
                                                          ),
                                                    fontSize: 16,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w800
                                                        : FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          // Users Section (only show in multiplayer mode)
                          if (_gameMode == 'multiplayer') ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    bottom: 12,
                                  ),
                                  child: Text(
                                    l10n.users.toUpperCase(),
                                    style: TextStyle(
                                      color: const Color(0xFF475569),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                // Player count buttons - horizontal scrollable
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(5, (index) {
                                      final playerCount =
                                          index + 2; // 2P, 3P, 4P, 5P, 6P
                                      final isSelected =
                                          _playerCount == playerCount;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () =>
                                              _updatePlayerCount(playerCount),
                                          child: _buildGlossyCard(
                                            borderRadius: 16,
                                            padding: EdgeInsets.zero,
                                            child: Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFF6366F1)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: isSelected
                                                    ? Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        width: 2,
                                                      )
                                                    : null,
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: const Color(
                                                            0xFF6366F1,
                                                          ).withOpacity(0.2),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${playerCount}P',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF475569,
                                                          ),
                                                    fontSize: 14,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w800
                                                        : FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Players list - glossy card container
                                _buildGlossyCard(
                                  borderRadius: 32,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      // Existing players (NO profile pics, NO drag icons)
                                      ...List.generate(_users.length, (index) {
                                        return _buildPlayerItem(
                                          index: index,
                                          controller: _userControllers[index],
                                          focusNode: _userFocusNodes[index],
                                          hintText: 'Player ${index + 1}',
                                        );
                                      }),
                                      // Invite player option (if not at max)
                                      // if (_playerCount < 6)
                                      //   Opacity(
                                      //     opacity: 0.6,
                                      //     child: _buildPlayerItem(
                                      //       index: _users.length,
                                      //       controller: TextEditingController(),
                                      //       focusNode: FocusNode(),
                                      //       hintText: 'Invite Player ${_users.length + 1}...',
                                      //       isInvite: true,
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  // Bottom indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: 128,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[400]?.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
