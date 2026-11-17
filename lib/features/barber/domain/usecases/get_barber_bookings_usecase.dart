import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class GetBarberBookingsUseCase {
  const GetBarberBookingsUseCase(this._repository);

  final CustomerRepository _repository;

  Future<List<BookingEntity>> call(String barberId) {
    return _repository.getBarberBookings(barberId);
  }
}
