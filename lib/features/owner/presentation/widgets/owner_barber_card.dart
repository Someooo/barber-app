import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';

class OwnerBarberCard extends StatelessWidget {
  const OwnerBarberCard({
    super.key,
    required this.barber,
    this.isOwnerSelf = false,
    required this.onDelete,
  });

  final BarberEntity barber;
  final bool isOwnerSelf;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isArabic = context.languageCode == 'AR';
    final specialty = isArabic ? barber.specialtyAr : barber.specialtyEn;
    final hasImage = barber.imageUrl != null && barber.imageUrl!.isNotEmpty;

    return RepaintBoundary(
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
        child: Row(
          children: [
            LuxuryAvatar(
              image: hasImage ? NetworkImage(barber.imageUrl!) : null,
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
                      Flexible(
                        child: Text(
                          barber.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isOwnerSelf) ...[
                        AppSpacing.horizontalSm,
                        LuxuryBadge.tier(
                          label: context.l10n.ownerYouBadge,
                          backgroundColor:
                              AppColors.secondary.withValues(alpha: 0.15),
                          foregroundColor: AppColors.secondary,
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Row(
                    children: [
                      Text(
                        context.l10n.yearsExperience(barber.experienceYears),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.horizontalSm,
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
            if (!isOwnerSelf)
              IconButton(
                onPressed: onDelete,
                tooltip: context.l10n.ownerDeleteConfirm,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
