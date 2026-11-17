import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class DeleteServiceUseCase {
  const DeleteServiceUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call(String serviceId) {
    return _repository.deleteService(serviceId);
  }
}
