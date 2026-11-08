import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF121212); // Obsidian Black
  static const Color secondary = Color(0xFFA17653); // Warm Bronze Accent
  static const Color tertiary = Color(0xFF4A4643); // Muted Charcoal
  static const Color neutral = Color(0xFFF5EFED); // Warm Ivory / Cream

  // Card surfaces
  static const Color cardLight = Color(0xFFFAF7F5);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Borders
  static const Color borderLight = Color(0xFFE5DDD8);
  static const Color borderDark = Color(0xFF2E2C2A);

  // Status
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);

  // Foregrounds
  static const Color white = Color(0xFFFFFFFF);
}
