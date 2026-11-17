import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import 'service_model.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.barberId,
    required super.barberName,
    required super.services,
    required super.dateTime,
    required super.totalPrice,
    required super.totalDurationMinutes,
    required super.status,
    super.notes,
    super.statusReason,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, [String? id]) {
    DateTime parsedDateTime;
    final rawDate = map['dateTime'];
    if (rawDate is Timestamp) {
      parsedDateTime = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDateTime = rawDate;
    } else if (rawDate is String) {
      parsedDateTime = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      parsedDateTime = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      parsedDateTime = DateTime.now();
    }

    final rawStatus = map['status'] as String?;
    final status = BookingStatus.values.firstWhere(
      (s) => s.name == rawStatus,
      orElse: () => BookingStatus.confirmed,
    );

    final rawServices = map['services'] as List<dynamic>? ?? const [];
    final services = rawServices.map((s) {
      final sMap = Map<String, dynamic>.from(s as Map);
      final sId = (sMap['id'] as String?) ?? '';
      return ServiceModel.fromMap(sMap, sId);
    }).toList();

    final resolvedId = id ?? (map['id'] as String?) ?? '';

    return BookingModel(
      id: resolvedId,
      customerId: (map['customerId'] as String?) ?? '',
      customerName: (map['customerName'] as String?) ?? '',
      barberId: (map['barberId'] as String?) ?? '',
      barberName: (map['barberName'] as String?) ?? '',
      services: services,
      dateTime: parsedDateTime,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      totalDurationMinutes:
          (map['totalDurationMinutes'] as num?)?.toInt() ?? 30,
      status: status,
      notes: map['notes'] as String?,
      statusReason: map['statusReason'] as String?,
    );
  }

  factory BookingModel.fromEntity(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      barberId: entity.barberId,
      barberName: entity.barberName,
      services: entity.services
          .map((s) => s is ServiceModel ? s : ServiceModel.fromEntity(s))
          .toList(),
      dateTime: entity.dateTime,
      totalPrice: entity.totalPrice,
      totalDurationMinutes: entity.totalDurationMinutes,
      status: entity.status,
      notes: entity.notes,
      statusReason: entity.statusReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'barberId': barberId,
      'barberName': barberName,
      'services': services.map((s) {
        final model = s is ServiceModel ? s : ServiceModel.fromEntity(s);
        final map = model.toMap();
        map['id'] = model.id;
        return map;
      }).toList(),
      'dateTime': dateTime.toIso8601String(),
      'totalPrice': totalPrice,
      'totalDurationMinutes': totalDurationMinutes,
      'status': status.name,
      'notes': notes,
      'statusReason': statusReason,
    };
  }
}
