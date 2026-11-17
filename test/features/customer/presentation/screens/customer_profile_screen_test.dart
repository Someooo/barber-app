import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barber_app/features/auth/domain/usecases/authenticate_user_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/check_auth_session_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/customer/presentation/screens/customer_profile_screen.dart';
import 'package:barber_app/features/customer/presentation/widgets/customer_identity_card.dart';
import 'package:barber_app/features/customer/presentation/widgets/customer_preferences_card.dart';
import 'package:barber_app/features/customer/presentation/widgets/sign_out_confirmation_dialog.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class _MockAuthRepo implements AuthRepository {
  bool didSignOut = false;

  @override
  Future<UserEntity> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity?> getCurrentUserSession() async {
    return const UserEntity(
      uid: 'cust_sami',
      fullName: 'Sami Almuhur',
      phoneNumber: '0799999999',
      role: UserRole.customer,
    );
  }

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }
}

Widget _buildTestHost({
  required Widget child,
  required AuthBloc authBloc,
  AppSettingsController? settingsController,
}) {
  final settings = settingsController ?? AppSettingsController();

  return BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: AppSettingsScope(
      controller: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return MaterialApp(
            locale: settings.locale,
            themeMode: settings.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: child,
          );
        },
      ),
    ),
  );
}

void main() {
  group('CustomerProfileScreen UI & Actions', () {
    testWidgets('renders identity card with user info and preferences card',
        (WidgetTester tester) async {
      final mockRepo = _MockAuthRepo();
      final authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(mockRepo),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(mockRepo),
        signOutUseCase: SignOutUseCase(mockRepo),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'cust_sami',
            fullName: 'Sami Almuhur',
            phoneNumber: '0799999999',
            role: UserRole.customer,
          ),
        ));
      addTearDown(authBloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerProfileScreen(),
          authBloc: authBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(CustomerIdentityCard), findsOneWidget);
      expect(find.text('Sami Almuhur'), findsOneWidget);
      expect(find.text('0799999999'), findsOneWidget);
      expect(find.text('CUSTOMER'), findsOneWidget);

      expect(find.byType(CustomerPreferencesCard), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('toggles dark mode switch and language button',
        (WidgetTester tester) async {
      final mockRepo = _MockAuthRepo();
      final authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(mockRepo),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(mockRepo),
        signOutUseCase: SignOutUseCase(mockRepo),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'cust_sami',
            fullName: 'Sami Almuhur',
            phoneNumber: '0799999999',
            role: UserRole.customer,
          ),
        ));
      addTearDown(authBloc.close);

      final settings = AppSettingsController();

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerProfileScreen(),
          authBloc: authBloc,
          settingsController: settings,
        ),
      );
      await tester.pumpAndSettle();

      expect(settings.themeMode, ThemeMode.light);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(settings.themeMode, ThemeMode.dark);

      expect(settings.languageCode, 'EN');
      await tester.tap(find.text('EN').first);
      await tester.pumpAndSettle();
      expect(settings.languageCode, 'AR');
      expect(find.text('الملف الشخصي'), findsOneWidget);
      expect(find.text('الوضع الليلي'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsOneWidget);
    });

    testWidgets(
        'taps enhanced theme icon container to toggle theme and updates icon',
        (WidgetTester tester) async {
      final mockRepo = _MockAuthRepo();
      final authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(mockRepo),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(mockRepo),
        signOutUseCase: SignOutUseCase(mockRepo),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'cust_sami',
            fullName: 'Sami Almuhur',
            phoneNumber: '0799999999',
            role: UserRole.customer,
          ),
        ));
      addTearDown(authBloc.close);

      final settings = AppSettingsController();

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerProfileScreen(),
          authBloc: authBloc,
          settingsController: settings,
        ),
      );
      await tester.pumpAndSettle();

      expect(settings.themeMode, ThemeMode.light);
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.light_mode_outlined));
      await tester.pumpAndSettle();

      expect(settings.themeMode, ThemeMode.dark);
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();

      expect(settings.themeMode, ThemeMode.light);
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    });

    testWidgets(
        'Sign Out button opens confirmation dialog and dispatches sign out when confirmed',
        (WidgetTester tester) async {
      final mockRepo = _MockAuthRepo();
      final authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(mockRepo),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(mockRepo),
        signOutUseCase: SignOutUseCase(mockRepo),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'cust_sami',
            fullName: 'Sami Almuhur',
            phoneNumber: '0799999999',
            role: UserRole.customer,
          ),
        ));
      addTearDown(authBloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerProfileScreen(),
          authBloc: authBloc,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(find.byType(SignOutConfirmationDialog), findsOneWidget);
      expect(find.text('Are you sure you want to sign out of your account?'),
          findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(SignOutConfirmationDialog), findsNothing);
      expect(mockRepo.didSignOut, isFalse);

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(find.byType(SignOutConfirmationDialog), findsOneWidget);

      final confirmSignOutFinder = find.descendant(
        of: find.byType(LuxuryPrimaryButton),
        matching: find.text('Sign Out'),
      );
      await tester.tap(confirmSignOutFinder);
      await tester.pumpAndSettle();

      expect(mockRepo.didSignOut, isTrue);
      expect(authBloc.state, const Unauthenticated());
    });
  });
}
