import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/core/router/app_router.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/features/auth/domain/entities/user_entity.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';

void main() {
  group('UserRole.owner & GoRouter Redirect Guard', () {
    test('UserRole.fromString parses owner and serializes cleanly', () {
      expect(UserRole.fromString('owner'), UserRole.owner);
      expect(UserRole.owner.toStringValue(), 'owner');
    });

    test('redirects owner to /owner/dashboard and blocks unauthorized roles',
        () {
      const ownerAuth = Authenticated(
        UserEntity(
          uid: 'owner_1',
          fullName: 'Owner',
          phoneNumber: '0790000000',
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
