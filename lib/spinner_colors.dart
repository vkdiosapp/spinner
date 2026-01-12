import 'package:flutter/material.dart';

/// Spinner Color Constants
///
/// Centralized color definitions for spinner segments.
/// Change colors here to update throughout the entire app.
class SpinnerColors {
  // Prevent instantiation
  SpinnerColors._();

  /// List of spinner segment colors in order
  /// Colors are assigned line-wise (sequentially) and repeat if there are more segments
  // static const List<Color> segmentColors = [
  //   Color(0xFFFF6B35), // Orange
  //   Color(0xFF6C5CE7), // Purple
  //   Color(0xFF74B9FF), // Light Blue
  //   Color(0xFF00D2D3), // Cyan
  //   Color(0xFFFFC312), // Yellow
  //   Color(0xFFEE5A6F), // Pink
  //   Color(0xFF00B894), // Green
  //   Color(0xFFFF6348), // Red Orange
  //   Color(0xFF0984E3), // Blue
  //   Color(0xFFFF00FF), // Magenta/Fuchsia
  //   Color(0xFF00FF7F), // Spring Green
  // ];

  static const List<Color> segmentColors = [
    Color(0xFFFF6B35), // Vibrant Orange
    Color(0xFF845EC2), // Soft Purple
    Color(0xFF4D96FF), // Bright Blue
    Color(0xFF00C9A7), // Teal
    Color(0xFFFFC75F), // Warm Yellow
    Color(0xFFFF9671), // Coral Pink
    Color(0xFF2ECC71), // Emerald Green
    Color(0xFFE17055), // Red Orange
    Color(0xFF0984E3), // Deep Sky Blue
    Color(0xFFD63384), // Magenta
    Color(0xFF00B894), // Mint Green
    Color(0xFF6C5CE7), // Indigo
  ];

  /// Get color for a segment by index
  /// Colors repeat cyclically if there are more segments than colors
  static Color getColor(int index) {
    return segmentColors[index % segmentColors.length];
  }

  /// Get all colors (useful for iteration)
  static List<Color> get allColors => List.unmodifiable(segmentColors);
}
