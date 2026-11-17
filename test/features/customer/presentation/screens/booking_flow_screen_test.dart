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
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/customer/domain/usecases/create_instant_booking_usecase.dart';
import 'package:barber_app/features/customer/domain/usecases/get_available_time_slots_usecase.dart';
import 'package:barber_app/features/customer/domain/usecases/get_customer_home_data_usecase.dart';
import 'package:barber_app/features/customer/presentation/bloc/booking_flow_bloc.dart';
import 'package:barber_app/features/customer/presentation/bloc/booking_flow_state.dart';
import 'package:barber_app/features/customer/presentation/bloc/customer_home_bloc.dart';
import 'package:barber_app/features/customer/presentation/screens/booking_flow_screen.dart';
import 'package:barber_app/features/customer/presentation/widgets/booking_confirmation_sheet.dart';
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

Widget _buildTestHost({
  required Widget child,
  required BookingFlowBloc bookingFlowBloc,
  CustomerHomeBloc? customerHomeBloc,
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
      BlocProvider<BookingFlowBloc>.value(value: bookingFlowBloc),
      BlocProvider<AuthBloc>.value(value: authBloc),
      if (customerHomeBloc != null)
        BlocProvider<CustomerHomeBloc>.value(value: customerHomeBloc),
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
  const tService1 = ServiceEntity(
    id: 'srv_1',
    nameEn: 'Signature Haircut',
    nameAr: 'قصة شعر مميزة',
    descriptionEn: 'Precision cut',
    descriptionAr: 'قص شعر متقن',
    price: 35.0,
    durationMinutes: 45,
    iconName: 'content_cut',
  );

  const tService2 = ServiceEntity(
    id: 'srv_2',
    nameEn: 'Royal Shave',
    nameAr: 'حلاقة ملكية',
    descriptionEn: 'Straight razor shave',
    descriptionAr: 'حلاقة كلاسيكية بالموس',
    price: 25.0,
    durationMinutes: 30,
    iconName: 'face',
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

  final tSlot = DateTime(2026, 12, 1, 10, 0);

  group('BookingFlowScreen UI & Interaction', () {
    late InMemoryFirestoreCustomerDataSource dataSource;
    late CustomerRepositoryImpl repository;
    late GetAvailableTimeSlotsUseCase getAvailableTimeSlotsUseCase;
    late CreateInstantBookingUseCase createInstantBookingUseCase;
    late GetCustomerHomeDataUseCase getCustomerHomeDataUseCase;

    setUp(() {
      dataSource = InMemoryFirestoreCustomerDataSource();
      repository = CustomerRepositoryImpl(remoteDataSource: dataSource);
      getAvailableTimeSlotsUseCase = GetAvailableTimeSlotsUseCase(repository);
      createInstantBookingUseCase = CreateInstantBookingUseCase(repository);
      getCustomerHomeDataUseCase = GetCustomerHomeDataUseCase(repository);
    });

    testWidgets('renders all booking steps, services, barbers, and bottom bar',
        (WidgetTester tester) async {
      final bloc = BookingFlowBloc(
        getAvailableTimeSlotsUseCase: getAvailableTimeSlotsUseCase,
        createInstantBookingUseCase: createInstantBookingUseCase,
        getCustomerHomeDataUseCase: getCustomerHomeDataUseCase,
        initialState: BookingFlowState.initial().copyWith(
          availableServices: [tService1, tService2],
          availableBarbers: [tBarber],
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: BookingFlowScreen(
            bookingFlowBloc: bloc,
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          bookingFlowBloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book Appointment'), findsOneWidget);
      expect(find.text('Select Services'), findsOneWidget);
      expect(find.text('Signature Haircut'), findsOneWidget);
      expect(find.text('Royal Shave'), findsOneWidget);

      expect(find.text('Select Barber'), findsOneWidget);
      expect(find.text('Tariq Al-Hashemi'), findsOneWidget);

      expect(find.text('Date & Time'), findsOneWidget);
      expect(find.text('Notes (Optional)'), findsOneWidget);

      expect(find.text('Confirm Instant Booking'), findsOneWidget);
      expect(find.text('\$0'), findsOneWidget);
    });

    testWidgets(
        'confirm button is disabled until service, barber, and slot are selected',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final bloc = BookingFlowBloc(
        getAvailableTimeSlotsUseCase: getAvailableTimeSlotsUseCase,
        createInstantBookingUseCase: createInstantBookingUseCase,
        getCustomerHomeDataUseCase: getCustomerHomeDataUseCase,
        initialState: BookingFlowState.initial().copyWith(
          availableServices: [tService1, tService2],
          availableBarbers: [tBarber],
          selectedDate: tomorrow,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: BookingFlowScreen(
            bookingFlowBloc: bloc,
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          bookingFlowBloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.byType(LuxuryPrimaryButton);
      final initialButton = tester.widget<LuxuryPrimaryButton>(buttonFinder);
      expect(initialButton.onPressed, isNull);

      await tester.tap(find.text('Signature Haircut'));
      await tester.pumpAndSettle();
      expect(find.text('\$35'), findsWidgets);
      expect(find.text('45 min'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Tariq Al-Hashemi'),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Tariq Al-Hashemi'));
      await tester.pumpAndSettle();

      final firstSlotFinder = find.byIcon(Icons.access_time);
      if (firstSlotFinder.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          firstSlotFinder.first,
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(firstSlotFinder.first);
        await tester.pumpAndSettle();
      }

      final updatedButton = tester.widget<LuxuryPrimaryButton>(buttonFinder);
      expect(updatedButton.onPressed, isNotNull);
    });

    testWidgets(
        'multi-service selection sums prices and updates bottom summary bar',
        (WidgetTester tester) async {
      final bloc = BookingFlowBloc(
        getAvailableTimeSlotsUseCase: getAvailableTimeSlotsUseCase,
        createInstantBookingUseCase: createInstantBookingUseCase,
        getCustomerHomeDataUseCase: getCustomerHomeDataUseCase,
        initialState: BookingFlowState.initial().copyWith(
          availableServices: [tService1, tService2],
          availableBarbers: [tBarber],
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: BookingFlowScreen(
            bookingFlowBloc: bloc,
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          bookingFlowBloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Signature Haircut'));
      await tester.pumpAndSettle();
      expect(find.text('\$35'), findsWidgets);

      await tester.tap(find.text('Royal Shave'));
      await tester.pumpAndSettle();
      expect(find.text('\$60'), findsOneWidget);
      expect(find.text('75 min'), findsWidgets);

      await tester.tap(find.text('Signature Haircut'));
      await tester.pumpAndSettle();
      expect(find.text('\$25'), findsWidgets);
      expect(find.text('30 min'), findsWidgets);
    });

    testWidgets(
        'instant confirmation flow opens BookingConfirmationSheet with confirmed badge',
        (WidgetTester tester) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final tomorrowSlots = await getAvailableTimeSlotsUseCase(
        barberId: tBarber.id,
        date: tomorrowDate,
        durationMinutes: 45,
      );
      final validSlot = tomorrowSlots.first;

      final readyBloc = BookingFlowBloc(
        getAvailableTimeSlotsUseCase: getAvailableTimeSlotsUseCase,
        createInstantBookingUseCase: createInstantBookingUseCase,
        getCustomerHomeDataUseCase: getCustomerHomeDataUseCase,
        initialState: BookingFlowState.initial(tomorrowDate).copyWith(
          availableServices: [tService1],
          availableBarbers: [tBarber],
          selectedServiceIds: {'srv_1'},
          selectedBarber: () => tBarber,
          selectedDate: tomorrowDate,
          selectedSlot: () => validSlot,
          availableSlots: tomorrowSlots,
          totalPrice: 35.0,
          totalDurationMinutes: 45,
        ),
      );
      addTearDown(readyBloc.close);

      await tester.pumpWidget(
        _buildTestHost(
          child: BookingFlowScreen(
            bookingFlowBloc: readyBloc,
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          bookingFlowBloc: readyBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirm Instant Booking'), findsOneWidget);
      await tester.tap(find.text('Confirm Instant Booking'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingConfirmationSheet), findsOneWidget);
      expect(find.text('Instant Booking Confirmed!'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(BookingConfirmationSheet), findsNothing);
    });

    testWidgets('supports Light and Dark themes and EN and AR locales',
        (WidgetTester tester) async {
      final readyBloc = BookingFlowBloc(
        getAvailableTimeSlotsUseCase: getAvailableTimeSlotsUseCase,
        createInstantBookingUseCase: createInstantBookingUseCase,
        getCustomerHomeDataUseCase: getCustomerHomeDataUseCase,
        initialState: BookingFlowState.initial().copyWith(
          availableServices: [tService1],
          availableBarbers: [tBarber],
          selectedServiceIds: {'srv_1'},
          selectedBarber: () => tBarber,
          selectedSlot: () => tSlot,
          availableSlots: [tSlot],
          totalPrice: 35.0,
          totalDurationMinutes: 45,
        ),
      );
      addTearDown(readyBloc.close);

      final settings = AppSettingsController();

      await tester.pumpWidget(
        _buildTestHost(
          child: BookingFlowScreen(
            bookingFlowBloc: readyBloc,
            customerId: 'cust_sami',
            customerName: 'Sami Almuhur',
          ),
          bookingFlowBloc: readyBloc,
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
      expect(find.text('حجز موعد'), findsOneWidget);
      expect(find.text('اختر الخدمات'), findsOneWidget);
      expect(find.text('قصة شعر مميزة'), findsOneWidget);
      expect(find.text('اختر الحلاق'), findsOneWidget);
      expect(find.text('كبير الحلاقين'), findsOneWidget);
      expect(find.text('تأكيد الحجز الفوري'), findsOneWidget);
      expect(find.text('35 د.أ'), findsWidgets);
    });
  });
}
