import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Helper widget to wrap pages with theme support
class ThemeWrapper extends StatelessWidget {
  final Widget child;
  
  const ThemeWrapper({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return child;
      },
    );
  }
}
