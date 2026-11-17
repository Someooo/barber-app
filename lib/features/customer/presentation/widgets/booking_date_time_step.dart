import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import '../bloc/booking_flow_bloc.dart';
import '../bloc/booking_flow_event.dart';
import '../bloc/booking_flow_state.dart';

class BookingDateTimeStep extends StatelessWidget {
  const BookingDateTimeStep({super.key});

  List<DateTime> _generateDates(DateTime baseDate) {
    final start = DateTime(baseDate.year, baseDate.month, baseDate.day);
    return List.generate(14, (i) => start.add(Duration(days: i)));
  }

  String _formatSlotTime(BuildContext context, DateTime slot) {
    try {
      final formatter = DateFormat('h:mm a', context.languageCode);
      return formatter.format(slot);
    } catch (_) {
      return '${slot.hour}:${slot.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final locale = context.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.selectDateTimeTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              AppSpacing.verticalXs,
              Text(
                context.l10n.selectDateTimeSubtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalMd,
        BlocBuilder<BookingFlowBloc, BookingFlowState>(
          buildWhen: (prev, curr) => prev.selectedDate != curr.selectedDate,
          builder: (context, state) {
            final dates = _generateDates(DateTime.now());

            return SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                ),
                itemCount: dates.length,
                separatorBuilder: (_, __) => AppSpacing.horizontalSm,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = state.isDateSelected(date);
                  final dayName = DateFormat('EEE', locale).format(date);
                  final dayNumber = DateFormat('d', locale).format(date);
                  final monthName = DateFormat('MMM', locale).format(date);

                  return RepaintBoundary(
                    child: Material(
                      color: isSelected
                          ? AppColors.secondary
                          : context.cardSurface,
                      borderRadius: AppRadius.controlBorder,
                      child: InkWell(
                        onTap: () {
                          context
                              .read<BookingFlowBloc>()
                              .add(BookingDateSelected(date));
                        },
                        borderRadius: AppRadius.controlBorder,
                        child: Container(
                          width: 68,
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: AppSpacing.xs,
                            horizontal: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.controlBorder,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary
                                  : context.borderColor,
                              width: isSelected ? 1.5 : AppSizes.hairline,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dayName.toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.neutral
                                      : scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpacing.verticalXs,
                              Text(
                                dayNumber,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isSelected
                                      ? AppColors.neutral
                                      : scheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                monthName,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.neutral.withValues(alpha: 0.8)
                                      : scheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        AppSpacing.verticalLg,
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: BlocBuilder<BookingFlowBloc, BookingFlowState>(
            buildWhen: (prev, curr) =>
                prev.selectedDate != curr.selectedDate ||
                prev.availableSlots != curr.availableSlots ||
                prev.isLoadingSlots != curr.isLoadingSlots ||
                prev.selectedSlot != curr.selectedSlot ||
                prev.selectedBarber != curr.selectedBarber,
            builder: (context, state) {
              if (state.isLoadingSlots) {
                return const LuxuryShimmerCard(height: 90.0);
              }

              if (state.selectedBarber == null) {
                return Container(
                  width: double.infinity,
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
                      const Icon(
                        Icons.person_pin_outlined,
                        size: AppSizes.iconSm,
                        color: AppColors.secondary,
                      ),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Text(
                          context.l10n.selectBarberPrompt,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state.availableSlots.isEmpty) {
                return Container(
                  width: double.infinity,
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
                      const Icon(
                        Icons.event_busy_outlined,
                        size: AppSizes.iconSm,
                        color: AppColors.secondary,
                      ),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Text(
                          context.l10n.noSlotsAvailable,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: state.availableSlots.map((slot) {
                  final isSelected = state.isSlotSelected(slot);
                  final formattedTime = _formatSlotTime(context, slot);

                  return RepaintBoundary(
                    child: Material(
                      color: isSelected
                          ? AppColors.secondary
                          : context.cardSurface,
                      borderRadius: AppRadius.controlBorder,
                      child: InkWell(
                        onTap: () {
                          context
                              .read<BookingFlowBloc>()
                              .add(BookingTimeSlotSelected(slot));
                        },
                        borderRadius: AppRadius.controlBorder,
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.controlBorder,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary
                                  : context.borderColor,
                              width: isSelected ? 1.5 : AppSizes.hairline,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: AppSizes.iconSm,
                                color: isSelected
                                    ? AppColors.neutral
                                    : AppColors.secondary,
                              ),
                              AppSpacing.horizontalXs,
                              Text(
                                formattedTime,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: isSelected
                                      ? AppColors.neutral
                                      : scheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
