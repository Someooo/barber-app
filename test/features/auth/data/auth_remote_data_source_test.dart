import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:barber_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barber_app/features/auth/domain/usecases/authenticate_user_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/check_auth_session_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeUser implements User {
  _FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.idToken = 'valid-jwt-token',
    this.idTokenError,
  });

  @override
  final String uid;

  @override
  final String? email;

  @override
  String? displayName;

  @override
  String? get phoneNumber => null;

  final String? idToken;
  final FirebaseAuthException? idTokenError;
  String? lastUpdatedDisplayName;

  @override
  Future<void> updateDisplayName(String? displayName) async {
    lastUpdatedDisplayName = displayName;
    this.displayName = displayName;
  }

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    if (idTokenError != null) {
      throw idTokenError!;
    }
    return idToken;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCredential implements UserCredential {
  _FakeUserCredential(this.user);

  @override
  final User? user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseAuth implements FirebaseAuth {
  User? activeUser;
  int signOutCallCount = 0;
  String? lastSignInEmail;
  String? lastSignInPassword;
  String? lastCreatedEmail;
  String? lastCreatedPassword;

  Future<UserCredential> Function(String email, String password)? onSignIn;
  Future<UserCredential> Function(String email, String password)? onCreateUser;

  @override
  User? get currentUser => activeUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (onSignIn != null) {
      return onSignIn!(email, password);
    }
    throw UnimplementedError('onSignIn was not configured');
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastCreatedEmail = email;
    lastCreatedPassword = password;
    if (onCreateUser != null) {
      return onCreateUser!(email, password);
    }
    throw UnimplementedError('onCreateUser was not configured');
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    activeUser = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeFirebaseAuth fakeFirebaseAuth;
  late AuthRemoteDataSourceImpl remoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    fakeFirebaseAuth = _FakeFirebaseAuth();
    remoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: fakeFirebaseAuth,
    );
    repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('Phone-to-Email Identifier Normalization', () {
    test('strips spaces, dashes, and parentheses and appends @barbersync.app',
        () {
      expect(
        AuthRemoteDataSourceImpl.phoneToEmail('+966 50-123-4567'),
        '+966501234567@barbersync.app',
      );
      expect(
        AuthRemoteDataSourceImpl.phoneToEmail('(050) 999 8877'),
        '0509998877@barbersync.app',
      );
    });

    test('throws FormatException when phone number has no digits', () {
      expect(
        () => AuthRemoteDataSourceImpl.phoneToEmail('   ---  '),
        throwsFormatException,
      );
    });
  });

  group('authenticateWithPhone & Role Guard', () {
    test('signs in existing user when selectedRole matches registered role',
        () async {
      final existingUser = _FakeUser(
        uid: 'uid-barber-1',
        email: '0501234567@barbersync.app',
        displayName: 'Sami Al-Harbi|barber',
      );
      fakeFirebaseAuth.onSignIn = (email, password) async {
        return _FakeUserCredential(existingUser);
      };

      final result = await remoteDataSource.authenticateWithPhone(
        fullName: 'Sami Al-Harbi',
        phoneNumber: '050 123-4567',
        password: 'Password123!',
        selectedRole: UserRole.barber,
      );

      expect(fakeFirebaseAuth.lastSignInEmail, '0501234567@barbersync.app');
      expect(result.uid, 'uid-barber-1');
      expect(result.fullName, 'Sami Al-Harbi');
      expect(result.phoneNumber, '0501234567');
      expect(result.role, UserRole.barber);
      expect(fakeFirebaseAuth.signOutCallCount, 0);
    });

    test(
        'throws RoleMismatchException and immediately calls signOut when role does not match',
        () async {
      final existingBarberUser = _FakeUser(
        uid: 'uid-barber-1',
        email: '0501234567@barbersync.app',
        displayName: 'Sami Al-Harbi|barber',
      );
      fakeFirebaseAuth.activeUser = existingBarberUser;
      fakeFirebaseAuth.onSignIn = (email, password) async {
        return _FakeUserCredential(existingBarberUser);
      };

      await expectLater(
        () => remoteDataSource.authenticateWithPhone(
          fullName: 'Sami Al-Harbi',
          phoneNumber: '050 123 4567',
          password: 'Password123!',
          selectedRole: UserRole.customer,
        ),
        throwsA(
          isA<RoleMismatchException>()
              .having((e) => e.expectedRole, 'expectedRole', 'customer')
              .having((e) => e.actualRole, 'actualRole', 'barber'),
        ),
      );

      expect(fakeFirebaseAuth.signOutCallCount, 1);
      expect(fakeFirebaseAuth.currentUser, isNull);
    });

    test(
        'auto-registers new user on user-not-found and saves fullName|role in displayName',
        () async {
      final createdUser = _FakeUser(
        uid: 'uid-customer-99',
        email: '0550001111@barbersync.app',
      );
      fakeFirebaseAuth.onSignIn = (email, password) async {
        throw FirebaseAuthException(code: 'user-not-found');
      };
      fakeFirebaseAuth.onCreateUser = (email, password) async {
        return _FakeUserCredential(createdUser);
      };

      final result = await remoteDataSource.authenticateWithPhone(
        fullName: 'Tariq Saleh',
        phoneNumber: '055-000-1111',
        password: 'SecretPassword1!',
        selectedRole: UserRole.customer,
      );

      expect(fakeFirebaseAuth.lastCreatedEmail, '0550001111@barbersync.app');
      expect(createdUser.lastUpdatedDisplayName, 'Tariq Saleh|customer');
      expect(result.uid, 'uid-customer-99');
      expect(result.fullName, 'Tariq Saleh');
      expect(result.phoneNumber, '0550001111');
      expect(result.role, UserRole.customer);
    });
  });

  group('getCurrentUserSession', () {
    test('returns UserEntity with correct UserRole when session is valid',
        () async {
      fakeFirebaseAuth.activeUser = _FakeUser(
        uid: 'uid-session-1',
        email: '+966501112233@barbersync.app',
        displayName: 'Khalid Mansour|barber',
        idToken: 'valid-id-token',
      );

      final UserEntity? sessionUser = await repository.getCurrentUserSession();

      expect(sessionUser, isNotNull);
      expect(sessionUser!.uid, 'uid-session-1');
      expect(sessionUser.fullName, 'Khalid Mansour');
      expect(sessionUser.phoneNumber, '+966501112233');
      expect(sessionUser.role, UserRole.barber);
      expect(fakeFirebaseAuth.signOutCallCount, 0);
    });

    test('returns null when no currentUser exists', () async {
      fakeFirebaseAuth.activeUser = null;

      final sessionUser = await repository.getCurrentUserSession();
      expect(sessionUser, isNull);
    });

    test('signs out and returns null when ID token validation throws',
        () async {
      fakeFirebaseAuth.activeUser = _FakeUser(
        uid: 'uid-expired',
        email: '0501112233@barbersync.app',
        displayName: 'Khalid Mansour|customer',
        idTokenError: FirebaseAuthException(code: 'user-token-expired'),
      );

      final sessionUser = await repository.getCurrentUserSession();

      expect(sessionUser, isNull);
      expect(fakeFirebaseAuth.signOutCallCount, 1);
    });
  });

  group('AuthRepository Failure Mapping & DI', () {
    test('maps FirebaseAuthException codes to typed domain Failures', () async {
      fakeFirebaseAuth.onSignIn = (email, password) async {
        throw FirebaseAuthException(code: 'wrong-password');
      };

      await expectLater(
        () => repository.authenticateWithPhone(
          fullName: 'User',
          phoneNumber: '0501234567',
          password: 'wrong',
          selectedRole: UserRole.customer,
        ),
        throwsA(isA<InvalidCredentialsFailure>()),
      );

      fakeFirebaseAuth.onSignIn = (email, password) async {
        throw FirebaseAuthException(code: 'weak-password');
      };

      await expectLater(
        () => repository.authenticateWithPhone(
          fullName: 'User',
          phoneNumber: '0501234567',
          password: '123',
          selectedRole: UserRole.customer,
        ),
        throwsA(isA<WeakPasswordFailure>()),
      );

      fakeFirebaseAuth.onSignIn = (email, password) async {
        throw FirebaseAuthException(code: 'network-request-failed');
      };

      await expectLater(
        () => repository.authenticateWithPhone(
          fullName: 'User',
          phoneNumber: '0501234567',
          password: 'Password123',
          selectedRole: UserRole.customer,
        ),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('registers and resolves Auth dependencies via GetIt service locator',
        () async {
      final testLocator = GetIt.asNewInstance();
      registerAuthDependencies(
        serviceLocator: testLocator,
        firebaseAuth: fakeFirebaseAuth,
      );

      expect(testLocator.isRegistered<FirebaseAuth>(), isTrue);
      expect(testLocator.isRegistered<AuthRemoteDataSource>(), isTrue);
      expect(testLocator.isRegistered<AuthRepository>(), isTrue);
      expect(testLocator.isRegistered<AuthenticateUserUseCase>(), isTrue);
      expect(testLocator.isRegistered<CheckAuthSessionUseCase>(), isTrue);
      expect(testLocator.isRegistered<SignOutUseCase>(), isTrue);

      final signOutUseCase = testLocator<SignOutUseCase>();
      await signOutUseCase();
      expect(fakeFirebaseAuth.signOutCallCount, 1);
    });
  });
}
