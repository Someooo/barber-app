import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Extension helpers on [BuildContext] for theme-dependent surfaces and borders.
extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Card / elevated surface color for current brightness.
  Color get cardSurface =>
      isDarkMode ? AppColors.cardDark : AppColors.cardLight;

  /// 1px border stroke color for current brightness.
  Color get borderColor =>
      isDarkMode ? AppColors.borderDark : AppColors.borderLight;

  /// Input background fill color.
  Color get inputFill => isDarkMode ? AppColors.cardDark : AppColors.white;
}

