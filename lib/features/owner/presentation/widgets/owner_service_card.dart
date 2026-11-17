import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';

class OwnerServiceCard extends StatelessWidget {
  const OwnerServiceCard({
    super.key,
    required this.service,
    required this.onDelete,
  });

  final ServiceEntity service;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isArabic = context.languageCode == 'AR';
    final primaryName = isArabic ? service.nameAr : service.nameEn;
    final secondaryName = isArabic ? service.nameEn : service.nameAr;

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
            Container(
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: AppOpacity.soft),
                borderRadius: AppRadius.controlBorder,
              ),
              child: const Icon(
                Icons.content_cut,
                color: AppColors.secondary,
                size: AppSizes.iconMd,
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (secondaryName.isNotEmpty) ...[
                    AppSpacing.verticalXs,
                    Text(
                      secondaryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  AppSpacing.verticalXs,
                  Text(
                    '\$${service.price.toStringAsFixed(0)} • ${context.l10n.durationMinutesLabel(service.durationMinutes)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
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
