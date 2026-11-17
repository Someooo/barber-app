import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/errors/failures.dart';
import '../../domain/entities/barber_entity.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/usecases/create_instant_booking_usecase.dart';
import '../../domain/usecases/get_available_time_slots_usecase.dart';
import '../../domain/usecases/get_customer_home_data_usecase.dart';
import 'booking_flow_event.dart';
import 'booking_flow_state.dart';

class BookingFlowBloc extends Bloc<BookingFlowEvent, BookingFlowState> {
  BookingFlowBloc({
    required GetAvailableTimeSlotsUseCase getAvailableTimeSlotsUseCase,
    required CreateInstantBookingUseCase createInstantBookingUseCase,
    GetCustomerHomeDataUseCase? getCustomerHomeDataUseCase,
    BookingFlowState? initialState,
  })  : _getAvailableTimeSlotsUseCase = getAvailableTimeSlotsUseCase,
        _createInstantBookingUseCase = createInstantBookingUseCase,
        _getCustomerHomeDataUseCase = getCustomerHomeDataUseCase,
        super(initialState ?? BookingFlowState.initial()) {
    on<BookingFlowInitialized>(_onInitialized);
    on<BookingServiceToggled>(_onServiceToggled);
    on<BookingBarberSelected>(_onBarberSelected);
    on<BookingDateSelected>(_onDateSelected);
    on<BookingTimeSlotSelected>(_onTimeSlotSelected);
    on<BookingSubmitted>(_onSubmitted);
  }

  final GetAvailableTimeSlotsUseCase _getAvailableTimeSlotsUseCase;
  final CreateInstantBookingUseCase _createInstantBookingUseCase;
  final GetCustomerHomeDataUseCase? _getCustomerHomeDataUseCase;

  Future<void> _onInitialized(
    BookingFlowInitialized event,
    Emitter<BookingFlowState> emit,
  ) async {
    List<ServiceEntity> services = event.availableServices ??
        (state.availableServices.isNotEmpty ? state.availableServices : []);
    List<BarberEntity> barbers = event.availableBarbers ??
        (state.availableBarbers.isNotEmpty ? state.availableBarbers : []);

    if ((services.isEmpty || barbers.isEmpty) &&
        _getCustomerHomeDataUseCase != null) {
      try {
        final homeData = await _getCustomerHomeDataUseCase('initial_fetch');
        if (services.isEmpty) services = homeData.services;
        if (barbers.isEmpty) barbers = homeData.barbers;
      } catch (e) {
        final failure = e is Failure
            ? e
            : ServerFailure(message: e.toString(), code: 'fetch-failed');
        emit(state.copyWith(failure: () => failure));
      }
    }

    final selectedIds = <String>{};
    if (event.preselectedServiceId != null) {
      final exists = services.any((s) => s.id == event.preselectedServiceId);
      if (exists) {
        selectedIds.add(event.preselectedServiceId!);
      }
    } else if (state.selectedServiceIds.isNotEmpty) {
      selectedIds.addAll(state.selectedServiceIds);
    }

    final double price = services
        .where((s) => selectedIds.contains(s.id))
        .fold(0.0, (acc, s) => acc + s.price);
    final int duration = services
        .where((s) => selectedIds.contains(s.id))
        .fold(0, (acc, s) => acc + s.durationMinutes);

    BarberEntity? selectedBarber = state.selectedBarber;
    if (event.preselectedBarberId != null) {
      final match = barbers.where((b) => b.id == event.preselectedBarberId);
      if (match.isNotEmpty) {
        selectedBarber = match.first;
      }
    }

    emit(state.copyWith(
      availableServices: services,
      availableBarbers: barbers,
      selectedServiceIds: selectedIds,
      totalPrice: price,
      totalDurationMinutes: duration,
      selectedBarber: () => selectedBarber,
    ));

    if (selectedBarber != null) {
      await _fetchSlots(
        emit: emit,
        barber: selectedBarber,
        date: state.selectedDate,
        durationMinutes: duration,
      );
    }
  }

  Future<void> _onServiceToggled(
    BookingServiceToggled event,
    Emitter<BookingFlowState> emit,
  ) async {
    final updatedIds = Set<String>.from(state.selectedServiceIds);
    if (updatedIds.contains(event.serviceId)) {
      updatedIds.remove(event.serviceId);
    } else {
      updatedIds.add(event.serviceId);
    }

    final price = state.availableServices
        .where((s) => updatedIds.contains(s.id))
        .fold(0.0, (acc, s) => acc + s.price);
    final duration = state.availableServices
        .where((s) => updatedIds.contains(s.id))
        .fold(0, (acc, s) => acc + s.durationMinutes);

    emit(state.copyWith(
      selectedServiceIds: updatedIds,
      totalPrice: price,
      totalDurationMinutes: duration,
    ));

    if (state.selectedBarber != null) {
      await _fetchSlots(
        emit: emit,
        barber: state.selectedBarber!,
        date: state.selectedDate,
        durationMinutes: duration,
      );
    }
  }

  Future<void> _onBarberSelected(
    BookingBarberSelected event,
    Emitter<BookingFlowState> emit,
  ) async {
    emit(state.copyWith(
      selectedBarber: () => event.barber,
      selectedSlot: () => null,
      isLoadingSlots: true,
      failure: () => null,
    ));

    await _fetchSlots(
      emit: emit,
      barber: event.barber,
      date: state.selectedDate,
      durationMinutes: state.totalDurationMinutes,
    );
  }

  Future<void> _onDateSelected(
    BookingDateSelected event,
    Emitter<BookingFlowState> emit,
  ) async {
    final normalized =
        DateTime(event.date.year, event.date.month, event.date.day);
    emit(state.copyWith(
      selectedDate: normalized,
      selectedSlot: () => null,
    ));

    if (state.selectedBarber != null) {
      emit(state.copyWith(isLoadingSlots: true));
      await _fetchSlots(
        emit: emit,
        barber: state.selectedBarber!,
        date: normalized,
        durationMinutes: state.totalDurationMinutes,
      );
    }
  }

  void _onTimeSlotSelected(
    BookingTimeSlotSelected event,
    Emitter<BookingFlowState> emit,
  ) {
    emit(state.copyWith(selectedSlot: () => event.slot));
  }

  Future<void> _onSubmitted(
    BookingSubmitted event,
    Emitter<BookingFlowState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(
      isSubmitting: true,
      failure: () => null,
    ));

    try {
      final booking = await _createInstantBookingUseCase(
        customerId: event.customerId,
        customerName: event.customerName,
        barberId: state.selectedBarber!.id,
        barberName: state.selectedBarber!.name,
        services: state.selectedServices,
        dateTime: state.selectedSlot!,
        totalPrice: state.totalPrice,
        totalDurationMinutes: state.totalDurationMinutes,
        notes: event.notes,
      );

      emit(state.copyWith(
        isSubmitting: false,
        createdBooking: () => booking,
      ));
    } catch (e) {
      final failure = e is Failure
          ? e
          : ServerFailure(message: e.toString(), code: 'booking-create-failed');
      emit(state.copyWith(
        isSubmitting: false,
        failure: () => failure,
      ));
    }
  }

  Future<void> _fetchSlots({
    required Emitter<BookingFlowState> emit,
    required BarberEntity barber,
    required DateTime date,
    required int durationMinutes,
  }) async {
    emit(state.copyWith(isLoadingSlots: true, failure: () => null));
    try {
      final effectiveDuration = durationMinutes > 0 ? durationMinutes : 30;
      final slots = await _getAvailableTimeSlotsUseCase(
        barberId: barber.id,
        date: date,
        durationMinutes: effectiveDuration,
      );

      final stillValidSlot = state.selectedSlot != null &&
          slots.any((s) => s.isAtSameMomentAs(state.selectedSlot!));

      emit(state.copyWith(
        availableSlots: slots,
        isLoadingSlots: false,
        selectedSlot: stillValidSlot ? () => state.selectedSlot : () => null,
      ));
    } catch (e) {
      final failure = e is Failure
          ? e
          : ServerFailure(message: e.toString(), code: 'slots-fetch-failed');
      emit(state.copyWith(
        isLoadingSlots: false,
        failure: () => failure,
      ));
    }
  }
}
