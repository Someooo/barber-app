import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class BarberCancelBookingUseCase {
  const BarberCancelBookingUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call({
    required String bookingId,
    required String reason,
  }) {
    return _repository.cancelBooking(
      bookingId: bookingId,
      reason: reason,
    );
  }
}
