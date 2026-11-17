import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/models/barber_model.dart';
import 'package:barber_app/features/customer/data/models/service_model.dart';

void main() {
  group('Owner Persistent Services & Barbers Management', () {
    test('adds and deletes services and persists across restarts', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds1 = InMemoryFirestoreCustomerDataSource(prefs: prefs);

      final initialCount = (await ds1.getServices()).length;

      final added = await ds1.addService(const ServiceModel(
        id: 'srv_vip',
        nameEn: 'VIP Royal Package',
        nameAr: 'باقة ملكية',
        descriptionEn: 'Full grooming',
        descriptionAr: 'عناية كاملة',
        price: 90,
        durationMinutes: 60,
        iconName: 'star',
      ));

      expect(added.id, 'srv_vip');
      expect((await ds1.getServices()).length, initialCount + 1);

      final ds2 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      expect((await ds2.getServices()).any((s) => s.id == 'srv_vip'), isTrue);

      await ds2.deleteService('srv_vip');
      expect((await ds2.getServices()).any((s) => s.id == 'srv_vip'), isFalse);

      final ds3 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      expect((await ds3.getServices()).any((s) => s.id == 'srv_vip'), isFalse);
    });

    test('adds and deletes barbers and persists across restarts', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds1 = InMemoryFirestoreCustomerDataSource(prefs: prefs);

      final added = await ds1.addBarber(const BarberModel(
        id: 'barber_vip',
        name: 'Faisal Al-Nasser',
        specialtyEn: 'Executive Styling',
        specialtyAr: 'تصفيف تنفيذي',
        rating: 5.0,
        experienceYears: 9,
        isAvailableToday: true,
      ));

      expect(added.id, 'barber_vip');
      expect((await ds1.getBarbers()).any((b) => b.id == 'barber_vip'), isTrue);

      final ds2 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      expect(
        (await ds2.getBarbers()).any((b) => b.id == 'barber_vip'),
        isTrue,
      );

      await ds2.deleteBarber('barber_vip');
      expect(
        (await ds2.getBarbers()).any((b) => b.id == 'barber_vip'),
        isFalse,
      );

      final ds3 = InMemoryFirestoreCustomerDataSource(prefs: prefs);
      expect(
        (await ds3.getBarbers()).any((b) => b.id == 'barber_vip'),
        isFalse,
      );
    });
  });
}
