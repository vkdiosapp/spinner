import 'package:flutter/material.dart';
import 'dart:ui';
import 'app_theme.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'app_localizations_helper.dart';
import 'ad_helper.dart';
import 'animated_gradient_background.dart';

class MultiplayerResultsPage extends StatefulWidget {
  final List<String> users;
  final int rounds;
  final Map<int, Map<String, int>> roundScores;
  final Map<String, int> totalScores;
  final bool hideScores;

  const MultiplayerResultsPage({
    super.key,
    required this.users,
    required this.rounds,
    required this.roundScores,
    required this.totalScores,
    this.hideScores = false,
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
        // Gold gradient matching HTML - #fbbf24 to #f59e0b to #d97706
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFBBF24), // #fbbf24
            const Color(0xFFF59E0B), // #f59e0b
            const Color(0xFFD97706), // #d97706
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case 2:
        // Silver gradient matching HTML - #f3f4f6 to #d1d5db to #9ca3af
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF3F4F6), // #f3f4f6
            const Color(0xFFD1D5DB), // #d1d5db
            const Color(0xFF9CA3AF), // #9ca3af
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case 3:
        // Bronze gradient matching HTML - #ea580c to #c2410c to #7c2d12
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEA580C), // #ea580c
            const Color(0xFFC2410C), // #c2410c
            const Color(0xFF7C2D12), // #7c2d12
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      default:
        return null; // No gradient for ranks 4+
    }
  }

  String _getRankTitle(int rank) {
    switch (rank) {
      case 1:
        return 'Grand Champion';
      case 2:
        return 'Runner Up';
      case 3:
        return 'Finalist';
      default:
        return '';
    }
  }

  Color _getRankIconColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFF59E0B); // gold-DEFAULT
      case 2:
        return const Color(0xFF9CA3AF); // silver-DEFAULT
      case 3:
        return const Color(0xFFD97706); // bronze-DEFAULT
      default:
        return Colors.grey;
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
        final fileName =
            'multiplayer_results_${DateTime.now().millisecondsSinceEpoch}.png';
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
        throw Exception(
          'Failed to capture screenshot - image is null or empty',
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizationsHelper.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSharing(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _goHome() {
    // Pop back to config page (config page is in stack since spinner used pushReplacement)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return AnimatedGradientBackground(
          child: Scaffold(
            backgroundColor:
                Colors.transparent, // Transparent so gradient shows through
            body: SafeArea(
              child: Column(
                children: [
                  // Fixed header with back button, title, and share button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button - glass card style
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _goHome,
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Color(0xFF475569),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Title with trophy icons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Color(0xFFF59E0B),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 41, 44, 232),
                                  Color.fromARGB(255, 136, 16, 248),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                l10n.gameResults,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.emoji_events,
                              color: Color(0xFFF59E0B),
                              size: 24,
                            ),
                          ],
                        ),
                        // Share button - glass card style
                        Builder(
                          builder: (context) {
                            return ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 12,
                                  sigmaY: 12,
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
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => _shareResults(context),
                                      child: const Icon(
                                        Icons.ios_share,
                                        color: Color(0xFF475569),
                                        size: 20,
                                      ),
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
                  // Scrollable content
                  Expanded(
                    child: Screenshot(
                      controller: _screenshotController,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Native Ad above first user
                            const NativeAdWidget(),
                            const SizedBox(height: 16),
                            // Top 3 players with special glossy cards
                            ..._sortedUsers.asMap().entries.take(3).map((
                              entry,
                            ) {
                              final rank = entry.key + 1;
                              final userEntry = entry.value;
                              final user = userEntry.key;
                              final totalScore = userEntry.value;
                              final medalGradient = _getMedalGradient(rank);
                              final rankTitle = _getRankTitle(rank);
                              final iconColor = _getRankIconColor(rank);
                              final isGold = rank == 1;

                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  gradient: medalGradient,
                                  borderRadius: BorderRadius.circular(
                                    isGold ? 32 : 28,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: rank == 1
                                          ? const Color(
                                              0xFFD97706,
                                            ).withOpacity(0.4)
                                          : rank == 2
                                          ? const Color(
                                              0xFF6B7280,
                                            ).withOpacity(0.3)
                                          : const Color(
                                              0xFF7C2D12,
                                            ).withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: -5,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.6),
                                      blurRadius: 0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Glossy overlay effect
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.0),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                              isGold ? 32 : 28,
                                            ),
                                            topRight: Radius.circular(
                                              isGold ? 32 : 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Padding(
                                      padding: EdgeInsets.all(isGold ? 24 : 20),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              // Avatar with rank badge
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: isGold ? 64 : 56,
                                                    height: isGold ? 64 : 56,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(
                                                            rank == 1
                                                                ? 0.2
                                                                : rank == 2
                                                                ? 0.4
                                                                : 0.2,
                                                          ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(
                                                              rank == 1
                                                                  ? 0.4
                                                                  : rank == 2
                                                                  ? 0.6
                                                                  : 0.4,
                                                            ),
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        user.length > 2
                                                            ? '${rank}'
                                                            : user.toUpperCase(),
                                                        style: TextStyle(
                                                          color: rank == 1
                                                              ? Colors.white
                                                              : rank == 2
                                                              ? const Color(
                                                                  0xFF374151,
                                                                )
                                                              : Colors.white,
                                                          fontSize: isGold
                                                              ? 20
                                                              : 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Rank icon badge
                                                  // Positioned(
                                                  //   bottom: -4,
                                                  //   right: -4,
                                                  //   child: Container(
                                                  //     width: isGold ? 32 : 24,
                                                  //     height: isGold ? 32 : 24,
                                                  //     decoration: BoxDecoration(
                                                  //       color: Colors.white,
                                                  //       shape: BoxShape.circle,
                                                  //       boxShadow: [
                                                  //         BoxShadow(
                                                  //           color: Colors.black.withOpacity(0.1),
                                                  //           blurRadius: isGold ? 8 : 4,
                                                  //           offset: const Offset(0, 2),
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //     child: Icon(
                                                  //       rank == 1
                                                  //           ? Icons.stars
                                                  //           : rank == 2
                                                  //               ? Icons.looks_two
                                                  //               : Icons.looks_3,
                                                  //       color: iconColor,
                                                  //       size: isGold ? 20 : 18,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              const SizedBox(width: 16),
                                              // Name and title
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user,
                                                      style: TextStyle(
                                                        color: rank == 1
                                                            ? Colors.white
                                                            : rank == 2
                                                            ? const Color(
                                                                0xFF1F2937,
                                                              )
                                                            : Colors.white,
                                                        fontSize: isGold
                                                            ? 20
                                                            : 18,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      rankTitle,
                                                      style: TextStyle(
                                                        color: rank == 1
                                                            ? Colors.white
                                                                  .withOpacity(
                                                                    0.8,
                                                                  )
                                                            : rank == 2
                                                            ? const Color(
                                                                0xFF6B7280,
                                                              )
                                                            : Colors.white
                                                                  .withOpacity(
                                                                    0.7,
                                                                  ),
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Total score
                                              if (!widget.hideScores)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Total Score',
                                                      style: TextStyle(
                                                        color: rank == 1
                                                            ? Colors.white
                                                                  .withOpacity(
                                                                    0.7,
                                                                  )
                                                            : rank == 2
                                                            ? const Color(
                                                                0xFF9CA3AF,
                                                              )
                                                            : Colors.white
                                                                  .withOpacity(
                                                                    0.6,
                                                                  ),
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      totalScore.toString(),
                                                      style: TextStyle(
                                                        color: rank == 1
                                                            ? Colors.white
                                                            : rank == 2
                                                            ? const Color(
                                                                0xFF1F2937,
                                                              )
                                                            : Colors.white,
                                                        fontSize: isGold
                                                            ? 32
                                                            : 24,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          // Round scores
                                          if (!widget.hideScores) ...[
                                            const SizedBox(height: 12),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                l10n.rounds(
                                                  List.generate(widget.rounds, (
                                                    roundIndex,
                                                  ) {
                                                    final round =
                                                        roundIndex + 1;
                                                    final roundScore =
                                                        widget
                                                            .roundScores[round]?[user] ??
                                                        0;
                                                    return l10n.roundScore(
                                                      round.toString(),
                                                      roundScore.toString(),
                                                    );
                                                  }).join(' | '),
                                                ),
                                                style: TextStyle(
                                                  color: rank == 1
                                                      ? Colors.white
                                                            .withOpacity(0.85)
                                                      : rank == 2
                                                      ? const Color(0xFF4B5563)
                                                      : Colors.white
                                                            .withOpacity(0.75),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            // Other players (4th+) with glass cards
                            if (_sortedUsers.length > 3) ...[
                              const SizedBox(height: 8),
                              ..._sortedUsers.asMap().entries.skip(3).map((
                                entry,
                              ) {
                                final rank = entry.key + 1;
                                final userEntry = entry.value;
                                final user = userEntry.key;
                                final totalScore = userEntry.value;

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 12,
                                      sigmaY: 12,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.6),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // Rank number
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      rank.toString(),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF64748B,
                                                        ),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Player name
                                                Expanded(
                                                  child: Text(
                                                    user,
                                                    style: const TextStyle(
                                                      color: Color(0xFF1F2937),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                // Total score
                                                if (!widget.hideScores)
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Total',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFF9CA3AF,
                                                          ),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Text(
                                                        totalScore.toString(),
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF1F2937,
                                                          ),
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            // Round scores
                                            if (!widget.hideScores) ...[
                                              const SizedBox(height: 12),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 44,
                                                ),
                                                child: Text(
                                                  l10n.rounds(
                                                    List.generate(widget.rounds, (
                                                      roundIndex,
                                                    ) {
                                                      final round =
                                                          roundIndex + 1;
                                                      final roundScore =
                                                          widget
                                                              .roundScores[round]?[user] ??
                                                          0;
                                                      return l10n.roundScore(
                                                        round.toString(),
                                                        roundScore.toString(),
                                                      );
                                                    }).join(' | '),
                                                  ),
                                                  style: const TextStyle(
                                                    color: Color(0xFF6B7280),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Play Again button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _goHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ), // primary color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.replay,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Play Again',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom indicator
                  Container(
                    width: 128,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9CA3AF).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
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
