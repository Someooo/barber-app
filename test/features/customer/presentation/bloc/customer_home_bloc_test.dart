import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:barber_app/features/customer/domain/usecases/get_customer_home_data_usecase.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_home_bloc.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_home_event.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_home_state.dart';

class _FakeCustomerRepository implements CustomerRepository {
  List<ServiceEntity> services = [];
  List<BarberEntity> barbers = [];
  List<BookingEntity> bookings = [];
  Failure? failureToThrow;

  @override
  Future<List<ServiceEntity>> getServices() async {
    if (failureToThrow != null) throw failureToThrow!;
    return services;
  }

  @override
  Future<List<BarberEntity>> getBarbers() async {
    if (failureToThrow != null) throw failureToThrow!;
    return barbers;
  }

  @override
  Future<List<BookingEntity>> getCustomerBookings(String customerId) async {
    if (failureToThrow != null) throw failureToThrow!;
    return bookings;
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    return [];
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
    throw UnimplementedError();
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  const tService = ServiceEntity(
    id: 's1',
    nameEn: 'Cut',
    nameAr: 'قص',
    descriptionEn: 'Haircut',
    descriptionAr: 'قص شعر',
    price: 35.0,
    durationMinutes: 30,
    iconName: 'content_cut',
  );

  const tBarber = BarberEntity(
    id: 'b1',
    name: 'Tariq',
    specialtyEn: 'Master Barber',
    specialtyAr: 'كبير الحلاقين',
    rating: 4.9,
    experienceYears: 10,
    isAvailableToday: true,
  );

  final tActiveBooking = BookingEntity(
    id: 'bk_1',
    customerId: 'cust_1',
    customerName: 'Sami',
    barberId: 'b1',
    barberName: 'Tariq',
    services: const [tService],
    dateTime: DateTime.now().add(const Duration(days: 1)),
    totalPrice: 35.0,
    totalDurationMinutes: 30,
    status: BookingStatus.confirmed,
  );

  group('CustomerHomeBloc', () {
    late _FakeCustomerRepository repository;
    late GetCustomerHomeDataUseCase useCase;
    late CustomerHomeBloc bloc;

    setUp(() {
      repository = _FakeCustomerRepository();
      useCase = GetCustomerHomeDataUseCase(repository);
      bloc = CustomerHomeBloc(getCustomerHomeDataUseCase: useCase);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is CustomerHomeInitial', () {
      expect(bloc.state, const CustomerHomeInitial());
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isLoaded, isFalse);
      expect(bloc.state.hasActiveBooking, isFalse);
    });

    test(
        'CustomerHomeLoadRequested emits [CustomerHomeLoading, CustomerHomeLoaded] on success',
        () async {
      repository.services = [tService];
      repository.barbers = [tBarber];
      repository.bookings = [tActiveBooking];

      final expectedStates = [
        const CustomerHomeLoading(),
        CustomerHomeLoaded(
          services: const [tService],
          barbers: const [tBarber],
          activeBooking: tActiveBooking,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const CustomerHomeLoadRequested(customerId: 'cust_1'));
    });

    test(
        'CustomerHomeLoadRequested emits [CustomerHomeLoading, CustomerHomeFailure] on Failure',
        () async {
      repository.failureToThrow =
          const ServerFailure(message: 'Connection failed', code: '500');

      final expectedStates = [
        const CustomerHomeLoading(),
        const CustomerHomeFailure(message: 'Connection failed', code: '500'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const CustomerHomeLoadRequested(customerId: 'cust_1'));
    });

    test(
        'CustomerHomeRefreshRequested updates state without emitting CustomerHomeLoading',
        () async {
      repository.services = [tService];
      repository.barbers = [tBarber];
      repository.bookings = [];

      final expectedStates = [
        const CustomerHomeLoaded(
          services: [tService],
          barbers: [tBarber],
          activeBooking: null,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const CustomerHomeRefreshRequested(customerId: 'cust_1'));
    });

    test('CustomerHomeLoaded semantic getters work properly', () {
      final loadedWithBooking = CustomerHomeLoaded(
        services: const [tService],
        barbers: const [tBarber],
        activeBooking: tActiveBooking,
      );

      expect(loadedWithBooking.isLoaded, isTrue);
      expect(loadedWithBooking.hasActiveBooking, isTrue);
      expect(loadedWithBooking.activeBookingOrNull, tActiveBooking);
      expect(loadedWithBooking.servicesOrEmpty, [tService]);
      expect(loadedWithBooking.barbersOrEmpty, [tBarber]);

      final loadedWithoutBooking = const CustomerHomeLoaded(
        services: [],
        barbers: [],
        activeBooking: null,
      );

      expect(loadedWithoutBooking.hasActiveBooking, isFalse);
      expect(loadedWithoutBooking.activeBookingOrNull, isNull);
    });
  });
}
