import 'dart:async';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barber_app/features/auth/domain/usecases/authenticate_user_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/check_auth_session_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/screens/login_screen.dart';
import 'package:barber_app/features/auth/presentation/widgets/widgets.dart';
import 'package:barber_app/l10n/app_localizations.dart';
import 'package:barber_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAuthRepository implements AuthRepository {
  UserEntity? sessionUser;
  String? lastFullName;
  String? lastPhoneNumber;
  String? lastPassword;
  UserRole? lastSelectedRole;
  int signOutCount = 0;

  Future<UserEntity> Function({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  })? onAuthenticate;

  @override
  Future<UserEntity> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) async {
    lastFullName = fullName;
    lastPhoneNumber = phoneNumber;
    lastPassword = password;
    lastSelectedRole = selectedRole;
    if (onAuthenticate != null) {
      return onAuthenticate!(
        fullName: fullName,
        phoneNumber: phoneNumber,
        password: password,
        selectedRole: selectedRole,
      );
    }
    return UserEntity(
      uid: 'uid-test',
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: selectedRole,
    );
  }

  @override
  Future<UserEntity?> getCurrentUserSession() async => sessionUser;

  @override
  Future<void> signOut() async {
    signOutCount++;
    sessionUser = null;
  }
}

AuthBloc _createTestAuthBloc(_TestAuthRepository repo) {
  return AuthBloc(
    authenticateUserUseCase: AuthenticateUserUseCase(repo),
    checkAuthSessionUseCase: CheckAuthSessionUseCase(repo),
    signOutUseCase: SignOutUseCase(repo),
  );
}

Widget _buildTestLoginHost({
  AuthBloc? authBloc,
  LoginFormSubmitCallback? onSubmit,
  bool isLoading = false,
}) {
  final settings = AppSettingsController();
  Widget child = LoginScreen(
    onSubmit: onSubmit,
    isLoading: isLoading,
  );

  if (authBloc != null) {
    child = BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: child,
    );
  }

  return AppSettingsScope(
    controller: settings,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('LoginScreen UI, Validation & AuthBloc Integration', () {
    testWidgets(
        'renders header, Full Name, Phone, Password fields, Role dropdown, and Continue button',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestLoginHost());
      await tester.pumpAndSettle();

      expect(find.byType(LoginHeader), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Sign in or create an account to continue'),
        findsOneWidget,
      );

      expect(find.byType(LuxuryTextField), findsNWidgets(3));
      expect(find.text('FULL NAME (FIRST & LAST)'), findsOneWidget);
      expect(find.text('PHONE NUMBER'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);

      expect(find.byType(RoleDropdownField), findsOneWidget);
      expect(find.text('ACCOUNT TYPE'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);

      expect(find.byType(LuxuryPrimaryButton), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets(
        'displays localized validation errors when submitting empty or invalid inputs',
        (WidgetTester tester) async {
      bool submitted = false;
      await tester.pumpWidget(
        _buildTestLoginHost(
          onSubmit: (_, __, ___, ____) => submitted = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(submitted, isFalse);
      expect(
        find.text('Please enter your first and last name'),
        findsOneWidget,
      );
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Sami');
      await tester.enterText(find.byType(TextFormField).at(1), '07912');
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.ensureVisible(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(submitted, isFalse);
      expect(
        find.text('Please enter your first and last name'),
        findsOneWidget,
      );
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets(
        'submitting valid credentials dispatches AuthSubmitRequested with exact fields and role',
        (WidgetTester tester) async {
      final repo = _TestAuthRepository();
      final bloc = _createTestAuthBloc(repo);
      addTearDown(bloc.close);

      await tester.pumpWidget(_buildTestLoginHost(authBloc: bloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Sami Almuhur',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '0791234567',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'SecretPass123',
      );

      await tester.ensureVisible(find.byType(RoleDropdownField));
      await tester.tap(find.byType(DropdownButtonFormField<UserRole>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barber').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(repo.lastFullName, 'Sami Almuhur');
      expect(repo.lastPhoneNumber, '0791234567');
      expect(repo.lastPassword, 'SecretPass123');
      expect(repo.lastSelectedRole, UserRole.barber);
    });

    testWidgets(
        'AuthLoading state disables inputs and shows loading indicator on the submit button',
        (WidgetTester tester) async {
      final repo = _TestAuthRepository();
      final completer = Completer<UserEntity>();
      repo.onAuthenticate = ({
        required fullName,
        required phoneNumber,
        required password,
        required selectedRole,
      }) =>
          completer.future;

      final bloc = _createTestAuthBloc(repo);
      addTearDown(bloc.close);

      await tester.pumpWidget(_buildTestLoginHost(authBloc: bloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Sami Almuhur',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '0791234567',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'SecretPass123',
      );

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final nameField =
          tester.widget<TextFormField>(find.byType(TextFormField).at(0));
      expect(nameField.enabled, isFalse);

      completer.complete(
        const UserEntity(
          uid: 'uid-1',
          fullName: 'Sami Almuhur',
          phoneNumber: '0791234567',
          role: UserRole.customer,
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets(
        'AuthFailureState(RoleMismatchFailure) renders localized roleMismatchError banner',
        (WidgetTester tester) async {
      final repo = _TestAuthRepository()
        ..onAuthenticate = ({
          required fullName,
          required phoneNumber,
          required password,
          required selectedRole,
        }) async {
          throw const RoleMismatchFailure(
            expectedRole: 'barber',
            actualRole: 'customer',
          );
        };
      final bloc = _createTestAuthBloc(repo);
      addTearDown(bloc.close);

      await tester.pumpWidget(_buildTestLoginHost(authBloc: bloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Sami Almuhur',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '0791234567',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'SecretPass123',
      );

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(AuthErrorBanner), findsOneWidget);
      expect(
        find.text(
          'Access denied: The selected account type does not match your registered role.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'Authenticated state navigates to /barber/dashboard for Barber and /customer/home for Customer, and Sign Out returns to /',
        (WidgetTester tester) async {
      final repo = _TestAuthRepository();
      final bloc = _createTestAuthBloc(repo);
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BarberSyncApp(
          authBloc: bloc,
          initialLocation: AppRoutes.login,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Sami Almuhur',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '0791234567',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'SecretPass123',
      );
      await tester.ensureVisible(find.byType(RoleDropdownField));
      await tester.tap(find.byType(DropdownButtonFormField<UserRole>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barber').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Barber Dashboard'), findsOneWidget);
      expect(find.text('Sami Almuhur'), findsOneWidget);
      expect(find.text('0791234567'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      expect(repo.signOutCount, 1);
      expect(find.text('Login'), findsOneWidget);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Tariq Saleh',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '0789876543',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'SecretPass123',
      );
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Customer Booking'), findsOneWidget);
      expect(find.text('Tariq Saleh'), findsOneWidget);
      expect(find.text('0789876543'), findsOneWidget);
    });
  });
}
