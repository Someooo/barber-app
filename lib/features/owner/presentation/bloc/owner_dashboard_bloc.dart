import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/owner/domain/usecases/add_barber_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/add_service_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/delete_barber_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/delete_service_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/get_owner_overview_usecase.dart';
import 'owner_dashboard_event.dart';
import 'owner_dashboard_state.dart';

class OwnerDashboardBloc
    extends Bloc<OwnerDashboardEvent, OwnerDashboardState> {
  OwnerDashboardBloc({
    required GetOwnerOverviewUseCase getOwnerOverviewUseCase,
    required AddServiceUseCase addServiceUseCase,
    required DeleteServiceUseCase deleteServiceUseCase,
    required AddBarberUseCase addBarberUseCase,
    required DeleteBarberUseCase deleteBarberUseCase,
    OwnerDashboardState? initialState,
  })  : _getOwnerOverviewUseCase = getOwnerOverviewUseCase,
        _addServiceUseCase = addServiceUseCase,
        _deleteServiceUseCase = deleteServiceUseCase,
        _addBarberUseCase = addBarberUseCase,
        _deleteBarberUseCase = deleteBarberUseCase,
        super(initialState ?? const OwnerDashboardInitial()) {
    on<OwnerDashboardLoadRequested>(_onLoadRequested);
    on<OwnerServiceAdded>(_onServiceAdded);
    on<OwnerServiceDeleted>(_onServiceDeleted);
    on<OwnerBarberAdded>(_onBarberAdded);
    on<OwnerBarberDeleted>(_onBarberDeleted);
  }

  final GetOwnerOverviewUseCase _getOwnerOverviewUseCase;
  final AddServiceUseCase _addServiceUseCase;
  final DeleteServiceUseCase _deleteServiceUseCase;
  final AddBarberUseCase _addBarberUseCase;
  final DeleteBarberUseCase _deleteBarberUseCase;

  Future<void> _onLoadRequested(
    OwnerDashboardLoadRequested event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    if (state is! OwnerDashboardLoaded) {
      emit(const OwnerDashboardLoading());
    }

    try {
      final overview = await _getOwnerOverviewUseCase();
      emit(_buildLoaded(overview));
    } on Failure catch (failure) {
      emit(OwnerDashboardFailure(failure));
    } catch (e) {
      emit(OwnerDashboardFailure(ServerFailure(message: e.toString())));
    }
  }

  Future<void> _onServiceAdded(
    OwnerServiceAdded event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    await _runMutation(emit, () async {
      await _addServiceUseCase(ServiceEntity(
        id: '',
        nameEn: event.nameEn.trim(),
        nameAr: event.nameAr.trim(),
        descriptionEn: event.descriptionEn.trim(),
        descriptionAr: event.descriptionAr.trim(),
        price: event.price,
        durationMinutes: event.durationMinutes,
        iconName: event.iconName,
      ));
    });
  }

  Future<void> _onServiceDeleted(
    OwnerServiceDeleted event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    await _runMutation(emit, () => _deleteServiceUseCase(event.serviceId));
  }

  Future<void> _onBarberAdded(
    OwnerBarberAdded event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    await _runMutation(emit, () async {
      await _addBarberUseCase(BarberEntity(
        id: '',
        name: event.name.trim(),
        specialtyEn: event.specialtyEn.trim(),
        specialtyAr: event.specialtyAr.trim(),
        rating: 5.0,
        experienceYears: event.experienceYears,
        isAvailableToday: true,
        imageUrl: event.imageUrl?.trim().isNotEmpty == true
            ? event.imageUrl!.trim()
            : null,
      ));
    });
  }

  Future<void> _onBarberDeleted(
    OwnerBarberDeleted event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    await _runMutation(emit, () => _deleteBarberUseCase(event.barberId));
  }

  Future<void> _runMutation(
    Emitter<OwnerDashboardState> emit,
    Future<void> Function() mutation,
  ) async {
    final current = state;
    if (current is! OwnerDashboardLoaded) return;

    emit(current.copyWith(
      isSubmittingAction: true,
      clearActionError: true,
    ));

    try {
      await mutation();
      final overview = await _getOwnerOverviewUseCase();
      emit(_buildLoaded(overview));
    } on Failure catch (failure) {
      emit(current.copyWith(
        isSubmittingAction: false,
        actionError: failure,
      ));
    } catch (e) {
      emit(current.copyWith(
        isSubmittingAction: false,
        actionError: ServerFailure(message: e.toString()),
      ));
    }
  }

  OwnerDashboardLoaded _buildLoaded(OwnerOverviewData overview) {
    final activeCount = overview.allBookings
        .where((b) =>
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.rescheduled)
        .length;

    final totalRevenue = overview.allBookings
        .where((b) => b.status != BookingStatus.cancelled)
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);

    return OwnerDashboardLoaded(
      services: overview.services,
      barbers: overview.barbers,
      allBookings: overview.allBookings,
      totalShopRevenue: totalRevenue,
      activeBookingsCount: activeCount,
    );
  }
}
