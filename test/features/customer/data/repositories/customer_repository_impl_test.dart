import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/data/datasources/customer_remote_data_source.dart';
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/models/barber_model.dart';
import 'package:barber_app/features/customer/data/models/booking_model.dart';
import 'package:barber_app/features/customer/data/models/service_model.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';

class _FakeCustomerRemoteDataSource implements CustomerRemoteDataSource {
  List<ServiceModel> services = [];
  List<BarberModel> barbers = [];
  List<BookingModel> bookings = [];
  List<DateTime> timeSlots = [];
  BookingModel? createdBooking;
  Exception? errorToThrow;

  @override
  Future<List<ServiceModel>> getServices() async {
    if (errorToThrow != null) throw errorToThrow!;
    return services;
  }

  @override
  Future<List<BarberModel>> getBarbers() async {
    if (errorToThrow != null) throw errorToThrow!;
    return barbers;
  }

  @override
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return bookings;
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return timeSlots;
  }

  @override
  Future<BookingModel> createInstantBooking({
    required String customerId,
    required String customerName,
    required String barberId,
    required String barberName,
    required List<ServiceModel> services,
    required DateTime dateTime,
    required double totalPrice,
    required int totalDurationMinutes,
    String? notes,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return createdBooking ??
        BookingModel(
          id: 'booking_new',
          customerId: customerId,
          customerName: customerName,
          barberId: barberId,
          barberName: barberName,
          services: services,
          dateTime: dateTime,
          totalPrice: totalPrice,
          totalDurationMinutes: totalDurationMinutes,
          status: BookingStatus.confirmed,
          notes: notes,
        );
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<BarberModel> ensureBarberProfile({
    required String barberId,
    required String name,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<BookingModel>> getBarberBookings(String barberId) async =>
      const [];

  @override
  Future<void> updateBarberAvailability({
    required String barberId,
    required bool isAvailableToday,
  }) async {}

  @override
  Future<void> completeBooking(String bookingId) async {}

  @override
  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDateTime,
    required String reason,
  }) async {}
}

void main() {
  const tService = ServiceModel(
    id: 's1',
    nameEn: 'Cut',
    nameAr: 'قص',
    descriptionEn: 'Haircut',
    descriptionAr: 'قص شعر',
    price: 30.0,
    durationMinutes: 30,
    iconName: 'content_cut',
  );

  const tBarber = BarberModel(
    id: 'b1',
    name: 'Tariq',
    specialtyEn: 'Master',
    specialtyAr: 'ماستر',
    rating: 4.9,
    experienceYears: 10,
    isAvailableToday: true,
  );

  final tBooking = BookingModel(
    id: 'bk1',
    customerId: 'c1',
    customerName: 'Sami',
    barberId: 'b1',
    barberName: 'Tariq',
    services: const [tService],
    dateTime: DateTime.now().add(const Duration(days: 1)),
    totalPrice: 30.0,
    totalDurationMinutes: 30,
    status: BookingStatus.confirmed,
  );

  group('CustomerRepositoryImpl with FakeDataSource', () {
    late _FakeCustomerRemoteDataSource fakeDataSource;
    late CustomerRepositoryImpl repository;

    setUp(() {
      fakeDataSource = _FakeCustomerRemoteDataSource();
      repository = CustomerRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('getServices returns services on success', () async {
      fakeDataSource.services = [tService];
      final result = await repository.getServices();
      expect(result, [tService]);
    });

    test('getServices maps AppException to ServerFailure', () async {
      fakeDataSource.errorToThrow =
          const ServerException(message: 'Remote error', code: 'remote-err');
      expect(
        () => repository.getServices(),
        throwsA(isA<ServerFailure>()
            .having((f) => f.message, 'message', 'Remote error')
            .having((f) => f.code, 'code', 'remote-err')),
      );
    });

    test('getBarbers returns barbers on success', () async {
      fakeDataSource.barbers = [tBarber];
      final result = await repository.getBarbers();
      expect(result, [tBarber]);
    });

    test('getCustomerBookings returns bookings on success', () async {
      fakeDataSource.bookings = [tBooking];
      final result = await repository.getCustomerBookings('c1');
      expect(result, [tBooking]);
    });

    test('getAvailableTimeSlots returns time slots', () async {
      final slot = DateTime.now().add(const Duration(hours: 2));
      fakeDataSource.timeSlots = [slot];
      final result = await repository.getAvailableTimeSlots(
        barberId: 'b1',
        date: DateTime.now(),
        durationMinutes: 30,
      );
      expect(result, [slot]);
    });

    test('createInstantBooking returns confirmed booking', () async {
      final bookingDate = DateTime.now().add(const Duration(days: 1));
      final result = await repository.createInstantBooking(
        customerId: 'c1',
        customerName: 'Sami',
        barberId: 'b1',
        barberName: 'Tariq',
        services: const [tService],
        dateTime: bookingDate,
        totalPrice: 30.0,
        totalDurationMinutes: 30,
      );

      expect(result.status, BookingStatus.confirmed);
      expect(result.customerId, 'c1');
      expect(result.services, [tService]);
    });

    test('cancelBooking invokes remoteDataSource', () async {
      await expectLater(
        repository.cancelBooking(bookingId: 'bk1', reason: 'Schedule conflict'),
        completes,
      );
    });
  });

  group('InMemoryFirestoreCustomerDataSource Integration', () {
    late InMemoryFirestoreCustomerDataSource dataSource;

    setUp(() {
      dataSource = InMemoryFirestoreCustomerDataSource();
    });

    test('initializes with pre-seeded luxury services and barbers', () async {
      final services = await dataSource.getServices();
      final barbers = await dataSource.getBarbers();

      expect(services, isNotEmpty);
      expect(barbers, isNotEmpty);
      expect(services.any((s) => s.id == 'srv_1'), isTrue);
      expect(barbers.any((b) => b.id == 'barber_1'), isTrue);
    });

    test(
        'creating instant booking adds to customer bookings and blocks that slot',
        () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final targetDate =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0);

      final initialSlots = await dataSource.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: tomorrow,
        durationMinutes: 30,
      );
      expect(initialSlots.contains(targetDate), isTrue);

      final services = await dataSource.getServices();
      final booking = await dataSource.createInstantBooking(
        customerId: 'cust_999',
        customerName: 'Ahmad',
        barberId: 'barber_1',
        barberName: 'Tariq Al-Hashemi',
        services: [services.first],
        dateTime: targetDate,
        totalPrice: 35.0,
        totalDurationMinutes: 30,
      );

      expect(booking.status, BookingStatus.confirmed);

      final customerBookings = await dataSource.getCustomerBookings('cust_999');
      expect(customerBookings.any((b) => b.id == booking.id), isTrue);

      final updatedSlots = await dataSource.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: tomorrow,
        durationMinutes: 30,
      );
      expect(updatedSlots.contains(targetDate), isFalse);

      await dataSource.cancelBooking(
        bookingId: booking.id,
        reason: 'Customer request',
      );

      final postCancelSlots = await dataSource.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: tomorrow,
        durationMinutes: 30,
      );
      expect(postCancelSlots.contains(targetDate), isTrue);
    });
  });
}
