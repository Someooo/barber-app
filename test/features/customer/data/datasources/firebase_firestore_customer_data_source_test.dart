import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/features/customer/data/datasources/customer_remote_data_source.dart';
import 'package:barber_app/features/customer/data/datasources/firebase_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/models/barber_model.dart';
import 'package:barber_app/features/customer/data/models/booking_model.dart';
import 'package:barber_app/features/customer/data/models/service_model.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';

void main() {
  group('Firestore Models & DataSource Serialization', () {
    test('BookingModel.fromMap handles Firestore Timestamp and ISO String', () {
      final date = DateTime(2026, 11, 20, 14, 30);
      final timestamp = Timestamp.fromDate(date);

      final fromTimestamp = BookingModel.fromMap(
        {
          'customerId': 'cust_1',
          'customerName': 'Sami',
          'barberId': 'barber_1',
          'barberName': 'Tariq',
          'services': [
            {
              'id': 'srv_1',
              'nameEn': 'Cut',
              'nameAr': 'قص',
              'descriptionEn': 'Cut',
              'descriptionAr': 'قص',
              'price': 35.0,
              'durationMinutes': 45,
              'iconName': 'content_cut',
            },
          ],
          'dateTime': timestamp,
          'totalPrice': 35.0,
          'totalDurationMinutes': 45,
          'status': 'confirmed',
          'notes': 'Sharp fade',
        },
        'booking_ts',
      );

      expect(fromTimestamp.id, 'booking_ts');
      expect(fromTimestamp.dateTime, date);
      expect(fromTimestamp.status, BookingStatus.confirmed);
      expect(fromTimestamp.services.single.id, 'srv_1');

      final map = fromTimestamp.toMap();
      expect(map['dateTime'], date.toIso8601String());

      final fromIso = BookingModel.fromMap(map);
      expect(fromIso.id, 'booking_ts');
      expect(fromIso.dateTime, date);
      expect(fromIso.notes, 'Sharp fade');
    });

    test('ServiceModel and BarberModel round-trip cleanly', () {
      const service = ServiceModel(
        id: 'srv_1',
        nameEn: 'Royal Shave',
        nameAr: 'حلاقة ملكية',
        descriptionEn: 'Hot towel',
        descriptionAr: 'فوطة ساخنة',
        price: 25,
        durationMinutes: 30,
        iconName: 'face',
      );
      final decodedService = ServiceModel.fromMap(service.toMap(), service.id);
      expect(decodedService, service);

      const barber = BarberModel(
        id: 'barber_1',
        name: 'Tariq',
        specialtyEn: 'Master',
        specialtyAr: 'كبير',
        rating: 4.9,
        experienceYears: 12,
        isAvailableToday: true,
        imageUrl: 'https://example.com/tariq.jpg',
      );
      final decodedBarber = BarberModel.fromMap(barber.toMap(), barber.id);
      expect(decodedBarber, barber);
    });

    test(
        'FirebaseFirestoreCustomerDataSource implements CustomerRemoteDataSource',
        () {
      expect(
        FirebaseFirestoreCustomerDataSource(),
        isA<CustomerRemoteDataSource>(),
      );
    });

    test('rejects double booking on same barber slot and frees slot on cancel',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = InMemoryFirestoreCustomerDataSource(prefs: prefs);

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final slot = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11);
      const service = ServiceModel(
        id: 'srv_1',
        nameEn: 'Cut',
        nameAr: 'قص',
        descriptionEn: 'Cut',
        descriptionAr: 'قص',
        price: 35,
        durationMinutes: 30,
        iconName: 'content_cut',
      );

      final created = await ds.createInstantBooking(
        customerId: 'c1',
        customerName: 'Sami',
        barberId: 'barber_1',
        barberName: 'Tariq',
        services: const [service],
        dateTime: slot,
        totalPrice: 35,
        totalDurationMinutes: 30,
      );

      final slotsBeforeCancel = await ds.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: tomorrow,
        durationMinutes: 30,
      );
      expect(slotsBeforeCancel.contains(slot), isFalse);

      await ds.cancelBooking(bookingId: created.id, reason: 'Cancelled');
      final slotsAfterCancel = await ds.getAvailableTimeSlots(
        barberId: 'barber_1',
        date: tomorrow,
        durationMinutes: 30,
      );
      expect(slotsAfterCancel.contains(slot), isTrue);

      await expectLater(
        () => ds.rescheduleBooking(
          bookingId: 'non_existent',
          newDateTime: slot,
          reason: 'Test',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
