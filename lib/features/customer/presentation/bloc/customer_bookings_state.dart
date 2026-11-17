import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/booking_entity.dart';

@immutable
abstract class CustomerBookingsState extends Equatable {
  const CustomerBookingsState();

  bool get isInitial => this is CustomerBookingsInitial;
  bool get isLoading => this is CustomerBookingsLoading;
  bool get isLoaded => this is CustomerBookingsLoaded;
  bool get isFailure => this is CustomerBookingsFailure;

  List<BookingEntity> get upcomingOrEmpty => this is CustomerBookingsLoaded
      ? (this as CustomerBookingsLoaded).upcomingBookings
      : const [];
  List<BookingEntity> get historyOrEmpty => this is CustomerBookingsLoaded
      ? (this as CustomerBookingsLoaded).historyBookings
      : const [];
  List<BookingEntity> get currentTabBookings => this is CustomerBookingsLoaded
      ? (this as CustomerBookingsLoaded).currentBookings
      : const [];
  int get currentTabIndex => this is CustomerBookingsLoaded
      ? (this as CustomerBookingsLoaded).selectedTabIndex
      : 0;
  bool isCancelling(String bookingId) =>
      this is CustomerBookingsLoaded &&
      (this as CustomerBookingsLoaded).cancellingBookingId == bookingId;

  @override
  List<Object?> get props => [];
}

class CustomerBookingsInitial extends CustomerBookingsState {
  const CustomerBookingsInitial();
}

class CustomerBookingsLoading extends CustomerBookingsState {
  const CustomerBookingsLoading();
}

class CustomerBookingsLoaded extends CustomerBookingsState {
  const CustomerBookingsLoaded({
    required this.upcomingBookings,
    required this.historyBookings,
    this.selectedTabIndex = 0,
    this.cancellingBookingId,
  });

  final List<BookingEntity> upcomingBookings;
  final List<BookingEntity> historyBookings;
  final int selectedTabIndex;
  final String? cancellingBookingId;

  List<BookingEntity> get currentBookings =>
      selectedTabIndex == 0 ? upcomingBookings : historyBookings;

  CustomerBookingsLoaded copyWith({
    List<BookingEntity>? upcomingBookings,
    List<BookingEntity>? historyBookings,
    int? selectedTabIndex,
    String? Function()? cancellingBookingId,
  }) {
    return CustomerBookingsLoaded(
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      cancellingBookingId: cancellingBookingId != null
          ? cancellingBookingId()
          : this.cancellingBookingId,
    );
  }

  @override
  List<Object?> get props => [
        upcomingBookings,
        historyBookings,
        selectedTabIndex,
        cancellingBookingId,
      ];
}

class CustomerBookingsFailure extends CustomerBookingsState {
  const CustomerBookingsFailure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}
