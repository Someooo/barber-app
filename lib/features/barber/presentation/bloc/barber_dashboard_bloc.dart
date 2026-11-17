import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/barber/domain/usecases/barber_cancel_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/complete_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/ensure_barber_profile_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/get_barber_bookings_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/reschedule_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/update_barber_availability_usecase.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'barber_dashboard_event.dart';
import 'barber_dashboard_state.dart';

class BarberDashboardBloc
    extends Bloc<BarberDashboardEvent, BarberDashboardState> {
  BarberDashboardBloc({
    required EnsureBarberProfileUseCase ensureBarberProfileUseCase,
    required GetBarberBookingsUseCase getBarberBookingsUseCase,
    required UpdateBarberAvailabilityUseCase updateBarberAvailabilityUseCase,
    required CompleteBookingUseCase completeBookingUseCase,
    required RescheduleBookingUseCase rescheduleBookingUseCase,
    required BarberCancelBookingUseCase barberCancelBookingUseCase,
    BarberDashboardState? initialState,
  })  : _ensureBarberProfileUseCase = ensureBarberProfileUseCase,
        _getBarberBookingsUseCase = getBarberBookingsUseCase,
        _updateBarberAvailabilityUseCase = updateBarberAvailabilityUseCase,
        _completeBookingUseCase = completeBookingUseCase,
        _rescheduleBookingUseCase = rescheduleBookingUseCase,
        _barberCancelBookingUseCase = barberCancelBookingUseCase,
        super(initialState ?? const BarberDashboardInitial()) {
    on<BarberDashboardLoadRequested>(_onLoadRequested);
    on<BarberAvailabilityToggled>(_onAvailabilityToggled);
    on<BarberScheduleFilterChanged>(_onFilterChanged);
    on<BarberBookingCompleted>(_onBookingCompleted);
    on<BarberBookingRescheduled>(_onBookingRescheduled);
    on<BarberBookingCancelled>(_onBookingCancelled);
  }

  final EnsureBarberProfileUseCase _ensureBarberProfileUseCase;
  final GetBarberBookingsUseCase _getBarberBookingsUseCase;
  final UpdateBarberAvailabilityUseCase _updateBarberAvailabilityUseCase;
  final CompleteBookingUseCase _completeBookingUseCase;
  final RescheduleBookingUseCase _rescheduleBookingUseCase;
  final BarberCancelBookingUseCase _barberCancelBookingUseCase;

  Future<void> _onLoadRequested(
    BarberDashboardLoadRequested event,
    Emitter<BarberDashboardState> emit,
  ) async {
    final previousFilter = state is BarberDashboardLoaded
        ? (state as BarberDashboardLoaded).selectedFilterIndex
        : 0;
    if (state is! BarberDashboardLoaded) {
      emit(const BarberDashboardLoading());
    }

    try {
      final profile = await _ensureBarberProfileUseCase(
        barberId: event.barberId,
        name: event.barberName,
      );
      final bookings = await _getBarberBookingsUseCase(event.barberId);
      emit(_buildLoadedState(
        profile: profile,
        bookings: bookings,
        selectedFilterIndex: previousFilter,
      ));
    } on Failure catch (failure) {
      emit(BarberDashboardFailure(failure));
    } catch (e) {
      emit(BarberDashboardFailure(ServerFailure(message: e.toString())));
    }
  }

  Future<void> _onAvailabilityToggled(
    BarberAvailabilityToggled event,
    Emitter<BarberDashboardState> emit,
  ) async {
    final current = state;
    if (current is! BarberDashboardLoaded) return;

    final updatedProfile = BarberEntity(
      id: current.barberProfile.id,
      name: current.barberProfile.name,
      specialtyEn: current.barberProfile.specialtyEn,
      specialtyAr: current.barberProfile.specialtyAr,
      rating: current.barberProfile.rating,
      experienceYears: current.barberProfile.experienceYears,
      isAvailableToday: event.isAvailableToday,
      imageUrl: current.barberProfile.imageUrl,
    );
    emit(current.copyWith(
      barberProfile: updatedProfile,
      clearActionSuccess: true,
      clearActionError: true,
    ));

    try {
      await _updateBarberAvailabilityUseCase(
        barberId: event.barberId,
        isAvailableToday: event.isAvailableToday,
      );
    } on Failure catch (failure) {
      emit(current.copyWith(actionError: failure, clearActionSuccess: true));
    } catch (e) {
      emit(current.copyWith(
        actionError: ServerFailure(message: e.toString()),
        clearActionSuccess: true,
      ));
    }
  }

  void _onFilterChanged(
    BarberScheduleFilterChanged event,
    Emitter<BarberDashboardState> emit,
  ) {
    final current = state;
    if (current is BarberDashboardLoaded) {
      emit(current.copyWith(
        selectedFilterIndex: event.filterIndex,
        clearActionSuccess: true,
        clearActionError: true,
      ));
    }
  }

  Future<void> _onBookingCompleted(
    BarberBookingCompleted event,
    Emitter<BarberDashboardState> emit,
  ) async {
    await _runBookingAction(
      emit: emit,
      bookingId: event.bookingId,
      barberId: event.barberId,
      successCode: 'completed',
      action: () => _completeBookingUseCase(event.bookingId),
    );
  }

  Future<void> _onBookingRescheduled(
    BarberBookingRescheduled event,
    Emitter<BarberDashboardState> emit,
  ) async {
    await _runBookingAction(
      emit: emit,
      bookingId: event.bookingId,
      barberId: event.barberId,
      successCode: 'rescheduled',
      action: () => _rescheduleBookingUseCase(
        bookingId: event.bookingId,
        newDateTime: event.newDateTime,
        reason: event.reason,
      ),
    );
  }

  Future<void> _onBookingCancelled(
    BarberBookingCancelled event,
    Emitter<BarberDashboardState> emit,
  ) async {
    await _runBookingAction(
      emit: emit,
      bookingId: event.bookingId,
      barberId: event.barberId,
      successCode: 'cancelled',
      action: () => _barberCancelBookingUseCase(
        bookingId: event.bookingId,
        reason: event.reason,
      ),
    );
  }

  Future<void> _runBookingAction({
    required Emitter<BarberDashboardState> emit,
    required String bookingId,
    required String barberId,
    required String successCode,
    required Future<void> Function() action,
  }) async {
    final current = state;
    if (current is! BarberDashboardLoaded) return;

    emit(current.copyWith(
      actionInProgressBookingId: bookingId,
      clearActionSuccess: true,
      clearActionError: true,
    ));

    try {
      await action();
      final bookings = await _getBarberBookingsUseCase(barberId);
      emit(_buildLoadedState(
        profile: current.barberProfile,
        bookings: bookings,
        selectedFilterIndex: current.selectedFilterIndex,
        lastActionSuccessCode: successCode,
      ));
    } on Failure catch (failure) {
      emit(current.copyWith(
        clearActionInProgress: true,
        clearActionSuccess: true,
        actionError: failure,
      ));
    } catch (e) {
      emit(current.copyWith(
        clearActionInProgress: true,
        clearActionSuccess: true,
        actionError: ServerFailure(message: e.toString()),
      ));
    }
  }

  BarberDashboardLoaded _buildLoadedState({
    required BarberEntity profile,
    required List<BookingEntity> bookings,
    required int selectedFilterIndex,
    String? lastActionSuccessCode,
  }) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final upcoming = bookings
        .where((b) =>
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.rescheduled)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final today = upcoming
        .where((b) =>
            !b.dateTime.isBefore(todayStart) &&
            b.dateTime.isBefore(tomorrowStart))
        .toList();

    final history = bookings
        .where((b) =>
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final todayRevenue = today.fold<double>(
      0.0,
      (sum, b) => sum + b.totalPrice,
    );

    return BarberDashboardLoaded(
      barberProfile: profile,
      todayBookings: today,
      upcomingBookings: upcoming,
      historyBookings: history,
      selectedFilterIndex: selectedFilterIndex,
      todayExpectedRevenue: todayRevenue,
      lastActionSuccessCode: lastActionSuccessCode,
    );
  }
}
