import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class RescheduleBookingUseCase {
  const RescheduleBookingUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call({
    required String bookingId,
    required DateTime newDateTime,
    required String reason,
  }) {
    return _repository.rescheduleBooking(
      bookingId: bookingId,
      newDateTime: newDateTime,
      reason: reason,
    );
  }
}
