import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

class AuthenticateUserUseCase {
  const AuthenticateUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) {
    return _repository.authenticateWithPhone(
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      selectedRole: selectedRole,
    );
  }
}
