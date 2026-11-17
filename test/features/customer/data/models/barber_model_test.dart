import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/features/customer/data/models/barber_model.dart';

void main() {
  group('BarberModel Serialization', () {
    test('fromMap and toMap preserve imageUrl when present', () {
      const imageUrl = 'https://example.com/barbers/tariq.jpg';
      final model = BarberModel.fromMap(
        const {
          'name': 'Tariq Al-Hashemi',
          'specialtyEn': 'Master Barber',
          'specialtyAr': 'كبير الحلاقين',
          'rating': 4.9,
          'experienceYears': 12,
          'isAvailableToday': true,
          'imageUrl': imageUrl,
        },
        'barber_1',
      );

      expect(model.id, 'barber_1');
      expect(model.imageUrl, imageUrl);
      expect(model.toMap()['imageUrl'], imageUrl);
    });

    test('fromMap and toMap handle null imageUrl cleanly', () {
      final model = BarberModel.fromMap(
        const {
          'name': 'Omar Khateeb',
          'specialtyEn': 'Modern Fades',
          'specialtyAr': 'التدرجات العصرية',
          'rating': 4.8,
          'experienceYears': 8,
          'isAvailableToday': false,
        },
        'barber_2',
      );

      expect(model.id, 'barber_2');
      expect(model.imageUrl, isNull);
      expect(model.toMap().containsKey('imageUrl'), isTrue);
      expect(model.toMap()['imageUrl'], isNull);
    });
  });
}
