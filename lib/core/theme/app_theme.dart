import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static const double _cardRadius = 16;
  static const double _controlRadius = 12;
  static const double _buttonHeight = 50;

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.neutral,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.neutral,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.neutral,
    onSurface: AppColors.primary,
    onSurfaceVariant: AppColors.tertiary,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.cardLight,
    surfaceContainer: AppColors.cardLight,
    surfaceContainerHigh: AppColors.cardLight,
    surfaceContainerHighest: AppColors.borderLight,
    outline: AppColors.borderLight,
    outlineVariant: AppColors.borderLight,
    inverseSurface: AppColors.primary,
    onInverseSurface: AppColors.neutral,
    inversePrimary: AppColors.neutral,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.neutral,
    onPrimary: AppColors.primary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.neutral,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.primary,
    onSurface: AppColors.neutral,
    onSurfaceVariant: AppColors.borderLight,
    surfaceContainerLowest: AppColors.primary,
    surfaceContainerLow: AppColors.cardDark,
    surfaceContainer: AppColors.cardDark,
    surfaceContainerHigh: AppColors.cardDark,
    surfaceContainerHighest: AppColors.borderDark,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.borderDark,
    inverseSurface: AppColors.neutral,
    onInverseSurface: AppColors.primary,
    inversePrimary: AppColors.primary,
    surfaceTint: Colors.transparent,
  );

  static ThemeData get lightTheme => _buildTheme(
        scheme: _lightScheme,
        cardColor: AppColors.cardLight,
        borderColor: AppColors.borderLight,
      );

  static ThemeData get darkTheme => _buildTheme(
        scheme: _darkScheme,
        cardColor: AppColors.cardDark,
        borderColor: AppColors.borderDark,
      );

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color cardColor,
    required Color borderColor,
  }) {
    final isDark = scheme.brightness == Brightness.dark;
    final textTheme = AppTextStyles.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_controlRadius),
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      dividerColor: borderColor,
      appBarTheme: AppBarThemeData(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium?.copyWith(fontSize: 22),
        iconTheme: IconThemeData(color: scheme.onSurface),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.38),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(64, _buttonHeight),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: cardColor,
        isDense: false,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.secondary,
        ),
        errorStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.error,
          fontSize: 12,
        ),
        border: inputBorder(borderColor),
        enabledBorder: inputBorder(borderColor),
        focusedBorder: inputBorder(AppColors.secondary, 1.5),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, 1.5),
        disabledBorder: inputBorder(borderColor.withValues(alpha: 0.5)),
      ),
    );
  }
}
