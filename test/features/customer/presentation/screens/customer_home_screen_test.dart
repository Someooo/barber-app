import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barber_app/features/auth/domain/usecases/authenticate_user_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/check_auth_session_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:barber_app/features/customer/domain/usecases/get_customer_home_data_usecase.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_home_bloc.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_home_state.dart';
import 'package:barber_app/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:barber_app/features/customer/presentation/screens/customer_shell_screen.dart';
import 'package:barber_app/features/customer/presentation/widgets/active_booking_hero_card.dart';
import 'package:barber_app/features/customer/presentation/widgets/barbers_showcase_section.dart';
import 'package:barber_app/features/customer/presentation/widgets/customer_home_error_banner.dart';
import 'package:barber_app/features/customer/presentation/widgets/quick_book_cta_banner.dart';
import 'package:barber_app/features/customer/presentation/widgets/services_catalog_section.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class _FakeTestAuthRepo implements AuthRepository {
  UserEntity? user = const UserEntity(
    uid: 'cust_sami',
    fullName: 'Sami Almuhur',
    phoneNumber: '0799999999',
    role: UserRole.customer,
  );

  @override
  Future<UserEntity> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) async {
    return user!;
  }

  @override
  Future<UserEntity?> getCurrentUserSession() async {
    return user;
  }

  @override
  Future<void> signOut() async {
    user = null;
  }
}

class _FakeTestCustomerRepo implements CustomerRepository {
  List<ServiceEntity> services = [];
  List<BarberEntity> barbers = [];
  List<BookingEntity> bookings = [];
  Completer<void>? delayCompleter;
  Object? errorToThrow;

  @override
  Future<List<ServiceEntity>> getServices() async {
    if (delayCompleter != null) await delayCompleter!.future;
    if (errorToThrow != null) throw errorToThrow!;
    return services;
  }

  @override
  Future<List<BarberEntity>> getBarbers() async {
    if (delayCompleter != null) await delayCompleter!.future;
    if (errorToThrow != null) throw errorToThrow!;
    return barbers;
  }

  @override
  Future<List<BookingEntity>> getCustomerBookings(String customerId) async {
    if (delayCompleter != null) await delayCompleter!.future;
    if (errorToThrow != null) throw errorToThrow!;
    return bookings;
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    return [];
  }

  @override
  Future<BookingEntity> createInstantBooking({
    required String customerId,
    required String customerName,
    required String barberId,
    required String barberName,
    required List<ServiceEntity> services,
    required DateTime dateTime,
    required double totalPrice,
    required int totalDurationMinutes,
    String? notes,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<BarberEntity> ensureBarberProfile({
    required String barberId,
    required String name,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<BookingEntity>> getBarberBookings(String barberId) async =>
      const [];

  @override
  Future<void> updateBarberAvailability({
    required String barberId,
    required bool isAvailableToday,
  }) async {}

  @override
  Future<void> completeBooking(String bookingId) async {}

  @override
  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDateTime,
    required String reason,
  }) async {}

  @override
  Future<ServiceEntity> addService(ServiceEntity service) async => service;

  @override
  Future<void> deleteService(String serviceId) async {}

  @override
  Future<BarberEntity> addBarber(BarberEntity barber) async => barber;

  @override
  Future<void> deleteBarber(String barberId) async {}

  @override
  Future<List<BookingEntity>> getAllShopBookings() async => const [];
}

Widget _buildTestHost({
  required Widget child,
  required CustomerHomeBloc customerHomeBloc,
  AuthBloc? authBloc,
  AppSettingsController? settingsController,
}) {
  final settings = settingsController ?? AppSettingsController();

  final effectiveAuthBloc = authBloc ??
      (AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(_FakeTestAuthRepo()),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(_FakeTestAuthRepo()),
        signOutUseCase: SignOutUseCase(_FakeTestAuthRepo()),
      )..add(const AuthCheckRequested()));

  Widget content = MultiBlocProvider(
    providers: [
      BlocProvider<CustomerHomeBloc>.value(value: customerHomeBloc),
      BlocProvider<AuthBloc>.value(value: effectiveAuthBloc),
    ],
    child: child,
  );

  return AppSettingsScope(
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
          home: content,
        );
      },
    ),
  );
}

void main() {
  const tService = ServiceEntity(
    id: 's1',
    nameEn: 'Signature Cut & Style',
    nameAr: 'قصة شعر وتصفيف مميز',
    descriptionEn: 'Precision scissor cut with styling.',
    descriptionAr: 'قص شعر احترافي وتصفيف.',
    price: 35.0,
    durationMinutes: 45,
    iconName: 'content_cut',
  );

  const tBarber = BarberEntity(
    id: 'b1',
    name: 'Tariq Al-Hashemi',
    specialtyEn: 'Master Barber',
    specialtyAr: 'كبير الحلاقين',
    rating: 4.9,
    experienceYears: 12,
    isAvailableToday: true,
  );

  final tActiveBooking = BookingEntity(
    id: 'bk_1',
    customerId: 'cust_sami',
    customerName: 'Sami Almuhur',
    barberId: 'b1',
    barberName: 'Tariq Al-Hashemi',
    services: const [tService],
    dateTime: DateTime.now().add(const Duration(days: 1)),
    totalPrice: 35.0,
    totalDurationMinutes: 45,
    status: BookingStatus.confirmed,
  );

  final tRescheduledBooking = BookingEntity(
    id: 'bk_2',
    customerId: 'cust_sami',
    customerName: 'Sami Almuhur',
    barberId: 'b1',
    barberName: 'Tariq Al-Hashemi',
    services: const [tService],
    dateTime: DateTime.now().add(const Duration(days: 2)),
    totalPrice: 35.0,
    totalDurationMinutes: 45,
    status: BookingStatus.rescheduled,
    statusReason: 'Barber emergency, moved 2 hours forward',
  );

  group('CustomerHomeScreen UI & Performance', () {
    late _FakeTestCustomerRepo repo;
    late GetCustomerHomeDataUseCase useCase;
    late CustomerHomeBloc bloc;

    setUp(() {
      repo = _FakeTestCustomerRepo();
      useCase = GetCustomerHomeDataUseCase(repo);
      bloc = CustomerHomeBloc(getCustomerHomeDataUseCase: useCase);
    });

    tearDown(() {
      bloc.close();
    });

    testWidgets('shows LuxuryShimmerCard loaders while loading',
        (WidgetTester tester) async {
      final loadingBloc = CustomerHomeBloc(
        getCustomerHomeDataUseCase: useCase,
        initialState: const CustomerHomeLoading(),
      );
      addTearDown(loadingBloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerHomeScreen(
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          customerHomeBloc: loadingBloc,
        ),
      );
      await tester.pump();

      expect(find.byType(LuxuryShimmerCard), findsWidgets);
    });

    testWidgets(
        'renders AppBar with greeting, active hero card, CTA, services, and barbers',
        (WidgetTester tester) async {
      final loadedBloc = CustomerHomeBloc(
        getCustomerHomeDataUseCase: useCase,
        initialState: CustomerHomeLoaded(
          services: const [tService],
          barbers: const [tBarber],
          activeBooking: tActiveBooking,
        ),
      );
      addTearDown(loadedBloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerHomeScreen(
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          customerHomeBloc: loadedBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Customer Booking'), findsOneWidget);
      expect(find.text('SAMI ALMUHUR'), findsWidgets);

      expect(find.byType(ActiveBookingHeroCard), findsOneWidget);
      expect(find.text('Upcoming Appointment'), findsOneWidget);
      expect(find.text('Tariq Al-Hashemi'), findsWidgets);
      expect(find.text('Confirmed'), findsOneWidget);

      expect(find.byType(QuickBookCtaBanner), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);

      expect(find.byType(ServicesCatalogSection), findsOneWidget);
      expect(find.text('Luxury Services'), findsOneWidget);
      expect(find.text('Signature Cut & Style'), findsWidgets);
      expect(find.text('\$35'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);

      expect(find.byType(BarbersShowcaseSection), findsOneWidget);
      expect(find.text('Master Barbers'), findsOneWidget);
      expect(find.text('Available Today'), findsOneWidget);
      expect(find.text('12 yrs exp'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
    });

    testWidgets(
        'does not render active booking card when activeBooking is null',
        (WidgetTester tester) async {
      final loadedBloc = CustomerHomeBloc(
        getCustomerHomeDataUseCase: useCase,
        initialState: const CustomerHomeLoaded(
          services: [tService],
          barbers: [tBarber],
          activeBooking: null,
        ),
      );
      addTearDown(loadedBloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerHomeScreen(
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          customerHomeBloc: loadedBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming Appointment'), findsNothing);
      expect(find.text('Luxury Services'), findsOneWidget);
    });

    testWidgets(
        'renders rescheduled status and statusReason when appointment is rescheduled',
        (WidgetTester tester) async {
      final loadedBloc = CustomerHomeBloc(
        getCustomerHomeDataUseCase: useCase,
        initialState: CustomerHomeLoaded(
          services: const [tService],
          barbers: const [tBarber],
          activeBooking: tRescheduledBooking,
        ),
      );
      addTearDown(loadedBloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerHomeScreen(
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          customerHomeBloc: loadedBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rescheduled'), findsOneWidget);
      expect(
        find.text('Reason: Barber emergency, moved 2 hours forward'),
        findsOneWidget,
      );
    });

    testWidgets('renders localized error banner and retries on press',
        (WidgetTester tester) async {
      repo.services = [tService];
      repo.barbers = [tBarber];

      final errorBloc = CustomerHomeBloc(
        getCustomerHomeDataUseCase: useCase,
        initialState: const CustomerHomeFailure(message: 'Network down'),
      );
      addTearDown(errorBloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerHomeScreen(
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          customerHomeBloc: errorBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomerHomeErrorBanner), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.text('Luxury Services'), findsOneWidget);
    });

    testWidgets('Theme and Locale toggles work on AppBar',
        (WidgetTester tester) async {
      final loadedBloc = CustomerHomeBloc(
        getCustomerHomeDataUseCase: useCase,
        initialState: const CustomerHomeLoaded(
          services: [tService],
          barbers: [tBarber],
          activeBooking: null,
        ),
      );
      addTearDown(loadedBloc.close);
      final settings = AppSettingsController();

      await tester.pumpWidget(
        _buildTestHost(
          child: const CustomerHomeScreen(
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          customerHomeBloc: loadedBloc,
          settingsController: settings,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

      expect(find.text('EN'), findsOneWidget);
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      expect(find.text('AR'), findsOneWidget);
      expect(find.text('الخدمات الفاخرة'), findsOneWidget);
      expect(find.text('قصة شعر وتصفيف مميز'), findsOneWidget);
    });
  });

  group('CustomerShellScreen Bottom Navigation', () {
    setUp(() {
      if (sl.isRegistered<CustomerHomeBloc>()) {
        sl.unregister<CustomerHomeBloc>();
      }
      final repo = _FakeTestCustomerRepo();
      repo.services = [tService];
      repo.barbers = [tBarber];
      sl.registerFactory<CustomerHomeBloc>(
        () => CustomerHomeBloc(
          getCustomerHomeDataUseCase: GetCustomerHomeDataUseCase(repo),
        ),
      );
    });

    tearDown(() {
      if (sl.isRegistered<CustomerHomeBloc>()) {
        sl.unregister<CustomerHomeBloc>();
      }
    });

    testWidgets('switches between Home, Bookings, and Profile tabs',
        (WidgetTester tester) async {
      final authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(_FakeTestAuthRepo()),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(_FakeTestAuthRepo()),
        signOutUseCase: SignOutUseCase(_FakeTestAuthRepo()),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'cust_sami',
            fullName: 'Sami Almuhur',
            phoneNumber: '0799999999',
            role: UserRole.customer,
          ),
        ));

      final settings = AppSettingsController();

      await tester.pumpWidget(
        AppSettingsScope(
          controller: settings,
          child: ListenableBuilder(
            listenable: settings,
            builder: (context, _) => MaterialApp(
              locale: settings.locale,
              themeMode: settings.themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BlocProvider<AuthBloc>.value(
                value: authBloc,
                child: const CustomerShellScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Luxury Services'), findsOneWidget);

      await tester.tap(find.text('My Bookings'));
      await tester.pumpAndSettle();
      expect(
        find.text('No Upcoming Bookings'),
        findsOneWidget,
      );

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Sami Almuhur'), findsWidgets);
      expect(find.text('0799999999'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Luxury Services'), findsOneWidget);
    });
  });
}
