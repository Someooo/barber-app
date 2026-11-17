import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';

class BarberAvailabilityKpiCard extends StatelessWidget {
  const BarberAvailabilityKpiCard({
    super.key,
    required this.isAvailableToday,
    required this.todayAppointmentsCount,
    required this.todayExpectedRevenue,
    required this.onAvailabilityChanged,
  });

  final bool isAvailableToday;
  final int todayAppointmentsCount;
  final double todayExpectedRevenue;
  final ValueChanged<bool> onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isDark = context.isDarkMode;

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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.availableTodayBadge,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        isAvailableToday
                            ? context.l10n.availableTodayBadge
                            : context.l10n.unavailableBadge,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isAvailableToday
                              ? AppColors.success
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                RepaintBoundary(
                  child: Switch(
                    value: isAvailableToday,
                    onChanged: onAvailabilityChanged,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.secondary,
                    inactiveThumbColor:
                        isDark ? AppColors.neutral : AppColors.primary,
                    inactiveTrackColor:
                        isDark ? AppColors.borderDark : AppColors.cream,
                    trackOutlineColor: WidgetStatePropertyAll(
                      AppColors.secondary.withValues(alpha: 0.5),
                    ),
                    trackOutlineWidth:
                        const WidgetStatePropertyAll(AppSizes.hairline),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalMd,
            const Divider(height: 1),
            AppSpacing.verticalMd,
            Row(
              children: [
                Expanded(
                  child: _KpiTile(
                    icon: Icons.event_available_outlined,
                    label: context.l10n.barberTodayAppointments,
                    value: todayAppointmentsCount.toString(),
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: _KpiTile(
                    icon: Icons.payments_outlined,
                    label: context.l10n.barberExpectedRevenue,
                    value: '\$${todayExpectedRevenue.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: AppOpacity.subtle),
        borderRadius: AppRadius.controlBorder,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: AppSizes.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconSm,
                color: AppColors.secondary,
              ),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalXs,
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
