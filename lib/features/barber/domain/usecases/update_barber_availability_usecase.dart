import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class UpdateBarberAvailabilityUseCase {
  const UpdateBarberAvailabilityUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call({
    required String barberId,
    required bool isAvailableToday,
  }) {
    return _repository.updateBarberAvailability(
      barberId: barberId,
      isAvailableToday: isAvailableToday,
    );
  }
}
