import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/core/errors/exceptions.dart';
import 'package:barber_app/core/router/app_router.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/auth/presentation/widgets/role_dropdown_field.dart';
import 'package:barber_app/l10n/app_localizations.dart';

void main() {
  group('Exclusive Owner Auth, RoleDropdownField & GoRouter Redirect', () {
    test('UserRole.fromString parses owner and serializes cleanly', () {
      expect(UserRole.fromString('owner'), UserRole.owner);
      expect(UserRole.owner.toStringValue(), 'owner');
    });

    test(
        'official owner phone (0799081839 / +962799081839) resolves to UserRole.owner and blocks others',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = AuthRemoteDataSourceImpl(prefs: prefs);

      final ownerUser = await ds.authenticateWithPhone(
        fullName: 'سامي المهر',
        phoneNumber: '+962799081839',
        password: AuthRemoteDataSourceImpl.officialOwnerPassword,
        selectedRole: UserRole.barber,
      );

      expect(ownerUser.role, UserRole.owner);
      expect(ownerUser.uid, AuthRemoteDataSourceImpl.officialOwnerUid);
      expect(ownerUser.fullName, 'سامي المهر');

      final restored = await ds.getCurrentUserSession();
      expect(restored?.role, UserRole.owner);

      await ds.signOut();
      expect(await ds.getCurrentUserSession(), isNull);

      await expectLater(
        () => ds.authenticateWithPhone(
          fullName: 'Unauthorized',
          phoneNumber: '0791111111',
          password: 'Password123',
          selectedRole: UserRole.owner,
        ),
        throwsA(isA<RoleMismatchException>()),
      );
    });

    testWidgets('RoleDropdownField exposes only Customer and Barber',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RoleDropdownField(
              selectedRole: UserRole.customer,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<UserRole>));
      await tester.pumpAndSettle();

      expect(find.text('Customer'), findsWidgets);
      expect(find.text('Barber'), findsWidgets);
      expect(find.text('Shop Owner'), findsNothing);
    });

    test('redirects owner to /owner/dashboard and blocks unauthorized roles',
        () {
      const ownerAuth = Authenticated(
        UserEntity(
          uid: 'owner_sami_almuhur',
          fullName: 'سامي المهر',
          phoneNumber: '0799081839',
          role: UserRole.owner,
        ),
      );
      const customerAuth = Authenticated(
        UserEntity(
          uid: 'cust_1',
          fullName: 'Customer',
          phoneNumber: '0790000001',
          role: UserRole.customer,
        ),
      );
      const barberAuth = Authenticated(
        UserEntity(
          uid: 'barber_1',
          fullName: 'Barber',
          phoneNumber: '0790000002',
          role: UserRole.barber,
        ),
      );

      expect(
        evaluateAuthRedirect(
          authState: ownerAuth,
          matchedLocation: AppRoutes.welcome,
        ),
        AppRoutes.ownerDashboard,
      );
      expect(
        evaluateAuthRedirect(
          authState: ownerAuth,
          matchedLocation: AppRoutes.customerHome,
        ),
        AppRoutes.ownerDashboard,
      );
      expect(
        evaluateAuthRedirect(
          authState: ownerAuth,
          matchedLocation: AppRoutes.barberDashboard,
        ),
        AppRoutes.ownerDashboard,
      );
      expect(
        evaluateAuthRedirect(
          authState: ownerAuth,
          matchedLocation: AppRoutes.ownerDashboard,
        ),
        isNull,
      );

      expect(
        evaluateAuthRedirect(
          authState: customerAuth,
          matchedLocation: AppRoutes.ownerDashboard,
        ),
        AppRoutes.customerHome,
      );
      expect(
        evaluateAuthRedirect(
          authState: barberAuth,
          matchedLocation: AppRoutes.ownerDashboard,
        ),
        AppRoutes.barberDashboard,
      );
    });
  });
}
