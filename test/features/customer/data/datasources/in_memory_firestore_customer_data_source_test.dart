import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/models/service_model.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';

void main() {
  group('InMemoryFirestoreCustomerDataSource Persistence', () {
    const tServices = [
      ServiceModel(
        id: 'srv_1',
        nameEn: 'Signature Haircut',
        nameAr: 'قصة شعر مميزة',
        descriptionEn: 'Haircut description',
        descriptionAr: 'وصف قصة الشعر',
        price: 35.0,
        durationMinutes: 45,
        iconName: 'content_cut',
      ),
    ];

    test('initializes with preseeded services and barbers', () async {
      final dataSource = InMemoryFirestoreCustomerDataSource();

      final services = await dataSource.getServices();
      final barbers = await dataSource.getBarbers();

      expect(services, isNotEmpty);
      expect(barbers, isNotEmpty);
    });

    test('creates booking and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final dataSource1 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      final bookingDate = DateTime.now().add(const Duration(days: 1));

      final created = await dataSource1.createInstantBooking(
        customerId: 'cust_sami',
        customerName: 'Sami Almuhur',
        barberId: 'barber_1',
        barberName: 'Tariq Al-Hashemi',
        services: tServices,
        dateTime: bookingDate,
        totalPrice: 35.0,
        totalDurationMinutes: 45,
        notes: 'VIP customer',
      );

      expect(created.id, isNotEmpty);
      expect(created.status, BookingStatus.confirmed);

      final savedList = prefs.getStringList(
          InMemoryFirestoreCustomerDataSource.bookingsStorageKey);
      expect(savedList, isNotNull);
      expect(savedList!.length, 1);

      final dataSource2 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      final restoredBookings =
          await dataSource2.getCustomerBookings('cust_sami');

      expect(restoredBookings.length, 1);
      expect(restoredBookings.first.id, created.id);
      expect(restoredBookings.first.customerName, 'Sami Almuhur');
      expect(restoredBookings.first.barberName, 'Tariq Al-Hashemi');
      expect(restoredBookings.first.status, BookingStatus.confirmed);
      expect(restoredBookings.first.notes, 'VIP customer');
    });

    test('persisted booking blocks time slots across datasource instances',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final dataSource1 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      final targetDate = DateTime.now().add(const Duration(days: 2));
      final appointmentTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        10,
        0,
      );

      final initialSlots = await dataSource1.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: targetDate,
        durationMinutes: 45,
      );
      expect(initialSlots.contains(appointmentTime), isTrue);

      await dataSource1.createInstantBooking(
        customerId: 'cust_sami',
        customerName: 'Sami Almuhur',
        barberId: 'barber_1',
        barberName: 'Tariq Al-Hashemi',
        services: tServices,
        dateTime: appointmentTime,
        totalPrice: 35.0,
        totalDurationMinutes: 45,
      );

      final dataSource2 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      final updatedSlots = await dataSource2.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: targetDate,
        durationMinutes: 45,
      );

      expect(updatedSlots.contains(appointmentTime), isFalse);
    });

    test('cancelling a booking persists status and frees the blocked time slot',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final dataSource1 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      final targetDate = DateTime.now().add(const Duration(days: 3));
      final appointmentTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        14,
        0,
      );

      final booking = await dataSource1.createInstantBooking(
        customerId: 'cust_sami',
        customerName: 'Sami Almuhur',
        barberId: 'barber_1',
        barberName: 'Tariq Al-Hashemi',
        services: tServices,
        dateTime: appointmentTime,
        totalPrice: 35.0,
        totalDurationMinutes: 45,
      );

      await dataSource1.cancelBooking(
        bookingId: booking.id,
        reason: 'Customer requested cancellation',
      );

      final dataSource2 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      final bookings = await dataSource2.getCustomerBookings('cust_sami');

      expect(bookings.length, 1);
      expect(bookings.first.status, BookingStatus.cancelled);
      expect(bookings.first.statusReason, 'Customer requested cancellation');

      final freeSlots = await dataSource2.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: targetDate,
        durationMinutes: 45,
      );
      expect(freeSlots.contains(appointmentTime), isTrue);
    });
  });
}
