import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/errors/failures.dart';
import '../../domain/usecases/get_customer_home_data_usecase.dart';
import 'customer_home_event.dart';
import 'customer_home_state.dart';

class CustomerHomeBloc extends Bloc<CustomerHomeEvent, CustomerHomeState> {
  CustomerHomeBloc({
    required GetCustomerHomeDataUseCase getCustomerHomeDataUseCase,
    CustomerHomeState initialState = const CustomerHomeInitial(),
  })  : _getCustomerHomeDataUseCase = getCustomerHomeDataUseCase,
        super(initialState) {
    on<CustomerHomeLoadRequested>(_onLoadRequested);
    on<CustomerHomeRefreshRequested>(_onRefreshRequested);
  }

  final GetCustomerHomeDataUseCase _getCustomerHomeDataUseCase;

  Future<void> _onLoadRequested(
    CustomerHomeLoadRequested event,
    Emitter<CustomerHomeState> emit,
  ) async {
    emit(const CustomerHomeLoading());
    await _fetchData(event.customerId, emit);
  }

  Future<void> _onRefreshRequested(
    CustomerHomeRefreshRequested event,
    Emitter<CustomerHomeState> emit,
  ) async {
    await _fetchData(event.customerId, emit);
  }

  Future<void> _fetchData(
    String customerId,
    Emitter<CustomerHomeState> emit,
  ) async {
    try {
      final homeData = await _getCustomerHomeDataUseCase(customerId);
      emit(CustomerHomeLoaded(
        services: homeData.services,
        barbers: homeData.barbers,
        activeBooking: homeData.activeBooking,
      ));
    } on Failure catch (f) {
      emit(CustomerHomeFailure(message: f.message, code: f.code));
    } catch (e) {
      emit(CustomerHomeFailure(message: e.toString()));
    }
  }
}
