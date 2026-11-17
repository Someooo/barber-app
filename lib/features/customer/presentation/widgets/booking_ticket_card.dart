import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';

class BookingTicketCard extends StatelessWidget {
  const BookingTicketCard({
    super.key,
    required this.booking,
    this.isCancelling = false,
    this.onCancel,
  });

  final BookingEntity booking;
  final bool isCancelling;
  final VoidCallback? onCancel;

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    try {
      final formatter =
          DateFormat('EEEE, d MMMM • h:mm a', context.languageCode);
      return formatter.format(dateTime);
    } catch (_) {
      return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  (String, LuxuryStatusType) _resolveStatus(BuildContext context) {
    return switch (booking.status) {
      BookingStatus.confirmed => (
          context.l10n.bookingStatusConfirmed,
          LuxuryStatusType.confirmed
        ),
      BookingStatus.rescheduled => (
          context.l10n.bookingStatusRescheduled,
          LuxuryStatusType.inProgress
        ),
      BookingStatus.completed => (
          context.l10n.bookingStatusCompleted,
          LuxuryStatusType.completed
        ),
      BookingStatus.cancelled => (
          context.l10n.bookingStatusCancelled,
          LuxuryStatusType.cancelled
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isArabic = context.languageCode == 'AR';
    final (statusLabel, statusType) = _resolveStatus(context);

    final servicesText =
        booking.services.map((s) => isArabic ? s.nameAr : s.nameEn).join(', ');

    final isUpcoming = booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.rescheduled;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(
            color: isUpcoming
                ? AppColors.secondary.withValues(alpha: 0.35)
                : context.borderColor,
            width: isUpcoming ? 1.5 : AppSizes.hairline,
          ),
        ),
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isUpcoming
                          ? Icons.calendar_today_outlined
                          : Icons.history_outlined,
                      size: AppSizes.iconSm,
                      color: AppColors.secondary,
                    ),
                    AppSpacing.horizontalXs,
                    Text(
                      _formatDateTime(context, booking.dateTime),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
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
                        servicesText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        booking.totalDurationMinutes,
                      ),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  context.l10n.priceDisplay(
                    booking.totalPrice.toStringAsFixed(0),
                  ),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (booking.statusReason != null &&
                booking.statusReason!.isNotEmpty) ...[
              AppSpacing.verticalSm,
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.controlBorder,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    width: AppSizes.hairline,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: AppSizes.iconSm,
                      color: AppColors.secondary,
                    ),
                    AppSpacing.horizontalXs,
                    Expanded(
                      child: Text(
                        booking.status == BookingStatus.rescheduled
                            ? context.l10n.rescheduledReasonLabel(
                                booking.statusReason!,
                              )
                            : context.l10n.cancellationReasonLabel(
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
            if (isUpcoming && onCancel != null) ...[
              AppSpacing.verticalMd,
              const Divider(height: 1),
              AppSpacing.verticalMd,
              RepaintBoundary(
                child: LuxuryOutlinedButton(
                  text: context.l10n.cancelBookingButton,
                  borderColor: AppColors.error.withValues(alpha: 0.5),
                  textColor: AppColors.error,
                  isFullWidth: true,
                  onPressed: isCancelling ? null : onCancel,
                  prefixIcon: isCancelling
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error,
                          ),
                        )
                      : const Icon(
                          Icons.cancel_outlined,
                          size: AppSizes.iconSm,
                          color: AppColors.error,
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
