import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';

class QuickBookCtaBanner extends StatelessWidget {
  const QuickBookCtaBanner({
    super.key,
    this.onBookPressed,
  });

  final VoidCallback? onBookPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: context.cardSurface,
            borderRadius: AppRadius.cardBorder,
            border: Border.all(
              color: context.borderColor,
              width: AppSizes.hairline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSizes.avatarSm,
                    height: AppSizes.avatarSm,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: AppRadius.controlBorder,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: AppSizes.iconSm,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Text(
                      context.l10n.bookNowBanner,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSm,
              Text(
                context.l10n.bookNowBannerSubtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.verticalMd,
              RepaintBoundary(
                child: LuxuryPrimaryButton(
                  text: context.l10n.bookAppointmentCta,
                  onPressed: onBookPressed,
                  prefixIcon: const Icon(
                    Icons.calendar_month,
                    size: AppSizes.iconSm,
                    color: AppColors.neutral,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
