import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class AddServiceUseCase {
  const AddServiceUseCase(this._repository);

  final CustomerRepository _repository;

  Future<ServiceEntity> call(ServiceEntity service) {
    return _repository.addService(service);
  }
}
