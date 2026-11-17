import 'package:equatable/equatable.dart';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';

abstract class OwnerDashboardState extends Equatable {
  const OwnerDashboardState();

  bool get isInitial => this is OwnerDashboardInitial;
  bool get isLoading => this is OwnerDashboardLoading;
  bool get isLoaded => this is OwnerDashboardLoaded;

  @override
  List<Object?> get props => [];
}

class OwnerDashboardInitial extends OwnerDashboardState {
  const OwnerDashboardInitial();
}

class OwnerDashboardLoading extends OwnerDashboardState {
  const OwnerDashboardLoading();
}

class OwnerDashboardLoaded extends OwnerDashboardState {
  const OwnerDashboardLoaded({
    required this.services,
    required this.barbers,
    required this.allBookings,
    required this.totalShopRevenue,
    required this.activeBookingsCount,
    this.isSubmittingAction = false,
    this.actionError,
  });

  final List<ServiceEntity> services;
  final List<BarberEntity> barbers;
  final List<BookingEntity> allBookings;
  final double totalShopRevenue;
  final int activeBookingsCount;
  final bool isSubmittingAction;
  final Failure? actionError;

  OwnerDashboardLoaded copyWith({
    List<ServiceEntity>? services,
    List<BarberEntity>? barbers,
    List<BookingEntity>? allBookings,
    double? totalShopRevenue,
    int? activeBookingsCount,
    bool? isSubmittingAction,
    Failure? actionError,
    bool clearActionError = false,
  }) {
    return OwnerDashboardLoaded(
      services: services ?? this.services,
      barbers: barbers ?? this.barbers,
      allBookings: allBookings ?? this.allBookings,
      totalShopRevenue: totalShopRevenue ?? this.totalShopRevenue,
      activeBookingsCount: activeBookingsCount ?? this.activeBookingsCount,
      isSubmittingAction: isSubmittingAction ?? this.isSubmittingAction,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        services,
        barbers,
        allBookings,
        totalShopRevenue,
        activeBookingsCount,
        isSubmittingAction,
        actionError,
      ];
}

class OwnerDashboardFailure extends OwnerDashboardState {
  const OwnerDashboardFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
