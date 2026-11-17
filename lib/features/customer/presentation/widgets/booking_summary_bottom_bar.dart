import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import '../bloc/booking_flow_bloc.dart';
import '../bloc/booking_flow_state.dart';

class BookingSummaryBottomBar extends StatelessWidget {
  const BookingSummaryBottomBar({
    super.key,
    required this.onConfirmPressed,
  });

  final VoidCallback onConfirmPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.md,
          end: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.cardSurface,
          border: Border(
            top: BorderSide(
              color: context.borderColor,
              width: AppSizes.hairline,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: BlocBuilder<BookingFlowBloc, BookingFlowState>(
          buildWhen: (prev, curr) =>
              prev.totalPrice != curr.totalPrice ||
              prev.totalDurationMinutes != curr.totalDurationMinutes ||
              prev.canSubmit != curr.canSubmit ||
              prev.isSubmitting != curr.isSubmitting,
          builder: (context, state) {
            final formattedPrice =
                context.l10n.priceDisplay(state.totalPrice.toStringAsFixed(0));
            final formattedDuration =
                context.l10n.durationMinutesLabel(state.totalDurationMinutes);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.totalLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.verticalXs,
                        Text(
                          formattedPrice,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (state.totalDurationMinutes > 0)
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: context.borderColor.withValues(alpha: 0.5),
                          borderRadius: AppRadius.controlBorder,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: AppSizes.iconSm,
                              color: scheme.onSurfaceVariant,
                            ),
                            AppSpacing.horizontalXs,
                            Text(
                              formattedDuration,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                AppSpacing.verticalMd,
                RepaintBoundary(
                  child: LuxuryPrimaryButton(
                    text: context.l10n.confirmInstantBookingCta,
                    isLoading: state.isSubmitting,
                    onPressed: state.canSubmit ? onConfirmPressed : null,
                    prefixIcon: const Icon(
                      Icons.check_circle_outline,
                      size: AppSizes.iconSm,
                      color: AppColors.neutral,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
