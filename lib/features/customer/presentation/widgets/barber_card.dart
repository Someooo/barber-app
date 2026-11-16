import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';

class BarberCard extends StatelessWidget {
  const BarberCard({
    super.key,
    required this.barber,
    this.onTap,
  });

  final BarberEntity barber;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.languageCode == 'AR';
    final specialty = isArabic ? barber.specialtyAr : barber.specialtyEn;
    final scheme = context.colors;

    return RepaintBoundary(
      child: Material(
        color: context.cardSurface,
        borderRadius: AppRadius.cardBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardBorder,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardBorder,
              border: Border.all(
                color: context.borderColor,
                width: AppSizes.hairline,
              ),
            ),
            child: Row(
              children: [
                LuxuryAvatar(
                  fallbackLabel: barber.name,
                  size: AppSizes.avatarLg,
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              barber.name,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: AppSizes.iconSm,
                                color: AppColors.secondary,
                              ),
                              AppSpacing.horizontalXs,
                              Text(
                                barber.rating.toStringAsFixed(1),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        specialty,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.verticalSm,
                      Row(
                        children: [
                          Text(
                            context.l10n.yearsExperience(
                              barber.experienceYears,
                            ),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          LuxuryBadge.status(
                            label: barber.isAvailableToday
                                ? context.l10n.availableTodayBadge
                                : context.l10n.unavailableBadge,
                            type: barber.isAvailableToday
                                ? LuxuryStatusType.confirmed
                                : LuxuryStatusType.cancelled,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
