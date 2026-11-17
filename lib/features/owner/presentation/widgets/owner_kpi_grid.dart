import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/owner_dashboard_state.dart';

class OwnerKpiGrid extends StatelessWidget {
  const OwnerKpiGrid({
    super.key,
    required this.onAddServiceTap,
    required this.onAddBarberTap,
  });

  final VoidCallback onAddServiceTap;
  final VoidCallback onAddBarberTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;

    return BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
      buildWhen: (prev, curr) {
        if (prev is OwnerDashboardLoaded && curr is OwnerDashboardLoaded) {
          return prev.totalShopRevenue != curr.totalShopRevenue ||
              prev.activeBookingsCount != curr.activeBookingsCount ||
              prev.barbers.length != curr.barbers.length ||
              prev.services.length != curr.services.length ||
              prev.allBookings.length != curr.allBookings.length;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        if (state.isLoading || state.isInitial) {
          return const Column(
            children: [
              LuxuryShimmerCard(height: 110.0),
              AppSpacing.verticalMd,
              LuxuryShimmerCard(height: 110.0),
            ],
          );
        }
        if (state is OwnerDashboardFailure) {
          return Text(
            state.failure.message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          );
        }

        final loaded = state as OwnerDashboardLoaded;
        final isArabic = context.languageCode == 'AR';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _OwnerKpiCard(
                    icon: Icons.payments_outlined,
                    label: l10n.ownerTotalRevenue,
                    value: '\$${loaded.totalShopRevenue.toStringAsFixed(0)}',
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: _OwnerKpiCard(
                    icon: Icons.event_available_outlined,
                    label: l10n.ownerActiveAppointments,
                    value: loaded.activeBookingsCount.toString(),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalMd,
            Row(
              children: [
                Expanded(
                  child: _OwnerKpiCard(
                    icon: Icons.content_cut,
                    label: l10n.ownerTotalBarbers,
                    value: loaded.barbers.length.toString(),
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: _OwnerKpiCard(
                    icon: Icons.design_services_outlined,
                    label: l10n.ownerTotalServices,
                    value: loaded.services.length.toString(),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalLg,
            Text(
              l10n.ownerQuickActions,
              style: AppTextStyles.titleMedium.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalSm,
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_circle_outline,
                    label: l10n.ownerAddNewService,
                    onTap: onAddServiceTap,
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.person_add_alt_1_outlined,
                    label: l10n.ownerAddNewBarber,
                    onTap: onAddBarberTap,
                  ),
                ),
              ],
            ),
            if (loaded.allBookings.isNotEmpty) ...[
              AppSpacing.verticalLg,
              Text(
                l10n.ownerRecentActivity,
                style: AppTextStyles.titleMedium.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.verticalSm,
              ...loaded.allBookings.take(3).map(
                    (b) => Padding(
                      padding: const EdgeInsetsDirectional.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: RepaintBoundary(
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
                              Expanded(
                                child: Text(
                                  '${b.customerName} • ${b.barberName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat.MMMd(isArabic ? 'ar' : 'en')
                                    .add_jm()
                                    .format(b.dateTime),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        );
      },
    );
  }
}

class _OwnerKpiCard extends StatelessWidget {
  const _OwnerKpiCard({
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppSizes.iconMd, color: AppColors.secondary),
            AppSpacing.verticalSm,
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return RepaintBoundary(
      child: Material(
        color: AppColors.secondary.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.cardBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardBorder,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardBorder,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.4),
                width: AppSizes.hairline,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: AppSizes.iconMd, color: AppColors.secondary),
                AppSpacing.horizontalSm,
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
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
