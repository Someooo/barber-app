import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:barber_app/core/errors/failures.dart';
import '../../domain/entities/barber_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/service_entity.dart';

@immutable
class BookingFlowState extends Equatable {
  const BookingFlowState({
    this.availableServices = const [],
    this.availableBarbers = const [],
    this.selectedServiceIds = const {},
    this.selectedBarber,
    required this.selectedDate,
    this.availableSlots = const [],
    this.isLoadingSlots = false,
    this.selectedSlot,
    this.totalPrice = 0.0,
    this.totalDurationMinutes = 0,
    this.isSubmitting = false,
    this.createdBooking,
    this.failure,
  });

  factory BookingFlowState.initial([DateTime? initialDate]) {
    final now = initialDate ?? DateTime.now();
    return BookingFlowState(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  final List<ServiceEntity> availableServices;
  final List<BarberEntity> availableBarbers;
  final Set<String> selectedServiceIds;
  final BarberEntity? selectedBarber;
  final DateTime selectedDate;
  final List<DateTime> availableSlots;
  final bool isLoadingSlots;
  final DateTime? selectedSlot;
  final double totalPrice;
  final int totalDurationMinutes;
  final bool isSubmitting;
  final BookingEntity? createdBooking;
  final Failure? failure;

  bool get canSubmit =>
      selectedServiceIds.isNotEmpty &&
      selectedBarber != null &&
      selectedSlot != null &&
      !isSubmitting;

  bool get hasSlots => availableSlots.isNotEmpty;

  List<ServiceEntity> get selectedServices => availableServices
      .where((s) => selectedServiceIds.contains(s.id))
      .toList();

  bool isServiceSelected(String serviceId) =>
      selectedServiceIds.contains(serviceId);

  bool isSlotSelected(DateTime slot) =>
      selectedSlot != null && selectedSlot!.isAtSameMomentAs(slot);

  bool isDateSelected(DateTime date) =>
      selectedDate.year == date.year &&
      selectedDate.month == date.month &&
      selectedDate.day == date.day;

  BookingFlowState copyWith({
    List<ServiceEntity>? availableServices,
    List<BarberEntity>? availableBarbers,
    Set<String>? selectedServiceIds,
    BarberEntity? Function()? selectedBarber,
    DateTime? selectedDate,
    List<DateTime>? availableSlots,
    bool? isLoadingSlots,
    DateTime? Function()? selectedSlot,
    double? totalPrice,
    int? totalDurationMinutes,
    bool? isSubmitting,
    BookingEntity? Function()? createdBooking,
    Failure? Function()? failure,
  }) {
    return BookingFlowState(
      availableServices: availableServices ?? this.availableServices,
      availableBarbers: availableBarbers ?? this.availableBarbers,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      selectedBarber:
          selectedBarber != null ? selectedBarber() : this.selectedBarber,
      selectedDate: selectedDate ?? this.selectedDate,
      availableSlots: availableSlots ?? this.availableSlots,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      selectedSlot: selectedSlot != null ? selectedSlot() : this.selectedSlot,
      totalPrice: totalPrice ?? this.totalPrice,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdBooking:
          createdBooking != null ? createdBooking() : this.createdBooking,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
        availableServices,
        availableBarbers,
        selectedServiceIds,
        selectedBarber,
        selectedDate,
        availableSlots,
        isLoadingSlots,
        selectedSlot,
        totalPrice,
        totalDurationMinutes,
        isSubmitting,
        createdBooking,
        failure,
      ];
}
