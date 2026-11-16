import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

import '../datasources/customer_remote_data_source.dart';
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
}
