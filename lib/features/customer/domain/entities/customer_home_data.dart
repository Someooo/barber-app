import 'package:equatable/equatable.dart';

import 'barber_entity.dart';
import 'booking_entity.dart';
import 'service_entity.dart';

class CustomerHomeData extends Equatable {
  const CustomerHomeData({
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
