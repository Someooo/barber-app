import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

import '../datasources/customer_remote_data_source.dart';
import '../models/barber_model.dart';
import '../models/service_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl({
    required CustomerRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CustomerRemoteDataSource _remoteDataSource;

  @override
  Future<List<ServiceEntity>> getServices() async {
    try {
      return await _remoteDataSource.getServices();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<BarberEntity>> getBarbers() async {
    try {
      return await _remoteDataSource.getBarbers();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<BookingEntity>> getCustomerBookings(String customerId) async {
    try {
      return await _remoteDataSource.getCustomerBookings(customerId);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    try {
      return await _remoteDataSource.getAvailableTimeSlots(
        barberId: barberId,
        date: date,
        durationMinutes: durationMinutes,
      );
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<BookingEntity> createInstantBooking({
    required String customerId,
    required String customerName,
    required String barberId,
    required String barberName,
    required List<ServiceEntity> services,
    required DateTime dateTime,
    required double totalPrice,
    required int totalDurationMinutes,
    String? notes,
  }) async {
    try {
      final serviceModels = services
          .map((s) => s is ServiceModel ? s : ServiceModel.fromEntity(s))
          .toList();

      return await _remoteDataSource.createInstantBooking(
        customerId: customerId,
        customerName: customerName,
        barberId: barberId,
        barberName: barberName,
        services: serviceModels,
        dateTime: dateTime,
        totalPrice: totalPrice,
        totalDurationMinutes: totalDurationMinutes,
        notes: notes,
      );
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      await _remoteDataSource.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<BarberEntity> ensureBarberProfile({
    required String barberId,
    required String name,
  }) async {
    try {
      return await _remoteDataSource.ensureBarberProfile(
        barberId: barberId,
        name: name,
      );
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<BookingEntity>> getBarberBookings(String barberId) async {
    try {
      return await _remoteDataSource.getBarberBookings(barberId);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> updateBarberAvailability({
    required String barberId,
    required bool isAvailableToday,
  }) async {
    try {
      await _remoteDataSource.updateBarberAvailability(
        barberId: barberId,
        isAvailableToday: isAvailableToday,
      );
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> completeBooking(String bookingId) async {
    try {
      await _remoteDataSource.completeBooking(bookingId);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDateTime,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.rescheduleBooking(
        bookingId: bookingId,
        newDateTime: newDateTime,
        reason: reason,
      );
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<ServiceEntity> addService(ServiceEntity service) async {
    try {
      final model =
          service is ServiceModel ? service : ServiceModel.fromEntity(service);
      return await _remoteDataSource.addService(model);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      await _remoteDataSource.deleteService(serviceId);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<BarberEntity> addBarber(BarberEntity barber) async {
    try {
      final model =
          barber is BarberModel ? barber : BarberModel.fromEntity(barber);
      return await _remoteDataSource.addBarber(model);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteBarber(String barberId) async {
    try {
      await _remoteDataSource.deleteBarber(barberId);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<BookingEntity>> getAllShopBookings() async {
    try {
      return await _remoteDataSource.getAllShopBookings();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, code: e.code);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
