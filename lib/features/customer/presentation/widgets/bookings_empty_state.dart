import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';

class BookingsEmptyState extends StatelessWidget {
  const BookingsEmptyState({
    super.key,
    required this.isUpcoming,
  });

  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final title = isUpcoming
        ? context.l10n.noUpcomingBookingsTitle
        : context.l10n.noHistoryBookingsTitle;
    final subtitle = isUpcoming
        ? context.l10n.noUpcomingBookingsSubtitle
        : context.l10n.noHistoryBookingsSubtitle;

    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64.0,
                height: 64.0,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isUpcoming
                        ? Icons.calendar_month_outlined
                        : Icons.history_outlined,
                    size: AppSizes.iconLg,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              AppSpacing.verticalMd,
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.verticalXs,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
