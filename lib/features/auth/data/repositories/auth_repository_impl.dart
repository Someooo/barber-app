import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) async {
    try {
      return await _remoteDataSource.authenticateWithPhone(
        fullName: fullName,
        phoneNumber: phoneNumber,
        password: password,
        selectedRole: selectedRole,
      );
    } on RoleMismatchException catch (e) {
      throw RoleMismatchFailure(
        expectedRole: e.expectedRole,
        actualRole: e.actualRole,
        message: e.message,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on Failure {
      rethrow;
    } on AppException catch (e) {
      throw AuthFailure(message: e.message, code: e.code);
    } on FormatException catch (e) {
      throw AuthFailure(message: e.message, code: 'invalid-format');
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUserSession() async {
    try {
      return await _remoteDataSource.getCurrentUserSession();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on Failure {
      rethrow;
    } on AppException catch (e) {
      throw AuthFailure(message: e.message, code: e.code);
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on Failure {
      rethrow;
    } on AppException catch (e) {
      throw AuthFailure(message: e.message, code: e.code);
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  Failure _mapFirebaseAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'wrong-password' ||
      'invalid-credential' ||
      'user-not-found' =>
        InvalidCredentialsFailure(
          message: e.message ?? 'Invalid phone number or password.',
          code: e.code,
        ),
      'weak-password' => WeakPasswordFailure(
          message: e.message ?? 'The password provided is too weak.',
          code: e.code,
        ),
      'network-request-failed' => NetworkFailure(
          message:
              e.message ?? 'Network error occurred. Please check connection.',
          code: e.code,
        ),
      _ => AuthFailure(
          message: e.message ?? 'Authentication failed.',
          code: e.code,
        ),
    };
  }
}
