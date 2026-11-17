import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class CustomerBookingsEvent extends Equatable {
  const CustomerBookingsEvent();

  @override
  List<Object?> get props => [];
}

class CustomerBookingsLoadRequested extends CustomerBookingsEvent {
  const CustomerBookingsLoadRequested(this.customerId);

  final String customerId;

  @override
  List<Object?> get props => [customerId];
}

class CustomerBookingsTabChanged extends CustomerBookingsEvent {
  const CustomerBookingsTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class CustomerBookingCancelRequested extends CustomerBookingsEvent {
  const CustomerBookingCancelRequested({
    required this.bookingId,
    required this.customerId,
    this.reason,
  });

  final String bookingId;
  final String customerId;
  final String? reason;

  @override
  List<Object?> get props => [bookingId, customerId, reason];
}
