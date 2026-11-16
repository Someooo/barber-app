import '../repositories/customer_repository.dart';

class CancelBookingUseCase {
  const CancelBookingUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call({
    required String bookingId,
    String? reason,
  }) {
    return _repository.cancelBooking(
      bookingId: bookingId,
      reason: reason,
    );
  }
}
