import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';

class BarberAppointmentCard extends StatelessWidget {
  const BarberAppointmentCard({
    super.key,
    required this.booking,
    this.isActionInProgress = false,
    this.onComplete,
    this.onReschedule,
    this.onCancel,
  });

  final BookingEntity booking;
  final bool isActionInProgress;
  final VoidCallback? onComplete;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isArabic = context.languageCode == 'AR';
    final l10n = context.l10n;
    final dateText = DateFormat.yMMMd(isArabic ? 'ar' : 'en')
        .add_jm()
        .format(booking.dateTime);
    final serviceNames =
        booking.services.map((s) => isArabic ? s.nameAr : s.nameEn).join(' • ');
    final statusBadgeType = switch (booking.status) {
      BookingStatus.confirmed => LuxuryStatusType.confirmed,
      BookingStatus.rescheduled => LuxuryStatusType.pending,
      BookingStatus.completed => LuxuryStatusType.completed,
      BookingStatus.cancelled => LuxuryStatusType.cancelled,
    };
    final statusLabel = switch (booking.status) {
      BookingStatus.confirmed => l10n.bookingStatusConfirmed,
      BookingStatus.rescheduled => l10n.bookingStatusRescheduled,
      BookingStatus.completed => l10n.bookingStatusCompleted,
      BookingStatus.cancelled => l10n.bookingStatusCancelled,
    };
    final hasActions =
        onComplete != null || onReschedule != null || onCancel != null;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.customerName.isNotEmpty
                        ? booking.customerName
                        : l10n.roleCustomerOption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSpacing.horizontalSm,
                LuxuryBadge.status(
                  label: statusLabel,
                  type: statusBadgeType,
                ),
              ],
            ),
            if (serviceNames.isNotEmpty) ...[
              AppSpacing.verticalXs,
              Text(
                serviceNames,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            AppSpacing.verticalSm,
            Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  size: AppSizes.iconSm,
                  color: AppColors.secondary,
                ),
                AppSpacing.horizontalXs,
                Expanded(
                  child: Text(
                    dateText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${booking.totalDurationMinutes} min • \$${booking.totalPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (booking.statusReason != null &&
                booking.statusReason!.isNotEmpty) ...[
              AppSpacing.verticalSm,
              Text(
                l10n.rescheduledReasonLabel(booking.statusReason!),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            if (hasActions) ...[
              AppSpacing.verticalMd,
              const Divider(height: 1),
              AppSpacing.verticalSm,
              Row(
                children: [
                  if (onComplete != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isActionInProgress ? null : onComplete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: const BorderSide(color: AppColors.success),
                        ),
                        child: Text(
                          l10n.barberCompleteAction,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (onComplete != null && onReschedule != null)
                    AppSpacing.horizontalXs,
                  if (onReschedule != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isActionInProgress ? null : onReschedule,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: const BorderSide(color: AppColors.secondary),
                        ),
                        child: Text(
                          l10n.barberRescheduleAction,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (onReschedule != null && onCancel != null)
                    AppSpacing.horizontalXs,
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isActionInProgress ? null : onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: Text(
                          l10n.barberCancelAction,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
