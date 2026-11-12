import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  bool get isSubmitting => this is AuthLoading;

  Failure? get activeFailure => switch (this) {
        AuthFailureState(:final failure) => failure,
        _ => null,
      };

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthCheckingSession extends AuthState {
  const AuthCheckingSession();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class AuthFailureState extends AuthState {
  const AuthFailureState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
