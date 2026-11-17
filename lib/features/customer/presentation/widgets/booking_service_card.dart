import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import '../../domain/entities/service_entity.dart';

class BookingServiceCard extends StatelessWidget {
  const BookingServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    this.onTap,
  });

  final ServiceEntity service;
  final bool isSelected;
  final VoidCallback? onTap;

  IconData _resolveIcon(String iconName) {
    return switch (iconName) {
      'content_cut' => Icons.content_cut,
      'face' => Icons.face,
      'spa' => Icons.spa,
      'brush' => Icons.brush,
      'star' => Icons.star,
      _ => Icons.content_cut,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isArabic = context.languageCode == 'AR';
    final name = isArabic ? service.nameAr : service.nameEn;
    final description =
        isArabic ? service.descriptionAr : service.descriptionEn;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizes.avatarSm,
                  height: AppSizes.avatarSm,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary.withValues(alpha: 0.2)
                        : context.borderColor.withValues(alpha: 0.5),
                    borderRadius: AppRadius.controlBorder,
                  ),
                  child: Center(
                    child: Icon(
                      _resolveIcon(service.iconName),
                      size: AppSizes.iconSm,
                      color: isSelected
                          ? AppColors.secondary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.verticalSm,
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: AppSizes.iconSm,
                            color: scheme.onSurfaceVariant,
                          ),
                          AppSpacing.horizontalXs,
                          Text(
                            context.l10n.durationMinutesLabel(
                              service.durationMinutes,
                            ),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.horizontalMd,
                          Text(
                            context.l10n.priceDisplay(
                              service.price.toStringAsFixed(0),
                            ),
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
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
                    borderRadius: BorderRadius.circular(12),
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
