import 'package:flutter/material.dart';
import 'spinner_config_page.dart';
import 'multiplayer_config_page.dart';
import 'dice_page.dart';
import 'truth_dare_level_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Random Picker',
        'description': 'Create a custom spinner with your own items',
        'icon': Icons.shuffle,
        'color': const Color(0xFF6C5CE7),
        'route': const SpinnerConfigPage(),
      },
      {
        'title': 'Multiplayer',
        'description': 'Play with friends and compete in rounds',
        'icon': Icons.people,
        'color': const Color(0xFFFF6B35),
        'route': const MultiplayerConfigPage(),
      },
      {
        'title': 'Dice',
        'description': 'Roll two dice and see the total',
        'icon': Icons.casino,
        'color': const Color(0xFF00D2FF),
        'route': const DicePage(),
      },
      {
        'title': 'Truth & Dare',
        'description': 'Play truth and dare with friends',
        'icon': Icons.celebration,
        'color': const Color(0xFFFF1493),
        'route': const TruthDareLevelPage(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final itemSize = isLandscape
                ? constraints.maxWidth / 5
                : constraints.maxWidth / 2.5;
            
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Spinner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: items.map((item) {
                          return SizedBox(
                            width: itemSize,
                            height: itemSize,
                            child: Card(
                              color: const Color(0xFF3D3D5C),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => item['route'] as Widget,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: itemSize * 0.35,
                                        height: itemSize * 0.35,
                                        decoration: BoxDecoration(
                                          color: item['color'] as Color,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          item['icon'] as IconData,
                                          color: Colors.white,
                                          size: itemSize * 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['title'] as String,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: itemSize * 0.08,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['description'] as String,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: itemSize * 0.055,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

