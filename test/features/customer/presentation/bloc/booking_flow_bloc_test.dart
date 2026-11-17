import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:barber_app/features/customer/domain/usecases/create_instant_booking_usecase.dart';
import 'package:barber_app/features/customer/domain/usecases/get_available_time_slots_usecase.dart';
import 'package:barber_app/features/customer/domain/usecases/get_customer_home_data_usecase.dart';
import 'package:barber_app/features/customer/presentation/bloc/booking_flow_bloc.dart';
import 'package:barber_app/features/customer/presentation/bloc/booking_flow_event.dart';
import 'package:barber_app/features/customer/presentation/bloc/booking_flow_state.dart';

class _FailingCustomerRepository implements CustomerRepository {
  @override
  Future<List<ServiceEntity>> getServices() async {
    throw const ServerFailure(message: 'Failed to fetch services');
  }

  @override
  Future<List<BarberEntity>> getBarbers() async {
    throw const ServerFailure(message: 'Failed to fetch barbers');
  }

  @override
  Future<List<BookingEntity>> getCustomerBookings(String customerId) async {
    throw const ServerFailure(message: 'Failed to fetch bookings');
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    throw const ServerFailure(message: 'Failed to fetch slots');
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
    throw const ServerFailure(message: 'Failed to create booking');
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    throw const ServerFailure(message: 'Failed to cancel');
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
  const tService1 = ServiceEntity(
    id: 'srv_1',
    nameEn: 'Signature Haircut',
    nameAr: 'قصة شعر مميزة',
    descriptionEn: 'Haircut',
    descriptionAr: 'قص شعر',
    price: 35.0,
    durationMinutes: 45,
    iconName: 'content_cut',
  );

  const tService2 = ServiceEntity(
    id: 'srv_2',
    nameEn: 'Royal Shave',
    nameAr: 'حلاقة ملكية',
    descriptionEn: 'Shave',
    descriptionAr: 'حلاقة',
    price: 25.0,
    durationMinutes: 30,
    iconName: 'face',
  );

  const tBarber = BarberEntity(
    id: 'barber_1',
    name: 'Tariq Al-Hashemi',
    specialtyEn: 'Master Barber',
    specialtyAr: 'كبير الحلاقين',
    rating: 4.9,
    experienceYears: 12,
    isAvailableToday: true,
  );

  group('BookingFlowBloc Unit Tests', () {
    late InMemoryFirestoreCustomerDataSource dataSource;
    late CustomerRepositoryImpl repository;
    late GetAvailableTimeSlotsUseCase getAvailableTimeSlotsUseCase;
    late CreateInstantBookingUseCase createInstantBookingUseCase;
    late GetCustomerHomeDataUseCase getCustomerHomeDataUseCase;
    late BookingFlowBloc bloc;

    setUp(() {
      dataSource = InMemoryFirestoreCustomerDataSource();
      repository = CustomerRepositoryImpl(remoteDataSource: dataSource);
      getAvailableTimeSlotsUseCase = GetAvailableTimeSlotsUseCase(repository);
      createInstantBookingUseCase = CreateInstantBookingUseCase(repository);
      getCustomerHomeDataUseCase = GetCustomerHomeDataUseCase(repository);

      bloc = BookingFlowBloc(
        getAvailableTimeSlotsUseCase: getAvailableTimeSlotsUseCase,
        createInstantBookingUseCase: createInstantBookingUseCase,
        getCustomerHomeDataUseCase: getCustomerHomeDataUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has default values', () {
      expect(bloc.state.availableServices, isEmpty);
      expect(bloc.state.availableBarbers, isEmpty);
      expect(bloc.state.selectedServiceIds, isEmpty);
      expect(bloc.state.selectedBarber, isNull);
      expect(bloc.state.selectedSlot, isNull);
      expect(bloc.state.totalPrice, 0.0);
      expect(bloc.state.totalDurationMinutes, 0);
      expect(bloc.state.canSubmit, isFalse);
    });

    test(
        'BookingFlowInitialized loads services & barbers and applies preselection',
        () async {
      bloc.add(const BookingFlowInitialized(
        availableServices: [tService1, tService2],
        availableBarbers: [tBarber],
        preselectedServiceId: 'srv_1',
        preselectedBarberId: 'barber_1',
      ));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<BookingFlowState>((state) {
            return state.availableServices.length == 2 &&
                state.availableBarbers.length == 1 &&
                state.selectedServiceIds.contains('srv_1') &&
                state.selectedBarber?.id == 'barber_1' &&
                state.totalPrice == 35.0 &&
                state.totalDurationMinutes == 45 &&
                state.availableSlots.isNotEmpty;
          }),
        ),
      );
    });

    test(
        'BookingServiceToggled calculates total price and duration for multiple services',
        () async {
      bloc.emit(BookingFlowState.initial().copyWith(
        availableServices: [tService1, tService2],
        availableBarbers: [tBarber],
      ));

      bloc.add(const BookingServiceToggled('srv_1'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<BookingFlowState>((state) =>
              state.selectedServiceIds.contains('srv_1') &&
              state.totalPrice == 35.0 &&
              state.totalDurationMinutes == 45),
        ),
      );

      bloc.add(const BookingServiceToggled('srv_2'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<BookingFlowState>((state) =>
              state.selectedServiceIds.contains('srv_1') &&
              state.selectedServiceIds.contains('srv_2') &&
              state.totalPrice == 60.0 &&
              state.totalDurationMinutes == 75),
        ),
      );

      bloc.add(const BookingServiceToggled('srv_1'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<BookingFlowState>((state) =>
              !state.selectedServiceIds.contains('srv_1') &&
              state.selectedServiceIds.contains('srv_2') &&
              state.totalPrice == 25.0 &&
              state.totalDurationMinutes == 30),
        ),
      );
    });

    test(
        'BookingBarberSelected fetches slots and resets previously selected slot',
        () async {
      final initialSlot = DateTime(2026, 12, 1, 10, 0);
      bloc.emit(BookingFlowState.initial().copyWith(
        availableServices: [tService1],
        selectedServiceIds: {'srv_1'},
        totalDurationMinutes: 45,
        selectedSlot: () => initialSlot,
      ));

      bloc.add(const BookingBarberSelected(tBarber));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<BookingFlowState>((state) =>
              state.selectedBarber == tBarber &&
              state.selectedSlot == null &&
              state.isLoadingSlots == false &&
              state.availableSlots.isNotEmpty),
        ),
      );
    });

    test(
        'BookingDateSelected updates selectedDate and fetches slots for new date',
        () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      bloc.emit(BookingFlowState.initial().copyWith(
        availableServices: [tService1],
        selectedServiceIds: {'srv_1'},
        selectedBarber: () => tBarber,
        totalDurationMinutes: 45,
      ));

      bloc.add(BookingDateSelected(tomorrow));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<BookingFlowState>((state) =>
              state.selectedDate.day == tomorrow.day &&
              state.selectedSlot == null &&
              state.availableSlots.isNotEmpty),
        ),
      );
    });

    test(
        'BookingSubmitted creates instant confirmed booking and prevents double booking',
        () async {
      final targetDate = DateTime.now().add(const Duration(days: 2));
      final normalizedDate =
          DateTime(targetDate.year, targetDate.month, targetDate.day);

      final slots = await getAvailableTimeSlotsUseCase(
        barberId: tBarber.id,
        date: normalizedDate,
        durationMinutes: 45,
      );
      expect(slots, isNotEmpty);
      final bookedSlot = slots.first;

      bloc.emit(BookingFlowState.initial(normalizedDate).copyWith(
        availableServices: [tService1],
        availableBarbers: [tBarber],
        selectedServiceIds: {'srv_1'},
        selectedBarber: () => tBarber,
        selectedSlot: () => bookedSlot,
        availableSlots: slots,
        totalPrice: 35.0,
        totalDurationMinutes: 45,
      ));

      expect(bloc.state.canSubmit, isTrue);

      bloc.add(const BookingSubmitted(
        customerId: 'cust_sami',
        customerName: 'Sami Almuhur',
        notes: 'Fade low, keep length on top',
      ));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<BookingFlowState>((state) {
            final b = state.createdBooking;
            return b != null &&
                b.status == BookingStatus.confirmed &&
                b.customerId == 'cust_sami' &&
                b.barberId == tBarber.id &&
                b.notes == 'Fade low, keep length on top' &&
                state.isSubmitting == false;
          }),
        ),
      );

      final slotsAfterBooking = await getAvailableTimeSlotsUseCase(
        barberId: tBarber.id,
        date: normalizedDate,
        durationMinutes: 45,
      );

      final slotStillAvailable =
          slotsAfterBooking.any((s) => s.isAtSameMomentAs(bookedSlot));
      expect(slotStillAvailable, isFalse);
    });

    test('emits Failure when repository fails', () async {
      final failingRepo = _FailingCustomerRepository();
      final failingBloc = BookingFlowBloc(
        getAvailableTimeSlotsUseCase: GetAvailableTimeSlotsUseCase(failingRepo),
        createInstantBookingUseCase: CreateInstantBookingUseCase(failingRepo),
        getCustomerHomeDataUseCase: GetCustomerHomeDataUseCase(failingRepo),
      );
      addTearDown(failingBloc.close);

      failingBloc.emit(BookingFlowState.initial().copyWith(
        availableServices: [tService1],
        availableBarbers: [tBarber],
        selectedServiceIds: {'srv_1'},
        selectedBarber: () => tBarber,
        selectedSlot: () => DateTime.now().add(const Duration(days: 1)),
        totalPrice: 35.0,
        totalDurationMinutes: 45,
      ));

      failingBloc.add(const BookingSubmitted(
        customerId: 'c1',
        customerName: 'Sami',
      ));

      await expectLater(
        failingBloc.stream,
        emitsThrough(
          predicate<BookingFlowState>((state) =>
              state.failure != null &&
              state.failure!.message == 'Failed to create booking' &&
              state.isSubmitting == false),
        ),
      );
    });
  });
}
