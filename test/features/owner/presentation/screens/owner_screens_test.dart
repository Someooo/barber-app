import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barber_app/features/auth/domain/usecases/authenticate_user_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/check_auth_session_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/owner/domain/usecases/add_barber_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/add_service_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/delete_barber_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/delete_service_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/get_owner_overview_usecase.dart';
import 'package:barber_app/features/owner/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:barber_app/features/owner/presentation/bloc/owner_dashboard_state.dart';
import 'package:barber_app/features/owner/presentation/screens/owner_barbers_screen.dart';
import 'package:barber_app/features/owner/presentation/screens/owner_overview_screen.dart';
import 'package:barber_app/features/owner/presentation/screens/owner_profile_screen.dart';
import 'package:barber_app/features/owner/presentation/screens/owner_services_screen.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class _MockAuthRepo implements AuthRepository {
  @override
  Future<UserEntity> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) async =>
      throw UnimplementedError();

  @override
  Future<UserEntity?> getCurrentUserSession() async => null;

  @override
  Future<void> signOut() async {}
}

Widget _buildHost({
  required Widget child,
  required AuthBloc authBloc,
  required OwnerDashboardBloc ownerBloc,
}) {
  final settings = AppSettingsController();
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<OwnerDashboardBloc>.value(value: ownerBloc),
    ],
    child: AppSettingsScope(
      controller: settings,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

void main() {
  group('Owner Screens UI & Actions', () {
    late CustomerRepositoryImpl repository;
    late AuthBloc authBloc;

    const tService = ServiceEntity(
      id: 'srv_1',
      nameEn: 'Signature Cut',
      nameAr: 'قصة مميزة',
      descriptionEn: 'Cut',
      descriptionAr: 'قص',
      price: 35,
      durationMinutes: 45,
      iconName: 'content_cut',
    );

    const tBarber = BarberEntity(
      id: 'barber_1',
      name: 'Tariq Al-Hashemi',
      specialtyEn: 'Master Barber',
      specialtyAr: 'كبير الحلاقين',
      rating: 4.9,
      experienceYears: 12,
      isAvailableToday: true,
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = CustomerRepositoryImpl(
        remoteDataSource: InMemoryFirestoreCustomerDataSource(prefs: prefs),
      );
      final authRepo = _MockAuthRepo();
      authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(authRepo),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(authRepo),
        signOutUseCase: SignOutUseCase(authRepo),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'owner_1',
            fullName: 'Sami Manager',
            phoneNumber: '0798888888',
            role: UserRole.owner,
          ),
        ));
    });

    tearDown(() => authBloc.close());

    OwnerDashboardBloc createLoadedBloc() {
      return OwnerDashboardBloc(
        getOwnerOverviewUseCase: GetOwnerOverviewUseCase(repository),
        addServiceUseCase: AddServiceUseCase(repository),
        deleteServiceUseCase: DeleteServiceUseCase(repository),
        addBarberUseCase: AddBarberUseCase(repository),
        deleteBarberUseCase: DeleteBarberUseCase(repository),
        initialState: const OwnerDashboardLoaded(
          services: [tService],
          barbers: [tBarber],
          allBookings: [],
          totalShopRevenue: 120,
          activeBookingsCount: 3,
        ),
      );
    }

    testWidgets('OwnerOverviewScreen renders KPI cards and quick actions',
        (WidgetTester tester) async {
      final bloc = createLoadedBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildHost(
          authBloc: authBloc,
          ownerBloc: bloc,
          child: OwnerOverviewScreen(
            onNavigateToServices: () {},
            onNavigateToBarbers: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shop Management'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('\$120'), findsOneWidget);
      expect(find.text('Active Appointments'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Add New Service'), findsOneWidget);
      expect(find.text('Add New Barber'), findsOneWidget);
    });

    testWidgets('OwnerServicesScreen opens Add sheet and Delete confirmation',
        (WidgetTester tester) async {
      final bloc = createLoadedBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildHost(
          authBloc: authBloc,
          ownerBloc: bloc,
          child: const OwnerServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Signature Cut'), findsOneWidget);

      await tester.tap(find.text('Add New Service'));
      await tester.pumpAndSettle();
      expect(find.text('SERVICE NAME (ENGLISH)'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('This field is required'), findsWidgets);

      Navigator.of(tester.element(find.text('SERVICE NAME (ENGLISH)'))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Delete Service'), findsOneWidget);
    });

    testWidgets('OwnerBarbersScreen opens Add sheet and Delete confirmation',
        (WidgetTester tester) async {
      final bloc = createLoadedBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildHost(
          authBloc: authBloc,
          ownerBloc: bloc,
          child: const OwnerBarbersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tariq Al-Hashemi'), findsOneWidget);

      await tester.tap(find.text('Add New Barber'));
      await tester.pumpAndSettle();
      expect(find.text('BARBER FULL NAME'), findsOneWidget);

      Navigator.of(tester.element(find.text('BARBER FULL NAME'))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Delete Barber'), findsOneWidget);
    });

    testWidgets('OwnerProfileScreen renders identity, switches, and sign out',
        (WidgetTester tester) async {
      final bloc = createLoadedBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildHost(
          authBloc: authBloc,
          ownerBloc: bloc,
          child: const OwnerProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sami Manager'), findsOneWidget);
      expect(find.text('SHOP OWNER'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      expect(
        find.text('Are you sure you want to sign out of your account?'),
        findsOneWidget,
      );
    });
  });
}
