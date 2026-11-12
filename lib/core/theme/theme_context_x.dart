import 'package:flutter/material.dart';

import 'app_colors.dart';

extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  ColorScheme get colors => Theme.of(this).colorScheme;

  Color get cardSurface =>
      isDarkMode ? AppColors.cardDark : AppColors.cardLight;

  Color get borderColor =>
      isDarkMode ? AppColors.borderDark : AppColors.borderLight;

  Color get inputFill => isDarkMode ? AppColors.cardDark : AppColors.white;
}
