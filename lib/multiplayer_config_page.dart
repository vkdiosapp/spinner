import 'package:flutter/material.dart';
import 'multiplayer_spinner_page.dart';
import 'who_first_spinner_page.dart';
import 'math_spinner_page.dart';
import 'ad_helper.dart';
import 'app_localizations_helper.dart';
import 'app_theme.dart';

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
  String _gameMode = 'single'; // 'single' or 'multiplayer'
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: Colors.transparent, // Transparent so gradient shows through
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
                        onPressed: () => BackArrowAd.handleBackButton(
                          context: context,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Title - centered on screen
                  Text(
                    widget.isMathSpinner
                        ? l10n.mathSpinner
                        : (widget.isWhoFirst
                              ? l10n.whoFirst
                              : l10n.multiplayer),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Start button - right aligned
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _startMultiplayer,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Text(
                              l10n.start,
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Game Mode Selection Section
                    Card(
                      color: AppTheme.cardBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.gameMode,
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Single Player Radio
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _gameMode = 'single';
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: _gameMode == 'single'
                                            ? const Color(0xFF6C5CE7)
                                            : const Color(0xFF2D2D44),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _gameMode == 'single'
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _gameMode == 'single'
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_unchecked,
                                            color: AppTheme.textColor,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.singlePlayer,
                                            style: TextStyle(
                                              color: AppTheme.textColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Multiplayer Radio
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _gameMode = 'multiplayer';
                                        _initializeUsers();
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: _gameMode == 'multiplayer'
                                            ? const Color(0xFF6C5CE7)
                                            : const Color(0xFF2D2D44),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _gameMode == 'multiplayer'
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _gameMode == 'multiplayer'
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_unchecked,
                                            color: AppTheme.textColor,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.multiplayerMode,
                                            style: TextStyle(
                                              color: AppTheme.textColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Rounds Selection Section (hide for WhoFirst and Math Spinner)
                    if (!widget.isWhoFirst && !widget.isMathSpinner)
                      Card(
                        color: AppTheme.cardBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.howManyRounds,
                                style: TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: List.generate(10, (index) {
                                  final roundNumber = index + 1;
                                  final isSelected = _rounds == roundNumber;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _rounds = roundNumber;
                                          });
                                        },
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF6C5CE7)
                                                : const Color(0xFF2D2D44),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$roundNumber',
                                              style: TextStyle(
                                                color: AppTheme.textColor,
                                                fontSize: 18,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!widget.isWhoFirst) const SizedBox(height: 24),

                    // Users List Section (only show if multiplayer mode)
                    if (_gameMode == 'multiplayer')
                      Card(
                        color: AppTheme.cardBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.users,
                                style: TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Player Count Selection
                              Row(
                                children: List.generate(5, (index) {
                                  final playerCount =
                                      index + 2; // 2P, 3P, 4P, 5P, 6P
                                  final isSelected =
                                      _playerCount == playerCount;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _updatePlayerCount(playerCount),
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF6C5CE7)
                                                : const Color(0xFF2D2D44),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${playerCount}P',
                                              style: TextStyle(
                                                color: AppTheme.textColor,
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 20),
                              // Users List
                              ...List.generate(_users.length, (index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: TextField(
                                    controller: _userControllers[index],
                                    focusNode: _userFocusNodes[index],
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLength: 15,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: l10n.enterUserName,
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFF2D2D44), // Same as spinner items
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      counterText: '', // Hide character counter
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    if (_gameMode == 'multiplayer') const SizedBox(height: 24),
                    if (_gameMode == 'single') const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}
