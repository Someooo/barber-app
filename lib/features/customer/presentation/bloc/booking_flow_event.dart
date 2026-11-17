import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/barber_entity.dart';
import '../../domain/entities/service_entity.dart';

@immutable
abstract class BookingFlowEvent extends Equatable {
  const BookingFlowEvent();

  @override
  List<Object?> get props => [];
}

class BookingFlowInitialized extends BookingFlowEvent {
  const BookingFlowInitialized({
    this.availableServices,
    this.availableBarbers,
    this.preselectedServiceId,
    this.preselectedBarberId,
  });

  final List<ServiceEntity>? availableServices;
  final List<BarberEntity>? availableBarbers;
  final String? preselectedServiceId;
  final String? preselectedBarberId;

  @override
  List<Object?> get props => [
        availableServices,
        availableBarbers,
        preselectedServiceId,
        preselectedBarberId,
      ];
}

class BookingServiceToggled extends BookingFlowEvent {
  const BookingServiceToggled(this.serviceId);

  final String serviceId;

  @override
  List<Object?> get props => [serviceId];
}

class BookingBarberSelected extends BookingFlowEvent {
  const BookingBarberSelected(this.barber);

  final BarberEntity barber;

  @override
  List<Object?> get props => [barber];
}

class BookingDateSelected extends BookingFlowEvent {
  const BookingDateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class BookingTimeSlotSelected extends BookingFlowEvent {
  const BookingTimeSlotSelected(this.slot);

  final DateTime slot;

  @override
  List<Object?> get props => [slot];
}

class BookingSubmitted extends BookingFlowEvent {
  const BookingSubmitted({
    required this.customerId,
    required this.customerName,
    this.notes,
  });

  final String customerId;
  final String customerName;
  final String? notes;

  @override
  List<Object?> get props => [customerId, customerName, notes];
}
