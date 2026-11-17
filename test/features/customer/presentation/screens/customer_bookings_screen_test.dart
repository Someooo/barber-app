import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/usecases/cancel_booking_usecase.dart';
import 'package:barber_app/features/customer/domain/usecases/get_customer_bookings_usecase.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_bookings_bloc.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_bookings_state.dart';
import 'package:barber_app/features/customer/presentation/screens/customer_bookings_screen.dart';
import 'package:barber_app/features/customer/presentation/widgets/booking_ticket_card.dart';
import 'package:barber_app/features/customer/presentation/widgets/bookings_empty_state.dart';
import 'package:barber_app/features/customer/presentation/widgets/cancel_booking_confirmation_dialog.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<UserEntity> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) async {
    return const UserEntity(
      uid: 'cust_sami',
      fullName: 'Sami Almuhur',
      phoneNumber: '0799999999',
      role: UserRole.customer,
    );
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
  Future<void> signOut() async {}
}

class _DummyGetCustomerBookingsUseCase implements GetCustomerBookingsUseCase {
  @override
  Future<List<BookingEntity>> call(String customerId) async => [];
}

class _DummyCancelBookingUseCase implements CancelBookingUseCase {
  @override
  Future<void> call({required String bookingId, String? reason}) async {}
}

Widget _buildTestHost({
  required Widget child,
  required CustomerBookingsBloc customerBookingsBloc,
  AppSettingsController? settingsController,
}) {
  final settings = settingsController ?? AppSettingsController();
  final authRepo = _FakeAuthRepo();
  final authBloc = AuthBloc(
    authenticateUserUseCase: AuthenticateUserUseCase(authRepo),
    checkAuthSessionUseCase: CheckAuthSessionUseCase(authRepo),
    signOutUseCase: SignOutUseCase(authRepo),
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<CustomerBookingsBloc>.value(value: customerBookingsBloc),
      BlocProvider<AuthBloc>.value(value: authBloc),
    ],
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
  const tService = ServiceEntity(
    id: 'srv_1',
    nameEn: 'Signature Haircut',
    nameAr: 'قصة شعر مميزة',
    descriptionEn: 'Precision cut',
    descriptionAr: 'قص شعر متقن',
    price: 35.0,
    durationMinutes: 45,
    iconName: 'content_cut',
  );

  final tUpcomingBooking = BookingEntity(
    id: 'bk_1',
    customerId: 'cust_sami',
    customerName: 'Sami Almuhur',
    barberId: 'barber_1',
    barberName: 'Tariq Al-Hashemi',
    services: const [tService],
    dateTime: DateTime(2026, 12, 1, 10, 0),
    totalPrice: 35.0,
    totalDurationMinutes: 45,
    status: BookingStatus.confirmed,
  );

  final tRescheduledBooking = BookingEntity(
    id: 'bk_2',
    customerId: 'cust_sami',
    customerName: 'Sami Almuhur',
    barberId: 'barber_1',
    barberName: 'Tariq Al-Hashemi',
    services: const [tService],
    dateTime: DateTime(2026, 12, 2, 14, 0),
    totalPrice: 35.0,
    totalDurationMinutes: 45,
    status: BookingStatus.rescheduled,
    statusReason: 'Barber moved session 1 hour later',
  );

  final tCancelledBooking = BookingEntity(
    id: 'bk_3',
    customerId: 'cust_sami',
    customerName: 'Sami Almuhur',
    barberId: 'barber_2',
    barberName: 'Omar Khateeb',
    services: const [tService],
    dateTime: DateTime(2026, 11, 10, 11, 0),
    totalPrice: 35.0,
    totalDurationMinutes: 45,
    status: BookingStatus.cancelled,
    statusReason: 'Emergency maintenance in salon',
  );

  group('CustomerBookingsScreen UI & Interaction', () {
    testWidgets('shows loading shimmer cards when in loading state',
        (WidgetTester tester) async {
      final bloc = CustomerBookingsBloc(
        getCustomerBookingsUseCase: _DummyGetCustomerBookingsUseCase(),
        cancelBookingUseCase: _DummyCancelBookingUseCase(),
        initialState: const CustomerBookingsLoading(),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: CustomerBookingsScreen(
            customerBookingsBloc: bloc,
            customerId: 'cust_sami',
          ),
          customerBookingsBloc: bloc,
        ),
      );
      await tester.pump();

      expect(find.byType(LuxuryShimmerCard), findsWidgets);
    });

    testWidgets('renders upcoming bookings with tickets and status badges',
        (WidgetTester tester) async {
      final bloc = CustomerBookingsBloc(
        getCustomerBookingsUseCase: _DummyGetCustomerBookingsUseCase(),
        cancelBookingUseCase: _DummyCancelBookingUseCase(),
        initialState: CustomerBookingsLoaded(
          upcomingBookings: [tUpcomingBooking, tRescheduledBooking],
          historyBookings: const [],
          selectedTabIndex: 0,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: CustomerBookingsScreen(
            customerBookingsBloc: bloc,
            customerId: 'cust_sami',
          ),
          customerBookingsBloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      expect(find.byType(BookingTicketCard), findsNWidgets(2));
      expect(find.text('Tariq Al-Hashemi'), findsWidgets);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Rescheduled'), findsOneWidget);
      expect(
        find.text('Reason: Barber moved session 1 hour later'),
        findsOneWidget,
      );
      expect(find.text('Cancel Booking'), findsWidgets);
    });

    testWidgets(
        'switches to history tab and renders past bookings with reasons',
        (WidgetTester tester) async {
      final bloc = CustomerBookingsBloc(
        getCustomerBookingsUseCase: _DummyGetCustomerBookingsUseCase(),
        cancelBookingUseCase: _DummyCancelBookingUseCase(),
        initialState: CustomerBookingsLoaded(
          upcomingBookings: [tUpcomingBooking],
          historyBookings: [tCancelledBooking],
          selectedTabIndex: 0,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: CustomerBookingsScreen(
            customerBookingsBloc: bloc,
            customerId: 'cust_sami',
          ),
          customerBookingsBloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirmed'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('Omar Khateeb'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(
        find.text('Cancellation Reason: Emergency maintenance in salon'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state when tab has no bookings',
        (WidgetTester tester) async {
      final bloc = CustomerBookingsBloc(
        getCustomerBookingsUseCase: _DummyGetCustomerBookingsUseCase(),
        cancelBookingUseCase: _DummyCancelBookingUseCase(),
        initialState: const CustomerBookingsLoaded(
          upcomingBookings: [],
          historyBookings: [],
          selectedTabIndex: 0,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: CustomerBookingsScreen(
            customerBookingsBloc: bloc,
            customerId: 'cust_sami',
          ),
          customerBookingsBloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BookingsEmptyState), findsOneWidget);
      expect(find.text('No Upcoming Bookings'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('No Booking History'), findsOneWidget);
    });

    testWidgets(
        'cancel booking opens confirmation dialog and handles cancel/dismiss',
        (WidgetTester tester) async {
      final bloc = CustomerBookingsBloc(
        getCustomerBookingsUseCase: _DummyGetCustomerBookingsUseCase(),
        cancelBookingUseCase: _DummyCancelBookingUseCase(),
        initialState: CustomerBookingsLoaded(
          upcomingBookings: [tUpcomingBooking],
          historyBookings: const [],
          selectedTabIndex: 0,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: CustomerBookingsScreen(
            customerBookingsBloc: bloc,
            customerId: 'cust_sami',
          ),
          customerBookingsBloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel Booking'), findsOneWidget);
      await tester.tap(find.text('Cancel Booking'));
      await tester.pumpAndSettle();

      expect(find.byType(CancelBookingConfirmationDialog), findsOneWidget);
      expect(find.text('Cancel Appointment'), findsOneWidget);
      expect(find.text('Keep Appointment'), findsOneWidget);
      expect(find.text('Yes, Cancel'), findsOneWidget);

      await tester.tap(find.text('Keep Appointment'));
      await tester.pumpAndSettle();
      expect(find.byType(CancelBookingConfirmationDialog), findsNothing);

      await tester.tap(find.text('Cancel Booking'));
      await tester.pumpAndSettle();
      expect(find.byType(CancelBookingConfirmationDialog), findsOneWidget);

      await tester.tap(find.text('Yes, Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(CancelBookingConfirmationDialog), findsNothing);
    });

    testWidgets('supports theme and locale toggling',
        (WidgetTester tester) async {
      final bloc = CustomerBookingsBloc(
        getCustomerBookingsUseCase: _DummyGetCustomerBookingsUseCase(),
        cancelBookingUseCase: _DummyCancelBookingUseCase(),
        initialState: CustomerBookingsLoaded(
          upcomingBookings: [tUpcomingBooking],
          historyBookings: const [],
          selectedTabIndex: 0,
        ),
      );
      addTearDown(bloc.close);

      final settings = AppSettingsController();

      await tester.pumpWidget(
        _buildTestHost(
          child: CustomerBookingsScreen(
            customerBookingsBloc: bloc,
            customerId: 'cust_sami',
          ),
          customerBookingsBloc: bloc,
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
      expect(find.text('حجوزاتي'), findsOneWidget);
      expect(find.text('المواعيد القادمة'), findsOneWidget);
      expect(find.text('السجل'), findsOneWidget);
      expect(find.text('إلغاء الموعد'), findsOneWidget);
      expect(find.text('مؤكد'), findsOneWidget);
    });
  });
}
