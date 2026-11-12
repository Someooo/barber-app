import '../entities/user_entity.dart';
import '../entities/user_role.dart';

abstract class AuthRepository {
  Future<UserEntity> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  });

  Future<UserEntity?> getCurrentUserSession();

  Future<void> signOut();
}
