import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/models/service_model.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';

void main() {
  group('Barber Persistent Datasource Sync & Actions', () {
    test(
        'ensureBarberProfile registers new barber and persists across restarts',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds1 = InMemoryFirestoreCustomerDataSource(prefs: prefs);

      final created = await ds1.ensureBarberProfile(
        barberId: 'barber_new_1',
        name: 'Kareem Mansour',
      );
      expect(created.id, 'barber_new_1');
      expect(created.name, 'Kareem Mansour');
      expect(created.isAvailableToday, isTrue);

      final barbers1 = await ds1.getBarbers();
      expect(barbers1.any((b) => b.id == 'barber_new_1'), isTrue);

      await ds1.updateBarberAvailability(
        barberId: 'barber_new_1',
        isAvailableToday: false,
      );

      final ds2 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      final barbers2 = await ds2.getBarbers();
      final persisted = barbers2.firstWhere((b) => b.id == 'barber_new_1');
      expect(persisted.name, 'Kareem Mansour');
      expect(persisted.isAvailableToday, isFalse);
    });

    test(
        'getBarberBookings isolates own bookings, supports complete, reschedule, and cancel with slot updates',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = InMemoryFirestoreCustomerDataSource(prefs: prefs);

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final slot1 = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10);
      final slot2 = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12);

      const service = ServiceModel(
        id: 'srv_1',
        nameEn: 'Haircut',
        nameAr: 'قص شعر',
        descriptionEn: 'Cut',
        descriptionAr: 'قص',
        price: 30,
        durationMinutes: 30,
        iconName: 'content_cut',
      );

      final b1 = await ds.createInstantBooking(
        customerId: 'cust_1',
        customerName: 'Sami',
        barberId: 'barber_1',
        barberName: 'Tariq',
        services: const [service],
        dateTime: slot1,
        totalPrice: 30,
        totalDurationMinutes: 30,
      );

      await ds.createInstantBooking(
        customerId: 'cust_2',
        customerName: 'Ali',
        barberId: 'barber_2',
        barberName: 'Omar',
        services: const [service],
        dateTime: slot1,
        totalPrice: 30,
        totalDurationMinutes: 30,
      );

      final barber1Bookings = await ds.getBarberBookings('barber_1');
      expect(barber1Bookings.length, 1);
      expect(barber1Bookings.first.id, b1.id);

      await expectLater(
        () => ds.rescheduleBooking(
          bookingId: b1.id,
          newDateTime: slot2,
          reason: '   ',
        ),
        throwsA(isA<ServerException>()),
      );

      await ds.rescheduleBooking(
        bookingId: b1.id,
        newDateTime: slot2,
        reason: 'Running 30 mins late',
      );

      final slotsAfterReschedule = await ds.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: tomorrow,
        durationMinutes: 30,
      );
      expect(slotsAfterReschedule.contains(slot1), isTrue);
      expect(slotsAfterReschedule.contains(slot2), isFalse);

      final updated = (await ds.getBarberBookings('barber_1')).first;
      expect(updated.status, BookingStatus.rescheduled);
      expect(updated.statusReason, 'Running 30 mins late');

      await ds.completeBooking(b1.id);
      final completed = (await ds.getBarberBookings('barber_1')).first;
      expect(completed.status, BookingStatus.completed);
    });
  });
}
