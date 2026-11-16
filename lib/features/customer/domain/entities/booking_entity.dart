import 'package:equatable/equatable.dart';

import 'booking_status.dart';
import 'service_entity.dart';

class BookingEntity extends Equatable {
  const BookingEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.barberId,
    required this.barberName,
    required this.services,
    required this.dateTime,
    required this.totalPrice,
    required this.totalDurationMinutes,
    required this.status,
    this.notes,
    this.statusReason,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String barberId;
  final String barberName;
  final List<ServiceEntity> services;
  final DateTime dateTime;
  final double totalPrice;
  final int totalDurationMinutes;
  final BookingStatus status;
  final String? notes;
  final String? statusReason;

  BookingEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? barberId,
    String? barberName,
    List<ServiceEntity>? services,
    DateTime? dateTime,
    double? totalPrice,
    int? totalDurationMinutes,
    BookingStatus? status,
    String? notes,
    String? statusReason,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      barberId: barberId ?? this.barberId,
      barberName: barberName ?? this.barberName,
      services: services ?? this.services,
      dateTime: dateTime ?? this.dateTime,
      totalPrice: totalPrice ?? this.totalPrice,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      statusReason: statusReason ?? this.statusReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        barberId,
        barberName,
        services,
        dateTime,
        totalPrice,
        totalDurationMinutes,
        status,
        notes,
        statusReason,
      ];
}
