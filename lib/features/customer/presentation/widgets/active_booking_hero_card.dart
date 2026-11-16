import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import '../bloc/customer_home_bloc.dart';
import '../bloc/customer_home_state.dart';

class ActiveBookingHeroCard extends StatelessWidget {
  const ActiveBookingHeroCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final locale = context.languageCode.toLowerCase();
    try {
      final formatter = DateFormat('EEEE, d MMMM • h:mm a', locale);
      return formatter.format(dateTime);
    } catch (_) {
      return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return BlocBuilder<CustomerHomeBloc, CustomerHomeState>(
      buildWhen: (prev, curr) =>
          prev.activeBookingOrNull != curr.activeBookingOrNull ||
          prev.isLoading != curr.isLoading,
      builder: (context, state) {
        final booking = state.activeBookingOrNull;
        if (booking == null) {
          return const SizedBox.shrink();
        }

        final isArabic = context.languageCode == 'AR';
        final isRescheduled = booking.status == BookingStatus.rescheduled;
        final statusLabel = isRescheduled
            ? context.l10n.bookingStatusRescheduled
            : context.l10n.bookingStatusConfirmed;
        final statusType = isRescheduled
            ? LuxuryStatusType.inProgress
            : LuxuryStatusType.confirmed;

        final serviceSummary = booking.services
            .map((s) => isArabic ? s.nameAr : s.nameEn)
            .join(' • ');

        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
            ),
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
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: AppSizes.iconSm,
                                color: AppColors.secondary,
                              ),
                              AppSpacing.horizontalXs,
                              Text(
                                context.l10n.activeBookingTitle,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          LuxuryBadge.status(
                            label: statusLabel,
                            type: statusType,
                          ),
                        ],
                      ),
                      AppSpacing.verticalMd,
                      Row(
                        children: [
                          LuxuryAvatar(
                            fallbackLabel: booking.barberName,
                            size: AppSizes.avatarMd,
                          ),
                          AppSpacing.horizontalMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.barberName,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                AppSpacing.verticalXs,
                                Text(
                                  _formatDateTime(context, booking.dateTime),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalSm,
                      const Divider(height: 1),
                      AppSpacing.verticalSm,
                      Text(
                        serviceSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      if (isRescheduled &&
                          booking.statusReason != null &&
                          booking.statusReason!.isNotEmpty) ...[
                        AppSpacing.verticalSm,
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsetsDirectional.all(
                            AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.controlBorder,
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              width: AppSizes.hairline,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: AppSizes.iconSm,
                                color: AppColors.secondary,
                              ),
                              AppSpacing.horizontalXs,
                              Expanded(
                                child: Text(
                                  context.l10n.rescheduledReasonLabel(
                                    booking.statusReason!,
                                  ),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
