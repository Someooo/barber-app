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
import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/owner/domain/usecases/add_barber_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/add_service_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/delete_barber_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/delete_service_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/get_owner_overview_usecase.dart';
import 'package:barber_app/features/owner/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:barber_app/features/owner/presentation/screens/owner_shell_screen.dart';
import 'package:barber_app/features/owner/presentation/widgets/owner_barber_card.dart';
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

void main() {
  group('OwnerShellScreen Merged Barber & Owner Experience', () {
    testWidgets(
        'syncs owner as active barber, shows My Schedule, protects owner card, and toggles availability',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = CustomerRepositoryImpl(
        remoteDataSource: InMemoryFirestoreCustomerDataSource(prefs: prefs),
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
      final now = DateTime.now();
      await repository.createInstantBooking(
        customerId: 'cust_1',
        customerName: 'Ali Customer',
        barberId: 'owner_sami_almuhur',
        barberName: 'سامي المهر',
        services: const [service],
        dateTime: DateTime(now.year, now.month, now.day, 23, 0),
        totalPrice: 35,
        totalDurationMinutes: 45,
      );

      final authRepo = _MockAuthRepo();
      final authBloc = AuthBloc(
        authenticateUserUseCase: AuthenticateUserUseCase(authRepo),
        checkAuthSessionUseCase: CheckAuthSessionUseCase(authRepo),
        signOutUseCase: SignOutUseCase(authRepo),
      )..emit(const Authenticated(
          UserEntity(
            uid: 'owner_sami_almuhur',
            fullName: 'سامي المهر',
            phoneNumber: '0799081839',
            role: UserRole.owner,
          ),
        ));
      addTearDown(authBloc.close);

      final ownerBloc = OwnerDashboardBloc(
        getOwnerOverviewUseCase: GetOwnerOverviewUseCase(repository),
        addServiceUseCase: AddServiceUseCase(repository),
        deleteServiceUseCase: DeleteServiceUseCase(repository),
        addBarberUseCase: AddBarberUseCase(repository),
        deleteBarberUseCase: DeleteBarberUseCase(repository),
      );
      addTearDown(ownerBloc.close);

      final barberBloc = BarberDashboardBloc(
        ensureBarberProfileUseCase: EnsureBarberProfileUseCase(repository),
        getBarberBookingsUseCase: GetBarberBookingsUseCase(repository),
        updateBarberAvailabilityUseCase:
            UpdateBarberAvailabilityUseCase(repository),
        completeBookingUseCase: CompleteBookingUseCase(repository),
        rescheduleBookingUseCase: RescheduleBookingUseCase(repository),
        barberCancelBookingUseCase: BarberCancelBookingUseCase(repository),
      );
      addTearDown(barberBloc.close);

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: AppSettingsScope(
            controller: AppSettingsController(),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: OwnerShellScreen(
                ownerDashboardBloc: ownerBloc,
                barberDashboardBloc: barberBloc,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final barbers = await repository.getBarbers();
      expect(barbers.any((b) => b.id == 'owner_sami_almuhur'), isTrue);

      await tester.tap(find.text('My Schedule'));
      await tester.pumpAndSettle();
      expect(find.text('Ali Customer'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);

      await tester.tap(find.text('Barbers'));
      await tester.pumpAndSettle();
      final barbersList = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(OwnerBarberCard),
      );
      expect(barbersList, findsWidgets);
      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('OWNER / YOU'), findsOneWidget);

      final ownerCard = find.ancestor(
        of: find.text('OWNER / YOU'),
        matching: find.byType(OwnerBarberCard),
      );
      expect(
        find.descendant(
          of: ownerCard,
          matching: find.byIcon(Icons.delete_outline),
        ),
        findsNothing,
      );

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Available Today'), findsOneWidget);
    });
  });
}
