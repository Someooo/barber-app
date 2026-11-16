import 'dart:async';

import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';

import '../models/barber_model.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import 'customer_remote_data_source.dart';

class InMemoryFirestoreCustomerDataSource implements CustomerRemoteDataSource {
  InMemoryFirestoreCustomerDataSource() {
    _initPreseededData();
  }

  final List<ServiceModel> _services = [];
  final List<BarberModel> _barbers = [];
  final List<BookingModel> _bookings = [];

  void _initPreseededData() {
    _services.addAll(const [
      ServiceModel(
        id: 'srv_1',
        nameEn: 'Signature Haircut & Beard Sculpting',
        nameAr: 'قصة شعر وتحديد اللحية المميزة',
        descriptionEn:
            'Precision shear cut, hot towel finish, and razor beard sculpting with nourishing oils.',
        descriptionAr:
            'قص شعر متقن، كمادات ساخنة، وتحديد اللحية بالموس مع زيوت العناية الفاخرة.',
        price: 35.0,
        durationMinutes: 45,
        iconName: 'content_cut',
      ),
      ServiceModel(
        id: 'srv_2',
        nameEn: 'Royal Shave & Hot Towel Treatment',
        nameAr: 'حلاقة ملكية مع فوطة ساخنة',
        descriptionEn:
            'Traditional straight razor shave with essential oils, pre-shave cream, and cold towel close.',
        descriptionAr:
            'حلاقة كلاسيكية بالموس المستقيم مع زيوت مهدئة، رغوة ساخنة، وفوطة باردة لغلق المسام.',
        price: 25.0,
        durationMinutes: 30,
        iconName: 'face',
      ),
      ServiceModel(
        id: 'srv_3',
        nameEn: 'Haircut & Scalp Treatment',
        nameAr: 'قص شعر وعلاج منشط للفروة',
        descriptionEn:
            'Custom fade or classic cut paired with tea tree scalp exfoliating therapy and massage.',
        descriptionAr:
            'قصة شعر مخصصة مع تدليك وتقشير فروة الرأس بخلاصة شجرة الشاي الطبيعية.',
        price: 30.0,
        durationMinutes: 40,
        iconName: 'spa',
      ),
      ServiceModel(
        id: 'srv_4',
        nameEn: 'Executive Beard Sculpting',
        nameAr: 'تحديد ونحت اللحية الفاخر',
        descriptionEn:
            'Detailed beard shape-up, trimmer taper, razor contour, and organic conditioning balm.',
        descriptionAr:
            'تحديد دقيق للذقن، تدرج احترافي، موس حاد مع بلسم ترطيب عضوي برائحة العود.',
        price: 20.0,
        durationMinutes: 25,
        iconName: 'brush',
      ),
      ServiceModel(
        id: 'srv_5',
        nameEn: 'BarberSync Complete Grooming',
        nameAr: 'باقة BarberSync المتكاملة',
        descriptionEn:
            'The pinnacle experience: signature cut, royal shave, scalp treatment, and mini facial.',
        descriptionAr:
            'التجربة المتكاملة: قص شعر، حلاقة ملكية، عناية بالفروة، وجلسة نضارة سريعة للبشرة.',
        price: 65.0,
        durationMinutes: 75,
        iconName: 'star',
      ),
    ]);

    _barbers.addAll(const [
      BarberModel(
        id: 'barber_1',
        name: 'Tariq Al-Hashemi',
        specialtyEn: 'Master Barber & Classic Styling',
        specialtyAr: 'كبير الحلاقين والتصفيف الكلاسيكي',
        rating: 4.9,
        experienceYears: 12,
        isAvailableToday: true,
      ),
      BarberModel(
        id: 'barber_2',
        name: 'Omar Khateeb',
        specialtyEn: 'Modern Fades & Textures',
        specialtyAr: 'خبير التدرجات العصرية والتصفيف',
        rating: 4.8,
        experienceYears: 8,
        isAvailableToday: true,
      ),
      BarberModel(
        id: 'barber_3',
        name: 'Zaid Al-Mansoor',
        specialtyEn: 'Beard Artistry & Razor Precision',
        specialtyAr: 'أخصائي فن ونحت اللحى بالموس',
        rating: 4.9,
        experienceYears: 10,
        isAvailableToday: true,
      ),
    ]);
  }

  @override
  Future<List<ServiceModel>> getServices() async {
    return List.unmodifiable(_services);
  }

  @override
  Future<List<BarberModel>> getBarbers() async {
    return List.unmodifiable(_barbers);
  }

  @override
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    return _bookings
        .where((b) => b.customerId == customerId || b.customerId.isEmpty)
        .toList();
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    final slots = <DateTime>[];
    final startHour = 9;
    final endHour = 20;

    final targetDate = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();

    final activeBarberBookings = _bookings.where((b) {
      if (b.barberId != barberId) return false;
      if (b.status == BookingStatus.cancelled) return false;
      final bDate = b.dateTime;
      return bDate.year == date.year &&
          bDate.month == date.month &&
          bDate.day == date.day;
    }).toList();

    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute in [0, 30]) {
        final slotStart = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          hour,
          minute,
        );

        if (slotStart.isBefore(now)) {
          continue;
        }

        final slotEnd = slotStart.add(Duration(minutes: durationMinutes));

        final hasOverlap = activeBarberBookings.any((booking) {
          final bookingStart = booking.dateTime;
          final bookingEnd =
              bookingStart.add(Duration(minutes: booking.totalDurationMinutes));
          return slotStart.isBefore(bookingEnd) &&
              slotEnd.isAfter(bookingStart);
        });

        if (!hasOverlap) {
          slots.add(slotStart);
        }
      }
    }

    return slots;
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
    final bookingId = 'booking_${DateTime.now().millisecondsSinceEpoch}';
    final booking = BookingModel(
      id: bookingId,
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

    _bookings.add(booking);
    return booking;
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw const ServerException(
        message: 'Booking not found',
        code: 'booking-not-found',
      );
    }

    final existing = _bookings[index];
    _bookings[index] = BookingModel(
      id: existing.id,
      customerId: existing.customerId,
      customerName: existing.customerName,
      barberId: existing.barberId,
      barberName: existing.barberName,
      services: existing.services,
      dateTime: existing.dateTime,
      totalPrice: existing.totalPrice,
      totalDurationMinutes: existing.totalDurationMinutes,
      status: BookingStatus.cancelled,
      notes: existing.notes,
      statusReason: reason,
    );
  }
}
