import 'package:equatable/equatable.dart';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';

abstract class BarberDashboardState extends Equatable {
  const BarberDashboardState();

  bool get isInitial => this is BarberDashboardInitial;
  bool get isLoading => this is BarberDashboardLoading;
  bool get isLoaded => this is BarberDashboardLoaded;

  @override
  List<Object?> get props => [];
}

class BarberDashboardInitial extends BarberDashboardState {
  const BarberDashboardInitial();
}

class BarberDashboardLoading extends BarberDashboardState {
  const BarberDashboardLoading();
}

class BarberDashboardLoaded extends BarberDashboardState {
  const BarberDashboardLoaded({
    required this.barberProfile,
    required this.todayBookings,
    required this.upcomingBookings,
    required this.historyBookings,
    required this.selectedFilterIndex,
    required this.todayExpectedRevenue,
    this.actionInProgressBookingId,
    this.lastActionSuccessCode,
    this.actionError,
  });

  final BarberEntity barberProfile;
  final List<BookingEntity> todayBookings;
  final List<BookingEntity> upcomingBookings;
  final List<BookingEntity> historyBookings;
  final int selectedFilterIndex;
  final double todayExpectedRevenue;
  final String? actionInProgressBookingId;
  final String? lastActionSuccessCode;
  final Failure? actionError;

  List<BookingEntity> get visibleScheduleBookings =>
      selectedFilterIndex == 0 ? todayBookings : upcomingBookings;

  BarberDashboardLoaded copyWith({
    BarberEntity? barberProfile,
    List<BookingEntity>? todayBookings,
    List<BookingEntity>? upcomingBookings,
    List<BookingEntity>? historyBookings,
    int? selectedFilterIndex,
    double? todayExpectedRevenue,
    String? actionInProgressBookingId,
    bool clearActionInProgress = false,
    String? lastActionSuccessCode,
    bool clearActionSuccess = false,
    Failure? actionError,
    bool clearActionError = false,
  }) {
    return BarberDashboardLoaded(
      barberProfile: barberProfile ?? this.barberProfile,
      todayBookings: todayBookings ?? this.todayBookings,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      todayExpectedRevenue: todayExpectedRevenue ?? this.todayExpectedRevenue,
      actionInProgressBookingId: clearActionInProgress
          ? null
          : (actionInProgressBookingId ?? this.actionInProgressBookingId),
      lastActionSuccessCode: clearActionSuccess
          ? null
          : (lastActionSuccessCode ?? this.lastActionSuccessCode),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        barberProfile,
        todayBookings,
        upcomingBookings,
        historyBookings,
        selectedFilterIndex,
        todayExpectedRevenue,
        actionInProgressBookingId,
        lastActionSuccessCode,
        actionError,
      ];
}

class BarberDashboardFailure extends BarberDashboardState {
  const BarberDashboardFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
