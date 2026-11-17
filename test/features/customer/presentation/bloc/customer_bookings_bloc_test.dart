import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:barber_app/features/customer/domain/usecases/cancel_booking_usecase.dart';
import 'package:barber_app/features/customer/domain/usecases/create_instant_booking_usecase.dart';
import 'package:barber_app/features/customer/domain/usecases/get_available_time_slots_usecase.dart';
import 'package:barber_app/features/customer/domain/usecases/get_customer_bookings_usecase.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_bookings_bloc.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_bookings_event.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_bookings_state.dart';

class _FailingCustomerRepo implements CustomerRepository {
  @override
  Future<List<BookingEntity>> getCustomerBookings(String customerId) async {
    throw const ServerFailure(message: 'Failed to load bookings');
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    throw const ServerFailure(message: 'Failed to cancel booking');
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
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<BarberEntity>> getBarbers() async {
    throw UnimplementedError();
  }

  @override
  Future<List<ServiceEntity>> getServices() async {
    throw UnimplementedError();
  }

  @override
  Future<BarberEntity> ensureBarberProfile({
    required String barberId,
    required String name,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<BookingEntity>> getBarberBookings(String barberId) async =>
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
  const tService = ServiceEntity(
    id: 'srv_1',
    nameEn: 'Signature Haircut',
    nameAr: 'قصة شعر مميزة',
    descriptionEn: 'Precision cut',
    descriptionAr: 'قص شعر متقن',
    price: 35.0,
    durationMinutes: 45,
    iconName: 'content_cut',
  );

  group('CustomerBookingsBloc Unit Tests', () {
    late InMemoryFirestoreCustomerDataSource dataSource;
    late CustomerRepositoryImpl repository;
    late GetCustomerBookingsUseCase getCustomerBookingsUseCase;
    late CancelBookingUseCase cancelBookingUseCase;
    late CreateInstantBookingUseCase createInstantBookingUseCase;
    late GetAvailableTimeSlotsUseCase getAvailableTimeSlotsUseCase;
    late CustomerBookingsBloc bloc;

    setUp(() {
      dataSource = InMemoryFirestoreCustomerDataSource();
      repository = CustomerRepositoryImpl(remoteDataSource: dataSource);
      getCustomerBookingsUseCase = GetCustomerBookingsUseCase(repository);
      cancelBookingUseCase = CancelBookingUseCase(repository);
      createInstantBookingUseCase = CreateInstantBookingUseCase(repository);
      getAvailableTimeSlotsUseCase = GetAvailableTimeSlotsUseCase(repository);

      bloc = CustomerBookingsBloc(
        getCustomerBookingsUseCase: getCustomerBookingsUseCase,
        cancelBookingUseCase: cancelBookingUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is CustomerBookingsInitial', () {
      expect(bloc.state, const CustomerBookingsInitial());
      expect(bloc.state.isInitial, isTrue);
      expect(bloc.state.upcomingOrEmpty, isEmpty);
      expect(bloc.state.historyOrEmpty, isEmpty);
    });

    test('CustomerBookingsTabChanged updates selectedTabIndex', () {
      final loadedState = const CustomerBookingsLoaded(
        upcomingBookings: [],
        historyBookings: [],
        selectedTabIndex: 0,
      );
      final blocWithState = CustomerBookingsBloc(
        getCustomerBookingsUseCase: getCustomerBookingsUseCase,
        cancelBookingUseCase: cancelBookingUseCase,
        initialState: loadedState,
      );
      addTearDown(blocWithState.close);

      expect(blocWithState.state.currentTabIndex, 0);

      blocWithState.add(const CustomerBookingsTabChanged(1));

      expectLater(
        blocWithState.stream,
        emits(predicate<CustomerBookingsState>((state) {
          return state is CustomerBookingsLoaded && state.selectedTabIndex == 1;
        })),
      );
    });

    test(
        'CustomerBookingsLoadRequested partitions bookings into upcoming and history',
        () async {
      final now = DateTime.now();
      final targetDate1 = now.add(const Duration(days: 1));
      final targetDate2 = now.add(const Duration(days: 2));

      final booking1 = await createInstantBookingUseCase(
        customerId: 'cust_sami',
        customerName: 'Sami Almuhur',
        barberId: 'barber_1',
        barberName: 'Tariq Al-Hashemi',
        services: const [tService],
        dateTime: targetDate1,
        totalPrice: 35.0,
        totalDurationMinutes: 45,
      );

      final booking2 = await createInstantBookingUseCase(
        customerId: 'cust_sami',
        customerName: 'Sami Almuhur',
        barberId: 'barber_1',
        barberName: 'Tariq Al-Hashemi',
        services: const [tService],
        dateTime: targetDate2,
        totalPrice: 35.0,
        totalDurationMinutes: 45,
      );

      await cancelBookingUseCase(
        bookingId: booking2.id,
        reason: 'Client schedule change',
      );

      bloc.add(const CustomerBookingsLoadRequested('cust_sami'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CustomerBookingsState>((state) {
          if (state is! CustomerBookingsLoaded) return false;
          final hasUpcoming =
              state.upcomingBookings.any((b) => b.id == booking1.id);
          final hasHistory = state.historyBookings.any((b) =>
              b.id == booking2.id && b.status == BookingStatus.cancelled);
          return hasUpcoming && hasHistory;
        })),
      );
    });

    test(
        'CustomerBookingCancelRequested cancels booking and immediately restores time slot',
        () async {
      final targetDate = DateTime.now().add(const Duration(days: 3));
      final normalizedDate =
          DateTime(targetDate.year, targetDate.month, targetDate.day);

      final initialSlots = await getAvailableTimeSlotsUseCase(
        barberId: 'barber_1',
        date: normalizedDate,
        durationMinutes: 45,
      );
      final slotToBook = initialSlots.first;

      final booking = await createInstantBookingUseCase(
        customerId: 'cust_sami',
        customerName: 'Sami Almuhur',
        barberId: 'barber_1',
        barberName: 'Tariq Al-Hashemi',
        services: const [tService],
        dateTime: slotToBook,
        totalPrice: 35.0,
        totalDurationMinutes: 45,
      );

      final slotsAfterBooking = await getAvailableTimeSlotsUseCase(
        barberId: 'barber_1',
        date: normalizedDate,
        durationMinutes: 45,
      );
      expect(
        slotsAfterBooking.any((s) => s.isAtSameMomentAs(slotToBook)),
        isFalse,
      );

      bloc.add(CustomerBookingCancelRequested(
        bookingId: booking.id,
        customerId: 'cust_sami',
        reason: 'Plans changed',
      ));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CustomerBookingsState>((state) {
          if (state is! CustomerBookingsLoaded) return false;
          final cancelledInHistory = state.historyBookings.any((b) =>
              b.id == booking.id &&
              b.status == BookingStatus.cancelled &&
              b.statusReason == 'Plans changed');
          final notInUpcoming =
              state.upcomingBookings.every((b) => b.id != booking.id);
          return cancelledInHistory && notInUpcoming;
        })),
      );

      final slotsAfterCancel = await getAvailableTimeSlotsUseCase(
        barberId: 'barber_1',
        date: normalizedDate,
        durationMinutes: 45,
      );
      expect(
        slotsAfterCancel.any((s) => s.isAtSameMomentAs(slotToBook)),
        isTrue,
      );
    });

    test('emits CustomerBookingsFailure when repository throws', () async {
      final failingRepo = _FailingCustomerRepo();
      final failingBloc = CustomerBookingsBloc(
        getCustomerBookingsUseCase: GetCustomerBookingsUseCase(failingRepo),
        cancelBookingUseCase: CancelBookingUseCase(failingRepo),
      );
      addTearDown(failingBloc.close);

      failingBloc.add(const CustomerBookingsLoadRequested('cust_sami'));

      await expectLater(
        failingBloc.stream,
        emitsThrough(predicate<CustomerBookingsState>((state) {
          return state is CustomerBookingsFailure &&
              state.message == 'Failed to load bookings';
        })),
      );
    });
  });
}
