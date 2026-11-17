import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';

class EnsureBarberProfileUseCase {
  const EnsureBarberProfileUseCase(this._repository);

  final CustomerRepository _repository;

  Future<BarberEntity> call({
    required String barberId,
    required String name,
  }) {
    return _repository.ensureBarberProfile(
      barberId: barberId,
      name: name,
    );
  }
}
