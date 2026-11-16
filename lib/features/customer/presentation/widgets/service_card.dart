import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  final ServiceEntity service;
  final VoidCallback? onTap;

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'content_cut':
        return Icons.content_cut;
      case 'face':
        return Icons.face;
      case 'spa':
        return Icons.spa_outlined;
      case 'brush':
        return Icons.brush_outlined;
      case 'star':
        return Icons.auto_awesome;
      default:
        return Icons.content_cut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.languageCode == 'AR';
    final name = isArabic ? service.nameAr : service.nameEn;
    final description =
        isArabic ? service.descriptionAr : service.descriptionEn;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizes.avatarMd,
                  height: AppSizes.avatarMd,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.controlBorder,
                  ),
                  child: Center(
                    child: Icon(
                      _resolveIcon(service.iconName),
                      color: AppColors.neutral,
                      size: AppSizes.iconMd,
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
                        style: AppTextStyles.titleMedium.copyWith(
                          color: scheme.onSurface,
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
                          const Spacer(),
                          Text(
                            context.l10n.priceDisplay(
                              service.price.toStringAsFixed(0),
                            ),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
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
