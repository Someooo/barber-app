import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  // Headlines & Titles (Newsreader serif)
  static TextStyle get headlineLarge => GoogleFonts.newsreader(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      );

  static TextStyle get headlineMedium => GoogleFonts.newsreader(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => GoogleFonts.newsreader(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
      );

  // Body & Labels (Plus Jakarta Sans)
  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextTheme get textTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.newsreader(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.newsreader(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.newsreader(textStyle: base.displaySmall),
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: GoogleFonts.newsreader(textStyle: base.headlineSmall),
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelSmall: labelSmall,
    );
  }
}
