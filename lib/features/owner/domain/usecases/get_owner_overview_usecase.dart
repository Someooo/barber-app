import 'package:equatable/equatable.dart';

import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class OwnerOverviewData extends Equatable {
  const OwnerOverviewData({
    required this.services,
    required this.barbers,
    required this.allBookings,
  });

  final List<ServiceEntity> services;
  final List<BarberEntity> barbers;
  final List<BookingEntity> allBookings;

  @override
  List<Object?> get props => [services, barbers, allBookings];
}

class GetOwnerOverviewUseCase {
  const GetOwnerOverviewUseCase(this._repository);

  final CustomerRepository _repository;

  Future<OwnerOverviewData> call() async {
    final results = await Future.wait([
      _repository.getServices(),
      _repository.getBarbers(),
      _repository.getAllShopBookings(),
    ]);
    return OwnerOverviewData(
      services: results[0] as List<ServiceEntity>,
      barbers: results[1] as List<BarberEntity>,
      allBookings: results[2] as List<BookingEntity>,
    );
  }
}
