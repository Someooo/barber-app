import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/features/barber/domain/usecases/barber_cancel_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/complete_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/ensure_barber_profile_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/get_barber_bookings_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/reschedule_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/update_barber_availability_usecase.dart';
import 'package:barber_app/features/barber/presentation/bloc/barber_dashboard_bloc.dart';
import 'package:barber_app/features/barber/presentation/bloc/barber_dashboard_event.dart';
import 'package:barber_app/features/barber/presentation/bloc/barber_dashboard_state.dart';
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';

void main() {
  group('BarberDashboardBloc', () {
    late CustomerRepositoryImpl repository;
    late BarberDashboardBloc bloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      repository = CustomerRepositoryImpl(remoteDataSource: ds);
      bloc = BarberDashboardBloc(
        ensureBarberProfileUseCase: EnsureBarberProfileUseCase(repository),
        getBarberBookingsUseCase: GetBarberBookingsUseCase(repository),
        updateBarberAvailabilityUseCase:
            UpdateBarberAvailabilityUseCase(repository),
        completeBookingUseCase: CompleteBookingUseCase(repository),
        rescheduleBookingUseCase: RescheduleBookingUseCase(repository),
        barberCancelBookingUseCase: BarberCancelBookingUseCase(repository),
      );
    });

    tearDown(() => bloc.close());

    test('loads only own bookings, toggles availability, completes and cancels',
        () async {
      const service = ServiceEntity(
        id: 'srv_1',
        nameEn: 'Cut',
        nameAr: 'قص',
        descriptionEn: 'Cut',
        descriptionAr: 'قص',
        price: 40,
        durationMinutes: 30,
        iconName: 'content_cut',
      );
      final now = DateTime.now();
      final todaySlot = DateTime(now.year, now.month, now.day, 23, 0);

      final ownBooking = await repository.createInstantBooking(
        customerId: 'c1',
        customerName: 'Sami',
        barberId: 'barber_custom',
        barberName: 'Nabil',
        services: const [service],
        dateTime: todaySlot,
        totalPrice: 40,
        totalDurationMinutes: 30,
      );
      await repository.createInstantBooking(
        customerId: 'c2',
        customerName: 'Other',
        barberId: 'barber_1',
        barberName: 'Tariq',
        services: const [service],
        dateTime: todaySlot,
        totalPrice: 40,
        totalDurationMinutes: 30,
      );

      bloc.add(const BarberDashboardLoadRequested(
        barberId: 'barber_custom',
        barberName: 'Nabil',
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(isA<BarberDashboardLoaded>()),
      );

      final loaded = bloc.state as BarberDashboardLoaded;
      expect(loaded.barberProfile.id, 'barber_custom');
      expect(loaded.todayBookings.length, 1);
      expect(loaded.todayBookings.first.id, ownBooking.id);
      expect(loaded.todayExpectedRevenue, 40.0);

      bloc.add(const BarberAvailabilityToggled(
        barberId: 'barber_custom',
        isAvailableToday: false,
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BarberDashboardLoaded>().having(
            (s) => s.barberProfile.isAvailableToday,
            'isAvailableToday',
            isFalse,
          ),
        ),
      );

      bloc.add(BarberBookingCancelled(
        bookingId: ownBooking.id,
        barberId: 'barber_custom',
        reason: 'Emergency',
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BarberDashboardLoaded>().having(
            (s) => s.historyBookings.length,
            'historyBookings.length',
            1,
          ),
        ),
      );

      final afterCancel = bloc.state as BarberDashboardLoaded;
      expect(afterCancel.todayBookings, isEmpty);
      expect(afterCancel.historyBookings.first.status, BookingStatus.cancelled);
      expect(afterCancel.historyBookings.first.statusReason, 'Emergency');
    });
  });
}
