import 'package:flutter/material.dart';
import 'multiplayer_spinner_page.dart';

class MultiplayerConfigPage extends StatefulWidget {
  const MultiplayerConfigPage({super.key});

  @override
  State<MultiplayerConfigPage> createState() => _MultiplayerConfigPageState();
}

class _MultiplayerConfigPageState extends State<MultiplayerConfigPage> {
  final List<TextEditingController> _userControllers = [];
  final List<String> _users = [];
  int _rounds = 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _userControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewUser() {
    setState(() {
      _users.add('');
      _userControllers.add(TextEditingController());
    });
  }

  void _removeUser(int index) {
    setState(() {
      _userControllers[index].dispose();
      _userControllers.removeAt(index);
      _users.removeAt(index);
    });
  }

  void _startMultiplayer() {
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
        const SnackBar(
          content: Text('Please add at least one user'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MultiplayerSpinnerPage(
          users: updatedUsers,
          rounds: _rounds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44),
      appBar: AppBar(
        title: const Text(
          'Multiplayer Setup',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rounds Selection Section
            Card(
              color: const Color(0xFF3D3D5C),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How Many Rounds',
                      style: TextStyle(
                        color: Colors.white,
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
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                    '$roundNumber',
                                    style: TextStyle(
                                      color: Colors.white,
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
            const SizedBox(height: 24),
            
            // Users List Section
            Card(
              color: const Color(0xFF3D3D5C),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Users',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addNewUser,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'User',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_users.length, (index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _userControllers[index],
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter user name',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () => _removeUser(index),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_users.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No users. Click "User" to add users.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Start Button
            ElevatedButton(
              onPressed: _startMultiplayer,
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
                'Start',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

