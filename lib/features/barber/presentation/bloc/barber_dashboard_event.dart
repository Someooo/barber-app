import 'package:equatable/equatable.dart';

abstract class BarberDashboardEvent extends Equatable {
  const BarberDashboardEvent();

  @override
  List<Object?> get props => [];
}

class BarberDashboardLoadRequested extends BarberDashboardEvent {
  const BarberDashboardLoadRequested({
    required this.barberId,
    required this.barberName,
  });

  final String barberId;
  final String barberName;

  @override
  List<Object?> get props => [barberId, barberName];
}

class BarberAvailabilityToggled extends BarberDashboardEvent {
  const BarberAvailabilityToggled({
    required this.barberId,
    required this.isAvailableToday,
  });

  final String barberId;
  final bool isAvailableToday;

  @override
  List<Object?> get props => [barberId, isAvailableToday];
}

class BarberScheduleFilterChanged extends BarberDashboardEvent {
  const BarberScheduleFilterChanged(this.filterIndex);

  final int filterIndex;

  @override
  List<Object?> get props => [filterIndex];
}

class BarberBookingCompleted extends BarberDashboardEvent {
  const BarberBookingCompleted({
    required this.bookingId,
    required this.barberId,
  });

  final String bookingId;
  final String barberId;

  @override
  List<Object?> get props => [bookingId, barberId];
}

class BarberBookingRescheduled extends BarberDashboardEvent {
  const BarberBookingRescheduled({
    required this.bookingId,
    required this.barberId,
    required this.newDateTime,
    required this.reason,
  });

  final String bookingId;
  final String barberId;
  final DateTime newDateTime;
  final String reason;

  @override
  List<Object?> get props => [bookingId, barberId, newDateTime, reason];
}

class BarberBookingCancelled extends BarberDashboardEvent {
  const BarberBookingCancelled({
    required this.bookingId,
    required this.barberId,
    required this.reason,
  });

  final String bookingId;
  final String barberId;
  final String reason;

  @override
  List<Object?> get props => [bookingId, barberId, reason];
}
