import 'package:equatable/equatable.dart';

import '../../domain/entities/user_role.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class AuthSubmitRequested extends AuthEvent {
  const AuthSubmitRequested({
    required this.fullName,
    required this.phoneNumber,
    required this.password,
    required this.selectedRole,
  });

  final String fullName;
  final String phoneNumber;
  final String password;
  final UserRole selectedRole;

  @override
  List<Object?> get props => [fullName, phoneNumber, password, selectedRole];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
