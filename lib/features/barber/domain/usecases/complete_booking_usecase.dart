import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class CompleteBookingUseCase {
  const CompleteBookingUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call(String bookingId) {
    return _repository.completeBooking(bookingId);
  }
}
