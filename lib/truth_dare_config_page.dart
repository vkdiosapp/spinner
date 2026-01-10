import 'package:flutter/material.dart';
import 'truth_dare_level_page.dart';
import 'ad_helper.dart';
import 'app_localizations_helper.dart';

class TruthDareConfigPage extends StatefulWidget {
  const TruthDareConfigPage({super.key});

  @override
  State<TruthDareConfigPage> createState() => _TruthDareConfigPageState();
}

class _TruthDareConfigPageState extends State<TruthDareConfigPage> {
  final List<TextEditingController> _userControllers = [];
  final List<FocusNode> _userFocusNodes = [];
  final List<String> _users = [];
  int _playerCount = 2; // Default to 2P

  @override
  void initState() {
    super.initState();
    // Initialize with default 2 players
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

    // Populate based on player count
    for (int i = 0; i < _playerCount; i++) {
      final playerName = 'Player ${i + 1}';
      _users.add(playerName);
      _userControllers.add(TextEditingController(text: playerName));
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

  void _startTruthDare() {
    final l10n = AppLocalizationsHelper.of(context);
    
    // Update users from controllers
    final updatedUsers = <String>[];
    for (var controller in _userControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        updatedUsers.add(text);
      }
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
            content: Text(
              l10n.duplicateUserName(user),
            ),
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
        builder: (context) => TruthDareLevelPage(users: updatedUsers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);
    
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
                        onPressed: () => BackArrowAd.handleBackButton(
                          context: context,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Title - centered on screen
                  Text(
                    l10n.truthDare,
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
                        color: const Color(0xFFFF1493),
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
                          onTap: _startTruthDare,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              l10n.start,
                              style: const TextStyle(
                                color: Colors.white,
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
                    // Users Section (with Player Count Selection)
                    Card(
                      color: const Color(0xFF3D3D5C),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.users,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Player Count Selection
                            Row(
                              children: List.generate(5, (index) {
                                final playerCount = index + 2; // 2P, 3P, 4P, 5P, 6P
                                final isSelected = _playerCount == playerCount;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _updatePlayerCount(playerCount),
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFFF1493)
                                              : const Color(0xFF2D2D44),
                                          borderRadius: BorderRadius.circular(12),
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
                                              color: Colors.white,
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
                                  textCapitalization: TextCapitalization.words,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: l10n.enterUserName,
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF2D2D44),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
