import 'package:equatable/equatable.dart';

import 'exceptions.dart';

abstract class Failure extends Equatable implements Exception {
  const Failure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({
    super.message = 'Invalid phone number or password.',
    super.code = 'wrong-password',
  });
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure({
    super.message = 'The password provided is too weak.',
    super.code = 'weak-password',
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network error occurred. Please check your connection.',
    super.code = 'network-request-failed',
  });
}

class RoleMismatchFailure extends AuthFailure implements RoleMismatchException {
  const RoleMismatchFailure({
    required this.expectedRole,
    required this.actualRole,
    String? message,
  }) : super(
          message: message ??
              'Selected role ($expectedRole) does not match registered account role ($actualRole).',
          code: 'role-mismatch',
        );

  @override
  final String expectedRole;

  @override
  final String actualRole;

  @override
  List<Object?> get props => [expectedRole, actualRole, message, code];
}
