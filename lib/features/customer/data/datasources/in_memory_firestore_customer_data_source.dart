import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';

import '../models/barber_model.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import 'customer_remote_data_source.dart';

class InMemoryFirestoreCustomerDataSource implements CustomerRemoteDataSource {
  static const String bookingsStorageKey = 'barbersync_customer_bookings';
  static const String barbersStorageKey = 'barbersync_barbers';
  static const String servicesStorageKey = 'barbersync_services';

  InMemoryFirestoreCustomerDataSource({SharedPreferences? prefs})
      : _prefs = prefs {
    _initPreseededData();
    _loadSavedServices();
    _loadSavedBarbers();
    _loadSavedBookings();
  }

  final SharedPreferences? _prefs;
  final List<ServiceModel> _services = [];
  final List<BarberModel> _barbers = [];
  final List<BookingModel> _bookings = [];

  void _loadSavedBookings() {
    final prefs = _prefs;
    if (prefs == null) return;

    final rawList = prefs.getStringList(bookingsStorageKey);
    if (rawList == null || rawList.isEmpty) return;

    for (final raw in rawList) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _bookings.add(BookingModel.fromMap(decoded));
        } else if (decoded is Map) {
          _bookings
              .add(BookingModel.fromMap(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {}
    }
  }

  Future<void> _saveBookings() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final encodedList = _bookings.map((b) => jsonEncode(b.toMap())).toList();
    await prefs.setStringList(bookingsStorageKey, encodedList);
  }

  void _loadSavedServices() {
    final prefs = _prefs;
    if (prefs == null) return;

    final rawList = prefs.getStringList(servicesStorageKey);
    if (rawList == null) return;

    final loaded = <ServiceModel>[];
    for (final raw in rawList) {
      try {
        final decoded = jsonDecode(raw);
        final map = decoded is Map<String, dynamic>
            ? decoded
            : (decoded is Map ? Map<String, dynamic>.from(decoded) : null);
        if (map == null) continue;
        final id = (map['id'] as String?) ?? '';
        if (id.isEmpty) continue;
        loaded.add(ServiceModel.fromMap(map, id));
      } catch (_) {}
    }
    _services
      ..clear()
      ..addAll(loaded);
  }

  Future<void> _saveServices() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final encodedList = _services
        .map((s) => jsonEncode(<String, dynamic>{'id': s.id, ...s.toMap()}))
        .toList();
    await prefs.setStringList(servicesStorageKey, encodedList);
  }

  void _loadSavedBarbers() {
    final prefs = _prefs;
    if (prefs == null) return;

    final rawList = prefs.getStringList(barbersStorageKey);
    if (rawList == null) return;

    final loaded = <BarberModel>[];
    for (final raw in rawList) {
      try {
        final decoded = jsonDecode(raw);
        final map = decoded is Map<String, dynamic>
            ? decoded
            : (decoded is Map ? Map<String, dynamic>.from(decoded) : null);
        if (map == null) continue;
        final id = (map['id'] as String?) ?? '';
        if (id.isEmpty) continue;
        loaded.add(BarberModel.fromMap(map, id));
      } catch (_) {}
    }
    _barbers
      ..clear()
      ..addAll(loaded);
  }

  Future<void> _saveBarbers() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final encodedList = _barbers
        .map((b) => jsonEncode(<String, dynamic>{'id': b.id, ...b.toMap()}))
        .toList();
    await prefs.setStringList(barbersStorageKey, encodedList);
  }

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
        imageUrl:
            'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80',
      ),
      BarberModel(
        id: 'barber_2',
        name: 'Omar Khateeb',
        specialtyEn: 'Modern Fades & Textures',
        specialtyAr: 'خبير التدرجات العصرية والتصفيف',
        rating: 4.8,
        experienceYears: 8,
        isAvailableToday: true,
        imageUrl:
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80',
      ),
      BarberModel(
        id: 'barber_3',
        name: 'Zaid Al-Mansoor',
        specialtyEn: 'Beard Artistry & Razor Precision',
        specialtyAr: 'أخصائي فن ونحت اللحى بالموس',
        rating: 4.9,
        experienceYears: 10,
        isAvailableToday: true,
        imageUrl:
            'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=600&q=80',
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
    const startHour = 9;
    const endHour = 20;

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
    await _saveBookings();
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
    await _saveBookings();
  }

  @override
  Future<BarberModel> ensureBarberProfile({
    required String barberId,
    required String name,
  }) async {
    final existingIndex = _barbers.indexWhere((b) => b.id == barberId);
    if (existingIndex >= 0) {
      return _barbers[existingIndex];
    }

    final created = BarberModel(
      id: barberId,
      name: name.trim().isNotEmpty ? name.trim() : 'Master Barber',
      specialtyEn: 'Master Barber & Grooming',
      specialtyAr: 'حلاق محترف وتصفيف الشعر',
      rating: 5.0,
      experienceYears: 5,
      isAvailableToday: true,
    );
    _barbers.add(created);
    await _saveBarbers();
    return created;
  }

  @override
  Future<List<BookingModel>> getBarberBookings(String barberId) async {
    return _bookings.where((b) => b.barberId == barberId).toList();
  }

  @override
  Future<void> updateBarberAvailability({
    required String barberId,
    required bool isAvailableToday,
  }) async {
    final index = _barbers.indexWhere((b) => b.id == barberId);
    if (index == -1) {
      throw const ServerException(
        message: 'Barber profile not found',
        code: 'barber-not-found',
      );
    }

    final existing = _barbers[index];
    _barbers[index] = BarberModel(
      id: existing.id,
      name: existing.name,
      specialtyEn: existing.specialtyEn,
      specialtyAr: existing.specialtyAr,
      rating: existing.rating,
      experienceYears: existing.experienceYears,
      isAvailableToday: isAvailableToday,
      imageUrl: existing.imageUrl,
    );
    await _saveBarbers();
  }

  @override
  Future<void> completeBooking(String bookingId) async {
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
      status: BookingStatus.completed,
      notes: existing.notes,
      statusReason: existing.statusReason,
    );
    await _saveBookings();
  }

  @override
  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDateTime,
    required String reason,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw const ServerException(
        message: 'Reschedule reason is required',
        code: 'reason-required',
      );
    }

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw const ServerException(
        message: 'Booking not found',
        code: 'booking-not-found',
      );
    }

    final existing = _bookings[index];
    final newEnd =
        newDateTime.add(Duration(minutes: existing.totalDurationMinutes));

    final hasConflict = _bookings.any((other) {
      if (other.id == bookingId) return false;
      if (other.barberId != existing.barberId) return false;
      if (other.status == BookingStatus.cancelled) return false;
      final otherStart = other.dateTime;
      final otherEnd =
          otherStart.add(Duration(minutes: other.totalDurationMinutes));
      return newDateTime.isBefore(otherEnd) && newEnd.isAfter(otherStart);
    });

    if (hasConflict) {
      throw const ServerException(
        message: 'Selected time slot is no longer available',
        code: 'slot-unavailable',
      );
    }

    _bookings[index] = BookingModel(
      id: existing.id,
      customerId: existing.customerId,
      customerName: existing.customerName,
      barberId: existing.barberId,
      barberName: existing.barberName,
      services: existing.services,
      dateTime: newDateTime,
      totalPrice: existing.totalPrice,
      totalDurationMinutes: existing.totalDurationMinutes,
      status: BookingStatus.rescheduled,
      notes: existing.notes,
      statusReason: trimmedReason,
    );
    await _saveBookings();
  }

  @override
  Future<ServiceModel> addService(ServiceModel service) async {
    final id = service.id.isNotEmpty
        ? service.id
        : 'srv_${DateTime.now().millisecondsSinceEpoch}';
    final created = ServiceModel(
      id: id,
      nameEn: service.nameEn,
      nameAr: service.nameAr,
      descriptionEn: service.descriptionEn,
      descriptionAr: service.descriptionAr,
      price: service.price,
      durationMinutes: service.durationMinutes,
      iconName: service.iconName,
    );
    _services.add(created);
    await _saveServices();
    return created;
  }

  @override
  Future<void> deleteService(String serviceId) async {
    _services.removeWhere((s) => s.id == serviceId);
    await _saveServices();
  }

  @override
  Future<BarberModel> addBarber(BarberModel barber) async {
    final id = barber.id.isNotEmpty
        ? barber.id
        : 'barber_${DateTime.now().millisecondsSinceEpoch}';
    final created = BarberModel(
      id: id,
      name: barber.name,
      specialtyEn: barber.specialtyEn,
      specialtyAr: barber.specialtyAr,
      rating: barber.rating,
      experienceYears: barber.experienceYears,
      isAvailableToday: barber.isAvailableToday,
      imageUrl: barber.imageUrl,
    );
    _barbers.add(created);
    await _saveBarbers();
    return created;
  }

  @override
  Future<void> deleteBarber(String barberId) async {
    _barbers.removeWhere((b) => b.id == barberId);
    await _saveBarbers();
  }

  @override
  Future<List<BookingModel>> getAllShopBookings() async {
    return List.unmodifiable(_bookings);
  }
}
