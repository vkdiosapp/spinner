import 'package:flutter/material.dart';
import 'truth_dare_spinner_page.dart';
import 'ad_helper.dart';
import 'animated_gradient_background.dart';

class TruthDareLevelPage extends StatelessWidget {
  final List<String> users;
  
  const TruthDareLevelPage({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      {'name': 'Easy', 'color': const Color(0xFF00B894)},
      {'name': 'Medium', 'color': const Color(0xFFFFC312)},
      {'name': 'Hard', 'color': const Color(0xFFFF6B35)},
      {'name': 'Extreme', 'color': const Color(0xFFEE5A6F)},
      {'name': 'Insane', 'color': const Color(0xFF5F27CD)},
    ];

    return AnimatedGradientBackground(
      child: Scaffold(
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
                  const Text(
                    'Truth & Dare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Choose a Level',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ...levels.asMap().entries.map((entry) {
                      final index = entry.key;
                      final level = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          color: const Color(0xFF3D3D5C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TruthDareSpinnerPage(
                                    level: level['name'] as String,
                                    users: users,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: level['color'] as Color,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: level['color'] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      level['name'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: level['color'] as Color,
                                  ),
                                ],
                              ),
                            ),
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
      ),
      ),
    );
  }
}

