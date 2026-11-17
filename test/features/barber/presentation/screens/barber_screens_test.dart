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
import 'package:barber_app/features/barber/domain/usecases/barber_cancel_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/complete_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/ensure_barber_profile_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/get_barber_bookings_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/reschedule_booking_usecase.dart';
import 'package:barber_app/features/barber/domain/usecases/update_barber_availability_usecase.dart';
import 'package:barber_app/features/barber/presentation/bloc/barber_dashboard_bloc.dart';
import 'package:barber_app/features/barber/presentation/bloc/barber_dashboard_state.dart';
import 'package:barber_app/features/barber/presentation/screens/barber_dashboard_screen.dart';
import 'package:barber_app/features/barber/presentation/screens/barber_history_screen.dart';
import 'package:barber_app/features/barber/presentation/screens/barber_profile_screen.dart';
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/usecases/get_available_time_slots_usecase.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class _MockAuthRepo implements AuthRepository {
  bool didSignOut = false;

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
  Future<void> signOut() async {
    didSignOut = true;
  }
}

Widget _buildHost({
  required Widget child,
  required AuthBloc authBloc,
  required BarberDashboardBloc dashboardBloc,
}) {
  final settings = AppSettingsController();
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<BarberDashboardBloc>.value(value: dashboardBloc),
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
  group('Barber Screens UI & Actions', () {
    late CustomerRepositoryImpl repository;
    late AuthBloc authBloc;
    late _MockAuthRepo authRepo;

    const barber = BarberEntity(
      id: 'barber_1',
      name: 'Tariq Al-Hashemi',
      specialtyEn: 'Master Barber',
      specialtyAr: 'كبير الحلاقين',
      rating: 4.9,
      experienceYears: 12,
      isAvailableToday: true,
    );

    const service = ServiceEntity(
      id: 'srv_1',
      nameEn: 'Signature Cut',
      nameAr: 'قصة مميزة',
      descriptionEn: 'Cut',
      descriptionAr: 'قص',
      price: 35,
      durationMinutes: 45,
      iconName: 'content_cut',
    );

    final activeBooking = BookingEntity(
      id: 'b_1',
      customerId: 'cust_1',
      customerName: 'Sami Almuhur',
      barberId: 'barber_1',
      barberName: 'Tariq Al-Hashemi',
      services: const [service],
      dateTime: DateTime(2026, 11, 18, 14, 0),
      totalPrice: 35,
      totalDurationMinutes: 45,
      status: BookingStatus.confirmed,
    );

    final completedBooking = BookingEntity(
      id: 'b_2',
      customerId: 'cust_2',
      customerName: 'Zaid Client',
      barberId: 'barber_1',
      barberName: 'Tariq Al-Hashemi',
      services: const [service],
      dateTime: DateTime(2026, 11, 16, 11, 0),
      totalPrice: 35,
      totalDurationMinutes: 45,
      status: BookingStatus.completed,
    );

    final cancelledBooking = BookingEntity(
      id: 'b_3',
      customerId: 'cust_3',
      customerName: 'Omar Client',
      barberId: 'barber_1',
      barberName: 'Tariq Al-Hashemi',
      services: const [service],
      dateTime: DateTime(2026, 11, 15, 11, 0),
      totalPrice: 35,
      totalDurationMinutes: 45,
      status: BookingStatus.cancelled,
      statusReason: 'Barber unavailable',
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = CustomerRepositoryImpl(
        remoteDataSource: InMemoryFirestoreCustomerDataSource(prefs: prefs),
      );
      authRepo = _MockAuthRepo();
      authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(authRepo),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(authRepo),
        signOutUseCase: SignOutUseCase(authRepo),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'barber_1',
            fullName: 'Tariq Al-Hashemi',
            phoneNumber: '0791111111',
            role: UserRole.barber,
          ),
        ));
    });

    tearDown(() => authBloc.close());

    BarberDashboardBloc createLoadedBloc() {
      return BarberDashboardBloc(
        ensureBarberProfileUseCase: EnsureBarberProfileUseCase(repository),
        getBarberBookingsUseCase: GetBarberBookingsUseCase(repository),
        updateBarberAvailabilityUseCase:
            UpdateBarberAvailabilityUseCase(repository),
        completeBookingUseCase: CompleteBookingUseCase(repository),
        rescheduleBookingUseCase: RescheduleBookingUseCase(repository),
        barberCancelBookingUseCase: BarberCancelBookingUseCase(repository),
        initialState: BarberDashboardLoaded(
          barberProfile: barber,
          todayBookings: [activeBooking],
          upcomingBookings: [activeBooking],
          historyBookings: [completedBooking, cancelledBooking],
          selectedFilterIndex: 0,
          todayExpectedRevenue: 35,
        ),
      );
    }

    testWidgets('BarberDashboardScreen renders KPI card, bookings, and dialogs',
        (WidgetTester tester) async {
      final bloc = createLoadedBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildHost(
          authBloc: authBloc,
          dashboardBloc: bloc,
          child: BarberDashboardScreen(
            getAvailableTimeSlotsUseCase:
                GetAvailableTimeSlotsUseCase(repository),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Today's Appointments"), findsOneWidget);
      expect(find.text('\$35'), findsOneWidget);
      expect(find.text('Sami Almuhur'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('Reschedule'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel Appointment'), findsOneWidget);
      await tester.tap(find.text('Confirm Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a reason'), findsOneWidget);
    });

    testWidgets('BarberHistoryScreen filters Completed and Cancelled bookings',
        (WidgetTester tester) async {
      final bloc = createLoadedBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildHost(
          authBloc: authBloc,
          dashboardBloc: bloc,
          child: const BarberHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zaid Client'), findsOneWidget);
      expect(find.text('Omar Client'), findsOneWidget);

      await tester.tap(find.text('Completed').first);
      await tester.pumpAndSettle();
      expect(find.text('Zaid Client'), findsOneWidget);
      expect(find.text('Omar Client'), findsNothing);

      await tester.tap(find.text('Cancelled').first);
      await tester.pumpAndSettle();
      expect(find.text('Zaid Client'), findsNothing);
      expect(find.text('Omar Client'), findsOneWidget);
      expect(find.text('Reason: Barber unavailable'), findsOneWidget);
    });

    testWidgets('BarberProfileScreen renders identity, switches, and sign out',
        (WidgetTester tester) async {
      final bloc = createLoadedBloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildHost(
          authBloc: authBloc,
          dashboardBloc: bloc,
          child: const BarberProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tariq Al-Hashemi'), findsOneWidget);
      expect(find.text('Available Today'), findsOneWidget);
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
