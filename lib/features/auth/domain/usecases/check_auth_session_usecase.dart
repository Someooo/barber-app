import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckAuthSessionUseCase {
  const CheckAuthSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() {
    return _repository.getCurrentUserSession();
  }
}
