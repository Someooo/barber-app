import '../entities/booking_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomerBookingsUseCase {
  const GetCustomerBookingsUseCase(this._repository);

  final CustomerRepository _repository;

  Future<List<BookingEntity>> call(String customerId) {
    return _repository.getCustomerBookings(customerId);
  }
}
