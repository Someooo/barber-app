import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/authenticate_user_usecase.dart';
import '../../domain/usecases/check_auth_session_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthenticateUserUseCase authenticateUserUseCase,
    required CheckAuthSessionUseCase checkAuthSessionUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _authenticateUserUseCase = authenticateUserUseCase,
        _checkAuthSessionUseCase = checkAuthSessionUseCase,
        _signOutUseCase = signOutUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSubmitRequested>(_onAuthSubmitRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  final AuthenticateUserUseCase _authenticateUserUseCase;
  final CheckAuthSessionUseCase _checkAuthSessionUseCase;
  final SignOutUseCase _signOutUseCase;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCheckingSession());
    try {
      final user = await _checkAuthSessionUseCase();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onAuthSubmitRequested(
    AuthSubmitRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authenticateUserUseCase(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        password: event.password,
        selectedRole: event.selectedRole,
      );
      emit(Authenticated(user));
    } on Failure catch (failure) {
      emit(AuthFailureState(failure));
    } on RoleMismatchException catch (e) {
      emit(
        AuthFailureState(
          RoleMismatchFailure(
            expectedRole: e.expectedRole,
            actualRole: e.actualRole,
            message: e.message,
          ),
        ),
      );
    } on AppException catch (e) {
      emit(AuthFailureState(AuthFailure(message: e.message, code: e.code)));
    } catch (e) {
      emit(AuthFailureState(AuthFailure(message: e.toString())));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _signOutUseCase();
      emit(const Unauthenticated());
    } on Failure catch (failure) {
      emit(AuthFailureState(failure));
    } on AppException catch (e) {
      emit(AuthFailureState(AuthFailure(message: e.message, code: e.code)));
    } catch (e) {
      emit(AuthFailureState(AuthFailure(message: e.toString())));
    }
  }
}
