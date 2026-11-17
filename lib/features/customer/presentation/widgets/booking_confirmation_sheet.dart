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

class BookingConfirmationSheet extends StatelessWidget {
  const BookingConfirmationSheet({
    super.key,
    required this.booking,
    required this.onDone,
  });

  final BookingEntity booking;
  final VoidCallback onDone;

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    try {
      final formatter =
          DateFormat('EEEE, d MMMM • h:mm a', context.languageCode);
      return formatter.format(dateTime);
    } catch (_) {
      return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isArabic = context.languageCode == 'AR';
    final servicesText =
        booking.services.map((s) => isArabic ? s.nameAr : s.nameEn).join(', ');

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.lg,
          end: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: AppRadius.controlBorder,
              ),
            ),
            AppSpacing.verticalLg,
            Container(
              width: AppSizes.avatarLg,
              height: AppSizes.avatarLg,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  size: AppSizes.iconLg,
                  color: AppColors.secondary,
                ),
              ),
            ),
            AppSpacing.verticalMd,
            LuxuryBadge.status(
              label: context.l10n.bookingStatusConfirmed,
              type: LuxuryStatusType.confirmed,
            ),
            AppSpacing.verticalSm,
            Text(
              context.l10n.bookingConfirmationSuccess,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              context.l10n.bookingConfirmationSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalLg,
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: context.borderColor.withValues(alpha: 0.25),
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
                      LuxuryAvatar(
                        fallbackLabel: booking.barberName,
                        size: AppSizes.avatarSm,
                      ),
                      AppSpacing.horizontalMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.barberName,
                              style: AppTextStyles.titleSmall.copyWith(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          servicesText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSm,
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
                ],
              ),
            ),
            AppSpacing.verticalXl,
            RepaintBoundary(
              child: LuxuryPrimaryButton(
                text: context.l10n.doneButton,
                onPressed: onDone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
