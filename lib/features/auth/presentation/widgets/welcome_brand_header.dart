import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class WelcomeBrandHeader extends StatelessWidget {
  const WelcomeBrandHeader({super.key});

  static const double _logoSize = 300;
  static const double _logoPadding = 14;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _logoSize,
          height: _logoSize,
          padding: const EdgeInsets.all(_logoPadding),
          child: ClipRRect(
            borderRadius: AppRadius.controlBorder,
            child: Image.asset(
              'assets/images/logoApp-withOutBackground.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Text(
          'BarberSync',
          textAlign: TextAlign.center,
          style: GoogleFonts.newsreader(
            fontSize: 38,
            height: 1.15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        AppSpacing.verticalSm,
        Text(
          AppLocalizations.of(context)!.welcomeTagline,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tertiary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
