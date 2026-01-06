import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'home_page.dart';

class MultiplayerResultsPage extends StatefulWidget {
  final List<String> users;
  final int rounds;
  final Map<int, Map<String, int>> roundScores;
  final Map<String, int> totalScores;

  const MultiplayerResultsPage({
    super.key,
    required this.users,
    required this.rounds,
    required this.roundScores,
    required this.totalScores,
  });

  @override
  State<MultiplayerResultsPage> createState() => _MultiplayerResultsPageState();
}

class _MultiplayerResultsPageState extends State<MultiplayerResultsPage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  List<MapEntry<String, int>> get _sortedUsers {
    final sorted = widget.totalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  Gradient? _getMedalGradient(int rank) {
    switch (rank) {
      case 1:
        // Gold gradient - rich yellow to orange with shine
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700), // Bright gold
            const Color(0xFFFFA500), // Orange gold
            const Color(0xFFFFD700), // Bright gold
            const Color(0xFFFFC125), // Goldenrod
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        );
      case 2:
        // Silver gradient - metallic gray to white with shine
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8E8E8), // Light silver
            const Color(0xFFFFFFFF), // White
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFE8E8E8), // Light silver
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        );
      case 3:
        // Bronze gradient - brown to copper with metallic shine
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFCD7F32), // Bronze
            const Color(0xFFB87333), // Darker bronze
            const Color(0xFFCD853F), // Peru bronze
            const Color(0xFFCD7F32), // Bronze
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        );
      default:
        return null; // No gradient for ranks 4+
    }
  }

  Future<void> _shareResults(BuildContext context) async {
    try {
      // Add a delay to ensure content is fully rendered
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Capture screenshot
      final image = await _screenshotController.capture();
      
      if (image != null && image.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'multiplayer_results_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        
        await file.writeAsBytes(image);
        
        // Verify file was created
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > 0) {
            // Get screen size for share position
            final screenSize = MediaQuery.of(context).size;
            final xFile = XFile(filePath);
            
            // Use shareXFiles with sharePositionOrigin for iOS compatibility
            await Share.shareXFiles(
              [xFile],
              text: 'Check out our multiplayer spinner game results!',
              sharePositionOrigin: Rect.fromLTWH(
                0,
                0,
                screenSize.width,
                screenSize.height,
              ),
            );
          } else {
            throw Exception('Screenshot file is empty');
          }
        } else {
          throw Exception('Screenshot file was not created at $filePath');
        }
      } else {
        throw Exception('Failed to capture screenshot - image is null or empty');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
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
            Builder(
              builder: (context) {
                return Positioned(
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
                      onPressed: () => _shareResults(context),
                    ),
                  ),
                );
              },
            ),
            // Main content
            Screenshot(
              controller: _screenshotController,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    const Text(
                      '🏆 Game Results 🏆',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Users List with Rankings
                    ..._sortedUsers.asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final userEntry = entry.value;
                      final user = userEntry.key;
                      final totalScore = userEntry.value;
                      final medalEmoji = _getMedalEmoji(rank);
                      final medalGradient = _getMedalGradient(rank);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: medalGradient,
                          color: medalGradient == null ? Colors.white : null, // White for ranks 4+
                          borderRadius: BorderRadius.circular(16),
                          border: rank <= 3
                              ? Border.all(color: Colors.white.withOpacity(0.8), width: 2.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: rank <= 3 
                                  ? (rank == 1 
                                      ? const Color(0xFFFFD700).withOpacity(0.4) // Gold glow
                                      : rank == 2 
                                          ? const Color(0xFFC0C0C0).withOpacity(0.4) // Silver glow
                                          : const Color(0xFFCD7F32).withOpacity(0.4)) // Bronze glow
                                  : Colors.black.withOpacity(0.2),
                              blurRadius: rank <= 3 ? 12 : 8,
                              spreadRadius: rank <= 3 ? 2 : 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User header with rank
                              Row(
                                children: [
                                  // Rank badge
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: rank <= 3
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.black.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        medalEmoji.isNotEmpty
                                            ? medalEmoji
                                            : '$rank',
                                        style: TextStyle(
                                          color: rank <= 3 ? Colors.white : Colors.black,
                                          fontSize: rank <= 3 ? 24 : 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // User name
                                  Expanded(
                                    child: Text(
                                      user,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Total score
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Total: $totalScore',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Round scores - all in one line
                              Text(
                                'Rounds: ${List.generate(widget.rounds, (roundIndex) {
                                  final round = roundIndex + 1;
                                  final roundScore = widget.roundScores[round]?[user] ?? 0;
                                  return 'R$round: $roundScore';
                                }).join(' | ')}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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

