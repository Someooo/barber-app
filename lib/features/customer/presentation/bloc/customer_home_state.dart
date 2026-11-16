import 'package:equatable/equatable.dart';

import '../../domain/entities/barber_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/service_entity.dart';

abstract class CustomerHomeState extends Equatable {
  const CustomerHomeState();

  bool get isInitial => this is CustomerHomeInitial;
  bool get isLoading => this is CustomerHomeLoading;
  bool get isLoaded => this is CustomerHomeLoaded;
  bool get isFailure => this is CustomerHomeFailure;

  bool get hasActiveBooking {
    final self = this;
    return self is CustomerHomeLoaded && self.activeBooking != null;
  }

  BookingEntity? get activeBookingOrNull {
    final self = this;
    return self is CustomerHomeLoaded ? self.activeBooking : null;
  }

  List<ServiceEntity> get servicesOrEmpty {
    final self = this;
    return self is CustomerHomeLoaded ? self.services : const [];
  }

  List<BarberEntity> get barbersOrEmpty {
    final self = this;
    return self is CustomerHomeLoaded ? self.barbers : const [];
  }

  @override
  List<Object?> get props => [];
}

class CustomerHomeInitial extends CustomerHomeState {
  const CustomerHomeInitial();
}

class CustomerHomeLoading extends CustomerHomeState {
  const CustomerHomeLoading();
}

class CustomerHomeLoaded extends CustomerHomeState {
  const CustomerHomeLoaded({
    required this.services,
    required this.barbers,
    this.activeBooking,
  });

  final List<ServiceEntity> services;
  final List<BarberEntity> barbers;
  final BookingEntity? activeBooking;

  @override
  List<Object?> get props => [services, barbers, activeBooking];
}

class CustomerHomeFailure extends CustomerHomeState {
  const CustomerHomeFailure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}
