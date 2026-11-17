import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class AddBarberUseCase {
  const AddBarberUseCase(this._repository);

  final CustomerRepository _repository;

  Future<BarberEntity> call(BarberEntity barber) {
    return _repository.addBarber(barber);
  }
}
