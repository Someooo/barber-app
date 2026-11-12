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
import 'package:barber_app/features/auth/presentation/screens/register_screen.dart';
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
    return UserEntity(
      uid: 'uid-reg-test',
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: selectedRole,
    );
  }

  @override
  Future<UserEntity?> getCurrentUserSession() async => sessionUser;

  @override
  Future<void> signOut() async {
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

Widget _buildTestRegisterHost({
  AuthBloc? authBloc,
  RegisterFormSubmitCallback? onSubmit,
}) {
  final settings = AppSettingsController();
  Widget child = RegisterScreen(onSubmit: onSubmit);

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
  group('RegisterScreen UI, Validation & Navigation', () {
    testWidgets(
        'renders RegisterHeader, BrandLogo, Full Name, Phone Number, Password fields, and Create Account button',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestRegisterHost());
      await tester.pumpAndSettle();

      expect(find.byType(RegisterHeader), findsOneWidget);
      expect(find.byType(BrandLogo), findsOneWidget);
      expect(find.text('Join BarberSync'), findsOneWidget);
      expect(find.text('Enter your details to get started'), findsOneWidget);
      expect(find.byType(LuxuryTextField), findsNWidgets(3));
      expect(find.text('FULL NAME (FIRST & LAST)'), findsOneWidget);
      expect(find.text('PHONE NUMBER'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.byType(LuxuryPrimaryButton), findsOneWidget);
    });

    testWidgets('validates empty inputs and prevents submission',
        (WidgetTester tester) async {
      bool submitted = false;
      await tester.pumpWidget(
        _buildTestRegisterHost(
          onSubmit: (_, __, ___, ____) => submitted = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(LuxuryPrimaryButton));
      await tester.tap(find.byType(LuxuryPrimaryButton));
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
        'submitting valid registration dispatches AuthSubmitRequested and redirects directly to Home route',
        (WidgetTester tester) async {
      final repo = _TestAuthRepository();
      final bloc = _createTestAuthBloc(repo);
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BarberSyncApp(
          authBloc: bloc,
          initialLocation: AppRoutes.register,
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

      await tester.ensureVisible(find.byType(LuxuryPrimaryButton));
      await tester.tap(find.byType(LuxuryPrimaryButton));
      await tester.pumpAndSettle();

      expect(repo.lastFullName, 'Sami Almuhur');
      expect(repo.lastPhoneNumber, '0791234567');
      expect(repo.lastPassword, 'SecretPass123');
      expect(repo.lastSelectedRole, UserRole.customer);
      expect(find.text('Customer Booking'), findsOneWidget);
      expect(find.text('Sami Almuhur'), findsOneWidget);
    });
  });
}

