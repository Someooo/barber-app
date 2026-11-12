import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/core/router/app_router.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barber_app/features/auth/domain/usecases/authenticate_user_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/check_auth_session_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  UserEntity? sessionUser;
  Object? sessionError;
  Future<UserEntity> Function({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  })? onAuthenticate;
  int signOutCalls = 0;

  @override
  Future<UserEntity> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) async {
    if (onAuthenticate != null) {
      return onAuthenticate!(
        fullName: fullName,
        phoneNumber: phoneNumber,
        password: password,
        selectedRole: selectedRole,
      );
    }
    throw UnimplementedError('onAuthenticate not configured');
  }

  @override
  Future<UserEntity?> getCurrentUserSession() async {
    if (sessionError != null) {
      throw sessionError!;
    }
    return sessionUser;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    sessionUser = null;
  }
}

void main() {
  late _FakeAuthRepository fakeRepository;
  late AuthenticateUserUseCase authenticateUserUseCase;
  late CheckAuthSessionUseCase checkAuthSessionUseCase;
  late SignOutUseCase signOutUseCase;
  late AuthBloc authBloc;

  const barberUser = UserEntity(
    uid: 'barber-101',
    fullName: 'Sami Al-Harbi',
    phoneNumber: '0501234567',
    role: UserRole.barber,
  );

  const customerUser = UserEntity(
    uid: 'customer-202',
    fullName: 'Tariq Saleh',
    phoneNumber: '0559876543',
    role: UserRole.customer,
  );

  setUp(() {
    fakeRepository = _FakeAuthRepository();
    authenticateUserUseCase = AuthenticateUserUseCase(fakeRepository);
    checkAuthSessionUseCase = CheckAuthSessionUseCase(fakeRepository);
    signOutUseCase = SignOutUseCase(fakeRepository);
    authBloc = AuthBloc(
      authenticateUserUseCase: authenticateUserUseCase,
      checkAuthSessionUseCase: checkAuthSessionUseCase,
      signOutUseCase: signOutUseCase,
    );
  });

  tearDown(() async {
    await authBloc.close();
  });

  group('AuthBloc State Transitions', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    test(
        'AuthCheckRequested emits [AuthCheckingSession, Authenticated] when session is valid',
        () async {
      fakeRepository.sessionUser = barberUser;

      final expectation = expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthCheckingSession(),
          const Authenticated(barberUser),
        ]),
      );

      authBloc.add(const AuthCheckRequested());
      await expectation;
      expect(authBloc.state, const Authenticated(barberUser));
    });

    test(
        'AuthCheckRequested emits [AuthCheckingSession, Unauthenticated] when session is null or expired',
        () async {
      fakeRepository.sessionUser = null;

      final expectation = expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthCheckingSession(),
          const Unauthenticated(),
        ]),
      );

      authBloc.add(const AuthCheckRequested());
      await expectation;
      expect(authBloc.state, const Unauthenticated());
    });

    test(
        'AuthSubmitRequested emits [AuthLoading, Authenticated] on successful authentication',
        () async {
      fakeRepository.onAuthenticate = ({
        required fullName,
        required phoneNumber,
        required password,
        required selectedRole,
      }) async {
        return customerUser;
      };

      final expectation = expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const Authenticated(customerUser),
        ]),
      );

      authBloc.add(
        const AuthSubmitRequested(
          fullName: 'Tariq Saleh',
          phoneNumber: '0559876543',
          password: 'Password123!',
          selectedRole: UserRole.customer,
        ),
      );
      await expectation;
      expect(authBloc.state, const Authenticated(customerUser));
    });

    test(
        'AuthSubmitRequested emits [AuthLoading, AuthFailureState] on RoleMismatchFailure',
        () async {
      const mismatchFailure = RoleMismatchFailure(
        expectedRole: 'customer',
        actualRole: 'barber',
      );
      fakeRepository.onAuthenticate = ({
        required fullName,
        required phoneNumber,
        required password,
        required selectedRole,
      }) async {
        throw mismatchFailure;
      };

      final expectation = expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const AuthFailureState(mismatchFailure),
        ]),
      );

      authBloc.add(
        const AuthSubmitRequested(
          fullName: 'Sami Al-Harbi',
          phoneNumber: '0501234567',
          password: 'Password123!',
          selectedRole: UserRole.customer,
        ),
      );
      await expectation;
      expect(authBloc.state, const AuthFailureState(mismatchFailure));
    });

    test('AuthSignOutRequested calls signOut and emits [Unauthenticated]',
        () async {
      fakeRepository.sessionUser = barberUser;
      authBloc.add(const AuthCheckRequested());
      await expectLater(
        authBloc.stream,
        emitsThrough(const Authenticated(barberUser)),
      );

      final signOutExpectation = expectLater(
        authBloc.stream,
        emits(const Unauthenticated()),
      );

      authBloc.add(const AuthSignOutRequested());
      await signOutExpectation;
      expect(fakeRepository.signOutCalls, 1);
      expect(authBloc.state, const Unauthenticated());
    });
  });

  group('GoRouter Redirect & Cross-Role Guard', () {
    test('does not redirect while AuthInitial or AuthCheckingSession', () {
      expect(
        evaluateAuthRedirect(
          authState: const AuthInitial(),
          matchedLocation: AppRoutes.welcome,
        ),
        isNull,
      );
      expect(
        evaluateAuthRedirect(
          authState: const AuthCheckingSession(),
          matchedLocation: AppRoutes.barberDashboard,
        ),
        isNull,
      );
    });

    test(
        'redirects Unauthenticated and AuthFailureState away from protected routes to /',
        () {
      expect(
        evaluateAuthRedirect(
          authState: const Unauthenticated(),
          matchedLocation: AppRoutes.barberDashboard,
        ),
        AppRoutes.welcome,
      );
      expect(
        evaluateAuthRedirect(
          authState: const AuthFailureState(InvalidCredentialsFailure()),
          matchedLocation: AppRoutes.customerHome,
        ),
        AppRoutes.welcome,
      );
      expect(
        evaluateAuthRedirect(
          authState: const Unauthenticated(),
          matchedLocation: AppRoutes.login,
        ),
        isNull,
      );
    });

    test(
        'redirects Authenticated users from public routes to role-specific home',
        () {
      expect(
        evaluateAuthRedirect(
          authState: const Authenticated(barberUser),
          matchedLocation: AppRoutes.welcome,
        ),
        AppRoutes.barberDashboard,
      );
      expect(
        evaluateAuthRedirect(
          authState: const Authenticated(customerUser),
          matchedLocation: AppRoutes.login,
        ),
        AppRoutes.customerHome,
      );
      expect(
        evaluateAuthRedirect(
          authState: const Authenticated(customerUser),
          matchedLocation: AppRoutes.register,
        ),
        AppRoutes.customerHome,
      );
    });

    test('blocks cross-role navigation between /barber/* and /customer/*', () {
      expect(
        evaluateAuthRedirect(
          authState: const Authenticated(customerUser),
          matchedLocation: AppRoutes.barberDashboard,
        ),
        AppRoutes.customerHome,
      );
      expect(
        evaluateAuthRedirect(
          authState: const Authenticated(barberUser),
          matchedLocation: AppRoutes.customerHome,
        ),
        AppRoutes.barberDashboard,
      );
    });

    testWidgets(
        'Active Barber session bypasses Welcome screen and lands on Barber Dashboard',
        (WidgetTester tester) async {
      fakeRepository.sessionUser = barberUser;
      final testBloc = AuthBloc(
        authenticateUserUseCase: authenticateUserUseCase,
        checkAuthSessionUseCase: checkAuthSessionUseCase,
        signOutUseCase: signOutUseCase,
      );
      addTearDown(testBloc.close);

      await tester.pumpWidget(BarberSyncApp(authBloc: testBloc));
      await tester.pumpAndSettle();

      expect(find.text('Barber Dashboard'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });
  });
}
