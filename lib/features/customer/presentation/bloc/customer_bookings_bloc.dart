import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/errors/failures.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/get_customer_bookings_usecase.dart';
import 'customer_bookings_event.dart';
import 'customer_bookings_state.dart';

class CustomerBookingsBloc
    extends Bloc<CustomerBookingsEvent, CustomerBookingsState> {
  CustomerBookingsBloc({
    required GetCustomerBookingsUseCase getCustomerBookingsUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
    CustomerBookingsState? initialState,
  })  : _getCustomerBookingsUseCase = getCustomerBookingsUseCase,
        _cancelBookingUseCase = cancelBookingUseCase,
        super(initialState ?? const CustomerBookingsInitial()) {
    on<CustomerBookingsLoadRequested>(_onLoadRequested);
    on<CustomerBookingsTabChanged>(_onTabChanged);
    on<CustomerBookingCancelRequested>(_onCancelRequested);
  }

  final GetCustomerBookingsUseCase _getCustomerBookingsUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;

  (List<BookingEntity>, List<BookingEntity>) _partitionBookings(
    List<BookingEntity> bookings,
  ) {
    final upcoming = bookings.where((b) {
      return b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.rescheduled;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final history = bookings.where((b) {
      return b.status == BookingStatus.completed ||
          b.status == BookingStatus.cancelled;
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return (upcoming, history);
  }

  Future<void> _onLoadRequested(
    CustomerBookingsLoadRequested event,
    Emitter<CustomerBookingsState> emit,
  ) async {
    final currentTabIndex = state is CustomerBookingsLoaded
        ? (state as CustomerBookingsLoaded).selectedTabIndex
        : 0;

    if (state is! CustomerBookingsLoaded) {
      emit(const CustomerBookingsLoading());
    }

    try {
      final bookings = await _getCustomerBookingsUseCase(event.customerId);
      final (upcoming, history) = _partitionBookings(bookings);

      emit(CustomerBookingsLoaded(
        upcomingBookings: upcoming,
        historyBookings: history,
        selectedTabIndex: currentTabIndex,
      ));
    } catch (e) {
      final failure = e is Failure
          ? e
          : ServerFailure(
              message: e.toString(),
              code: 'bookings-load-failed',
            );
      emit(CustomerBookingsFailure(
        message: failure.message,
        code: failure.code,
      ));
    }
  }

  void _onTabChanged(
    CustomerBookingsTabChanged event,
    Emitter<CustomerBookingsState> emit,
  ) {
    if (state is CustomerBookingsLoaded) {
      final currentState = state as CustomerBookingsLoaded;
      emit(currentState.copyWith(selectedTabIndex: event.tabIndex));
    }
  }

  Future<void> _onCancelRequested(
    CustomerBookingCancelRequested event,
    Emitter<CustomerBookingsState> emit,
  ) async {
    final currentTabIndex = state is CustomerBookingsLoaded
        ? (state as CustomerBookingsLoaded).selectedTabIndex
        : 0;

    if (state is CustomerBookingsLoaded) {
      final currentState = state as CustomerBookingsLoaded;
      emit(currentState.copyWith(
        cancellingBookingId: () => event.bookingId,
      ));
    }

    try {
      await _cancelBookingUseCase(
        bookingId: event.bookingId,
        reason: event.reason,
      );

      final bookings = await _getCustomerBookingsUseCase(event.customerId);
      final (upcoming, history) = _partitionBookings(bookings);

      emit(CustomerBookingsLoaded(
        upcomingBookings: upcoming,
        historyBookings: history,
        selectedTabIndex: currentTabIndex,
        cancellingBookingId: null,
      ));
    } catch (e) {
      final failure = e is Failure
          ? e
          : ServerFailure(
              message: e.toString(),
              code: 'cancel-failed',
            );
      emit(CustomerBookingsFailure(
        message: failure.message,
        code: failure.code,
      ));
    }
  }
}
