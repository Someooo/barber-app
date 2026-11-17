import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/usecases/get_available_time_slots_usecase.dart';
import '../bloc/barber_dashboard_bloc.dart';
import '../bloc/barber_dashboard_event.dart';
import '../bloc/barber_dashboard_state.dart';
import 'barber_appointment_card.dart';
import 'barber_availability_kpi_card.dart';
import 'barber_cancel_booking_dialog.dart';
import 'barber_schedule_filter_tab.dart';
import 'reschedule_booking_dialog.dart';

class BarberScheduleSection extends StatelessWidget {
  const BarberScheduleSection({
    super.key,
    required this.barberId,
    this.getAvailableTimeSlotsUseCase,
  });

  final String barberId;
  final GetAvailableTimeSlotsUseCase? getAvailableTimeSlotsUseCase;

  Future<void> _onReschedule(
    BuildContext context,
    BookingEntity booking,
  ) async {
    final useCase =
        getAvailableTimeSlotsUseCase ?? sl<GetAvailableTimeSlotsUseCase>();
    final result = await showDialog<RescheduleResult>(
      context: context,
      builder: (_) => RescheduleBookingDialog(
        booking: booking,
        getAvailableTimeSlotsUseCase: useCase,
      ),
    );
    if (result != null && context.mounted) {
      context.read<BarberDashboardBloc>().add(BarberBookingRescheduled(
            bookingId: booking.id,
            barberId: barberId,
            newDateTime: result.newDateTime,
            reason: result.reason,
          ));
    }
  }

  Future<void> _onCancel(BuildContext context, BookingEntity booking) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const BarberCancelBookingDialog(),
    );
    if (reason != null && reason.isNotEmpty && context.mounted) {
      context.read<BarberDashboardBloc>().add(BarberBookingCancelled(
            bookingId: booking.id,
            barberId: barberId,
            reason: reason,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<BarberDashboardBloc, BarberDashboardState>(
          buildWhen: (prev, curr) {
            if (prev is BarberDashboardLoaded &&
                curr is BarberDashboardLoaded) {
              return prev.barberProfile.isAvailableToday !=
                      curr.barberProfile.isAvailableToday ||
                  prev.todayBookings.length != curr.todayBookings.length ||
                  prev.todayExpectedRevenue != curr.todayExpectedRevenue;
            }
            return prev.runtimeType != curr.runtimeType;
          },
          builder: (context, state) {
            if (state is! BarberDashboardLoaded) {
              return const LuxuryShimmerCard(height: 140.0);
            }
            return BarberAvailabilityKpiCard(
              isAvailableToday: state.barberProfile.isAvailableToday,
              todayAppointmentsCount: state.todayBookings.length,
              todayExpectedRevenue: state.todayExpectedRevenue,
              onAvailabilityChanged: (value) {
                context.read<BarberDashboardBloc>().add(
                      BarberAvailabilityToggled(
                        barberId: barberId,
                        isAvailableToday: value,
                      ),
                    );
              },
            );
          },
        ),
        AppSpacing.verticalMd,
        BlocBuilder<BarberDashboardBloc, BarberDashboardState>(
          buildWhen: (prev, curr) {
            if (prev is BarberDashboardLoaded &&
                curr is BarberDashboardLoaded) {
              return prev.selectedFilterIndex != curr.selectedFilterIndex;
            }
            return prev.runtimeType != curr.runtimeType;
          },
          builder: (context, state) {
            final index =
                state is BarberDashboardLoaded ? state.selectedFilterIndex : 0;
            return BarberScheduleFilterTab(
              selectedIndex: index,
              onChanged: (newIndex) {
                context
                    .read<BarberDashboardBloc>()
                    .add(BarberScheduleFilterChanged(newIndex));
              },
            );
          },
        ),
        AppSpacing.verticalMd,
        BlocBuilder<BarberDashboardBloc, BarberDashboardState>(
          buildWhen: (prev, curr) {
            if (prev is BarberDashboardLoaded &&
                curr is BarberDashboardLoaded) {
              return prev.visibleScheduleBookings !=
                      curr.visibleScheduleBookings ||
                  prev.actionInProgressBookingId !=
                      curr.actionInProgressBookingId;
            }
            return prev.runtimeType != curr.runtimeType;
          },
          builder: (context, state) {
            if (state.isLoading || state.isInitial) {
              return const Column(
                children: [
                  LuxuryShimmerCard(height: 120.0),
                  AppSpacing.verticalMd,
                  LuxuryShimmerCard(height: 120.0),
                ],
              );
            }
            if (state is BarberDashboardFailure) {
              return Padding(
                padding: AppSpacing.cardPadding,
                child: Text(
                  state.failure.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              );
            }
            final loaded = state as BarberDashboardLoaded;
            final bookings = loaded.visibleScheduleBookings;
            if (bookings.isEmpty) {
              return _EmptyScheduleState(
                isToday: loaded.selectedFilterIndex == 0,
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => AppSpacing.verticalMd,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BarberAppointmentCard(
                  booking: booking,
                  isActionInProgress:
                      loaded.actionInProgressBookingId == booking.id,
                  onComplete: () => context.read<BarberDashboardBloc>().add(
                        BarberBookingCompleted(
                          bookingId: booking.id,
                          barberId: barberId,
                        ),
                      ),
                  onReschedule: () => _onReschedule(context, booking),
                  onCancel: () => _onCancel(context, booking),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _EmptyScheduleState extends StatelessWidget {
  const _EmptyScheduleState({required this.isToday});

  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;

    return RepaintBoundary(
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(
            color: context.borderColor,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.event_available_outlined,
              size: 40.0,
              color: AppColors.secondary,
            ),
            AppSpacing.verticalSm,
            Text(
              isToday
                  ? l10n.barberNoTodayBookingsTitle
                  : l10n.barberNoUpcomingBookingsTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              isToday
                  ? l10n.barberNoTodayBookingsSubtitle
                  : l10n.barberNoUpcomingBookingsSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
