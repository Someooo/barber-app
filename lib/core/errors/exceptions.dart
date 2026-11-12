class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
  });
}

class RoleMismatchException extends AuthException {
  const RoleMismatchException({
    required this.expectedRole,
    required this.actualRole,
    String? message,
  }) : super(
          message: message ??
              'Selected role ($expectedRole) does not match registered account role ($actualRole).',
          code: 'role-mismatch',
        );

  final String expectedRole;
  final String actualRole;

  @override
  String toString() =>
      'RoleMismatchException(expectedRole: $expectedRole, actualRole: $actualRole, message: $message)';
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException({
    super.message = 'Invalid phone number or password.',
    super.code = 'wrong-password',
  });
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException({
    super.message = 'The password provided is too weak.',
    super.code = 'weak-password',
  });
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network request failed. Please check your connection.',
    super.code = 'network-request-failed',
  });
}
