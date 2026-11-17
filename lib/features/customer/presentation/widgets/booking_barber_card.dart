import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';
import '../../domain/entities/barber_entity.dart';

class BookingBarberCard extends StatelessWidget {
  const BookingBarberCard({
    super.key,
    required this.barber,
    required this.isSelected,
    this.onTap,
  });

  final BarberEntity barber;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isArabic = context.languageCode == 'AR';
    final specialty = isArabic ? barber.specialtyAr : barber.specialtyEn;

    final borderColor = isSelected ? AppColors.secondary : context.borderColor;
    final borderWidth = isSelected ? 1.5 : AppSizes.hairline;

    return RepaintBoundary(
      child: Material(
        color: isSelected
            ? AppColors.secondary.withValues(alpha: 0.08)
            : context.cardSurface,
        borderRadius: AppRadius.cardBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardBorder,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardBorder,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Row(
              children: [
                LuxuryAvatar(
                  fallbackLabel: barber.name,
                  size: AppSizes.avatarMd,
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
                      AppSpacing.verticalXs,
                      Text(
                        specialty,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: AppSizes.iconSm,
                            color: AppColors.secondary,
                          ),
                          AppSpacing.horizontalXs,
                          Text(
                            barber.rating.toStringAsFixed(1),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpacing.horizontalMd,
                          Text(
                            context.l10n.yearsExperience(
                              barber.experienceYears,
                            ),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.horizontalSm,
                Container(
                  width: AppSizes.iconMd,
                  height: AppSizes.iconMd,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.secondary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            size: 14.0,
                            color: AppColors.neutral,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
