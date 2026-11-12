import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/theme/theme_context_x.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  static const double _logoSize = 120.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Container(
        //   width: _logoSize,
        //   height: _logoSize,
        //   padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
        //   decoration: BoxDecoration(
        //     color: context.cardSurface,
        //     borderRadius: AppRadius.cardBorder,
        //     border: Border.all(
        //       color: context.borderColor,
        //       width: AppSizes.hairline,
        //     ),
        //     boxShadow: [
        //       BoxShadow(
        //         color: AppColors.primary.withValues(alpha: AppOpacity.subtle),
        //         blurRadius: AppSpacing.md,
        //         offset: const Offset(0, AppSpacing.xs),
        //       ),
        //     ],
        //   ),

        // ),
        const BrandLogo(
          size: _logoSize,
          borderRadius: AppRadius.controlBorder,
        ),
        AppSpacing.verticalLg,
        Text(
          l10n.loginWelcomeTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.newsreader(
            fontSize: 32,
            height: 40 / 32,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
            letterSpacing: -0.25,
          ),
        ),
        AppSpacing.verticalSm,
        Text(
          l10n.loginSubtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
