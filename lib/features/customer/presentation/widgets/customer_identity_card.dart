import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';

class CustomerIdentityCard extends StatelessWidget {
  const CustomerIdentityCard({
    super.key,
    required this.fullName,
    required this.phoneNumber,
    required this.roleLabel,
  });

  final String fullName;
  final String phoneNumber;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
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
          children: [
            LuxuryAvatar(
              fallbackLabel: fullName,
              size: AppSizes.avatarLg,
            ),
            AppSpacing.verticalMd,
            Text(
              fullName,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (phoneNumber.isNotEmpty) ...[
              AppSpacing.verticalXs,
              Text(
                phoneNumber,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            AppSpacing.verticalSm,
            LuxuryBadge.tier(
              label: roleLabel,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              foregroundColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
