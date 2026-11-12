import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double control = 12.0;
  static const double card = 16.0;
  static const double stadium = 999.0;

  static const BorderRadius controlBorder =
      BorderRadius.all(Radius.circular(control));
  static const BorderRadius cardBorder =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius stadiumBorder =
      BorderRadius.all(Radius.circular(stadium));
}

abstract class AppSizes {
  static const double hairline = 1.0;
  static const double focusBorder = 1.5;

  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;

  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;

  static const double dot = 8.0;

  static const double buttonHeight = 50.0;
  static const double buttonHeightCompact = 40.0;
  static const double loaderStroke = 2.0;

  static const double appBarHeight = 72.0;
  static const double heroBannerHeight = 184.0;
  static const double progressBarHeight = 8.0;

  static const double timelineTimeWidth = 56.0;
  static const double timelineLineWidth = 2.0;

  static const double frostBlur = 12.0;
}

abstract class AppOpacity {
  static const double subtle = 0.08;
  static const double soft = 0.12;
  static const double medium = 0.2;
  static const double disabled = 0.38;
  static const double scrim = 0.65;
}

abstract class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration progress = Duration(milliseconds: 600);
  static const Duration shimmer = Duration(milliseconds: 1400);
}
