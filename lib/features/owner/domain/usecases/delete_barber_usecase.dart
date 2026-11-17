import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class DeleteBarberUseCase {
  const DeleteBarberUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call(String barberId) {
    return _repository.deleteBarber(barberId);
  }
}
