import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barber_app/features/auth/domain/usecases/authenticate_user_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/check_auth_session_usecase.dart';
import 'package:barber_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:barber_app/features/customer/domain/usecases/get_customer_home_data_usecase.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_home_bloc.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_home_state.dart';
import 'package:barber_app/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:barber_app/features/customer/presentation/widgets/barbers_showcase_section.dart';
import 'package:barber_app/features/customer/presentation/widgets/master_barber_card.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class _FakeCustomerRepo implements CustomerRepository {
  @override
  Future<List<BarberEntity>> getBarbers() async => const [];

  @override
  Future<List<ServiceEntity>> getServices() async => const [];

  @override
  Future<List<BookingEntity>> getCustomerBookings(String customerId) async =>
      const [];

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) async =>
      const [];

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
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {}

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

class _FakeAuthRepo implements AuthRepository {
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

const _tBarbers = [
  BarberEntity(
    id: 'barber_1',
    name: 'Tariq Al-Hashemi',
    specialtyEn: 'Master Barber & Classic Styling',
    specialtyAr: 'كبير الحلاقين',
    rating: 4.9,
    experienceYears: 12,
    isAvailableToday: true,
  ),
  BarberEntity(
    id: 'barber_2',
    name: 'Omar Khateeb',
    specialtyEn: 'Modern Fades & Textures',
    specialtyAr: 'التدرجات العصرية',
    rating: 4.8,
    experienceYears: 8,
    isAvailableToday: true,
  ),
  BarberEntity(
    id: 'barber_3',
    name: 'Zaid Al-Mansoor',
    specialtyEn: 'Beard Artistry & Razor Precision',
    specialtyAr: 'نحت اللحى',
    rating: 4.9,
    experienceYears: 10,
    isAvailableToday: false,
  ),
];

void main() {
  group('MasterBarberCard & Horizontal Carousel', () {
    testWidgets(
        'renders horizontal carousel, fallback avatar, supports horizontal scroll, and navigates on tap',
        (WidgetTester tester) async {
      String? navigatedBarberId;

      final homeBloc = CustomerHomeBloc(
        getCustomerHomeDataUseCase:
            GetCustomerHomeDataUseCase(_FakeCustomerRepo()),
        initialState: const CustomerHomeLoaded(
          services: [],
          barbers: _tBarbers,
        ),
      );
      addTearDown(homeBloc.close);

      final authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(_FakeAuthRepo()),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(_FakeAuthRepo()),
        signOutUseCase: SignOutUseCase(_FakeAuthRepo()),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'cust_1',
            fullName: 'Sami',
            phoneNumber: '0790000000',
            role: UserRole.customer,
          ),
        ));
      addTearDown(authBloc.close);

      final router = GoRouter(
        initialLocation: AppRoutes.customerHome,
        routes: [
          GoRoute(
            path: AppRoutes.customerHome,
            builder: (_, __) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.customerBook,
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              navigatedBarberId = extra?['barberId'] as String?;
              return const Scaffold(body: Text('Booking Screen'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<CustomerHomeBloc>.value(value: homeBloc),
          ],
          child: AppSettingsScope(
            controller: AppSettingsController(),
            child: MaterialApp.router(
              theme: AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final carouselFinder = find.descendant(
        of: find.byType(BarbersShowcaseSection),
        matching: find.byType(ListView),
      );
      expect(carouselFinder, findsOneWidget);

      final listView = tester.widget<ListView>(carouselFinder);
      expect(listView.scrollDirection, Axis.horizontal);
      expect(find.byType(MasterBarberCard), findsWidgets);
      expect(find.byType(LuxuryAvatar), findsWidgets);

      await tester.ensureVisible(carouselFinder);
      await tester.pumpAndSettle();

      await tester.drag(carouselFinder, const Offset(-350, 0));
      await tester.pumpAndSettle();

      expect(find.text('Zaid Al-Mansoor'), findsOneWidget);
      await tester.ensureVisible(find.text('Zaid Al-Mansoor'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zaid Al-Mansoor'));
      await tester.pumpAndSettle();

      expect(navigatedBarberId, 'barber_3');
      expect(find.text('Booking Screen'), findsOneWidget);
    });
  });
}
