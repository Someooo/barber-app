import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import '../models/barber_model.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import 'customer_remote_data_source.dart';

class FirebaseFirestoreCustomerDataSource implements CustomerRemoteDataSource {
  FirebaseFirestoreCustomerDataSource({FirebaseFirestore? firestore})
      : _firestoreInstance = firestore;

  final FirebaseFirestore? _firestoreInstance;

  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _servicesRef =>
      _firestore.collection('services');

  CollectionReference<Map<String, dynamic>> get _barbersRef =>
      _firestore.collection('barbers');

  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _firestore.collection('bookings');

  static const List<ServiceModel> _defaultServices = [
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
  ];

  Future<void> seedInitialCatalogIfEmpty() async {
    try {
      final existing = await _servicesRef.limit(1).get();
      if (existing.docs.isNotEmpty) return;

      final batch = _firestore.batch();
      for (final service in _defaultServices) {
        batch.set(_servicesRef.doc(service.id), service.toMap());
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      await seedInitialCatalogIfEmpty();
      final snapshot = await _servicesRef.get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<ServiceModel> addService(ServiceModel service) async {
    try {
      final id = service.id.isNotEmpty ? service.id : _servicesRef.doc().id;
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
      await _servicesRef.doc(id).set(created.toMap());
      return created;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      await _servicesRef.doc(serviceId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<List<BarberModel>> getBarbers() async {
    try {
      final snapshot = await _barbersRef.get();
      return snapshot.docs
          .map((doc) => BarberModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<BarberModel> addBarber(BarberModel barber) async {
    try {
      final id = barber.id.isNotEmpty ? barber.id : _barbersRef.doc().id;
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
      await _barbersRef.doc(id).set(created.toMap());
      return created;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<void> deleteBarber(String barberId) async {
    try {
      await _barbersRef.doc(barberId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<BarberModel> ensureBarberProfile({
    required String barberId,
    required String name,
  }) async {
    try {
      final docRef = _barbersRef.doc(barberId);
      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        return BarberModel.fromMap(snapshot.data()!, snapshot.id);
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
      await docRef.set(created.toMap(), SetOptions(merge: true));
      return created;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<void> updateBarberAvailability({
    required String barberId,
    required bool isAvailableToday,
  }) async {
    try {
      await _barbersRef
          .doc(barberId)
          .update({'isAvailableToday': isAvailableToday});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    try {
      final snapshot =
          await _bookingsRef.where('customerId', isEqualTo: customerId).get();
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<List<BookingModel>> getBarberBookings(String barberId) async {
    try {
      final snapshot =
          await _bookingsRef.where('barberId', isEqualTo: barberId).get();
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<List<BookingModel>> getAllShopBookings() async {
    try {
      final snapshot = await _bookingsRef.get();
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  Future<List<BookingModel>> _getActiveBarberBookingsForDate({
    required String barberId,
    required DateTime date,
  }) async {
    final snapshot = await _bookingsRef
        .where('barberId', isEqualTo: barberId)
        .where('status', whereIn: [
      BookingStatus.confirmed.name,
      BookingStatus.rescheduled.name,
    ]).get();

    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .where((b) =>
            b.dateTime.year == date.year &&
            b.dateTime.month == date.month &&
            b.dateTime.day == date.day)
        .toList();
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    try {
      final activeBookings = await _getActiveBarberBookingsForDate(
        barberId: barberId,
        date: date,
      );

      final slots = <DateTime>[];
      const startHour = 9;
      const endHour = 20;
      final targetDate = DateTime(date.year, date.month, date.day);
      final now = DateTime.now();

      for (int hour = startHour; hour < endHour; hour++) {
        for (final minute in [0, 30]) {
          final slotStart = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            hour,
            minute,
          );
          if (slotStart.isBefore(now)) continue;

          final slotEnd = slotStart.add(Duration(minutes: durationMinutes));
          final hasOverlap = activeBookings.any((booking) {
            final bookingStart = booking.dateTime;
            final bookingEnd = bookingStart
                .add(Duration(minutes: booking.totalDurationMinutes));
            return slotStart.isBefore(bookingEnd) &&
                slotEnd.isAfter(bookingStart);
          });
          if (!hasOverlap) {
            slots.add(slotStart);
          }
        }
      }
      return slots;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
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
    try {
      final candidateBookings = await _getActiveBarberBookingsForDate(
        barberId: barberId,
        date: dateTime,
      );
      final newDocRef = _bookingsRef.doc();
      final slotEnd = dateTime.add(Duration(minutes: totalDurationMinutes));

      return await _firestore.runTransaction((transaction) async {
        for (final existing in candidateBookings) {
          final snap = await transaction.get(_bookingsRef.doc(existing.id));
          if (!snap.exists || snap.data() == null) continue;
          final fresh = BookingModel.fromMap(snap.data()!, snap.id);
          if (fresh.status == BookingStatus.cancelled ||
              fresh.status == BookingStatus.completed) {
            continue;
          }
          final freshEnd =
              fresh.dateTime.add(Duration(minutes: fresh.totalDurationMinutes));
          if (dateTime.isBefore(freshEnd) && slotEnd.isAfter(fresh.dateTime)) {
            throw const ServerException(
              message: 'Selected time slot is no longer available',
              code: 'slot-unavailable',
            );
          }
        }

        final booking = BookingModel(
          id: newDocRef.id,
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
        transaction.set(newDocRef, booking.toMap());
        return booking;
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      await _bookingsRef.doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
        'statusReason': reason,
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<void> completeBooking(String bookingId) async {
    try {
      await _bookingsRef.doc(bookingId).update({
        'status': BookingStatus.completed.name,
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
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

    try {
      final targetDoc = _bookingsRef.doc(bookingId);
      final targetSnap = await targetDoc.get();
      if (!targetSnap.exists || targetSnap.data() == null) {
        throw const ServerException(
          message: 'Booking not found',
          code: 'booking-not-found',
        );
      }

      final targetBooking =
          BookingModel.fromMap(targetSnap.data()!, targetSnap.id);
      final candidateBookings = await _getActiveBarberBookingsForDate(
        barberId: targetBooking.barberId,
        date: newDateTime,
      );
      final newEnd = newDateTime
          .add(Duration(minutes: targetBooking.totalDurationMinutes));

      await _firestore.runTransaction((transaction) async {
        for (final existing in candidateBookings) {
          if (existing.id == bookingId) continue;
          final snap = await transaction.get(_bookingsRef.doc(existing.id));
          if (!snap.exists || snap.data() == null) continue;
          final fresh = BookingModel.fromMap(snap.data()!, snap.id);
          if (fresh.status == BookingStatus.cancelled ||
              fresh.status == BookingStatus.completed) {
            continue;
          }
          final freshEnd =
              fresh.dateTime.add(Duration(minutes: fresh.totalDurationMinutes));
          if (newDateTime.isBefore(freshEnd) &&
              newEnd.isAfter(fresh.dateTime)) {
            throw const ServerException(
              message: 'Selected time slot is no longer available',
              code: 'slot-unavailable',
            );
          }
        }

        transaction.update(targetDoc, {
          'dateTime': newDateTime.toIso8601String(),
          'status': BookingStatus.rescheduled.name,
          'statusReason': trimmedReason,
        });
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, code: e.code);
    }
  }
}
