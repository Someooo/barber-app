import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/luxury_bottom_nav_bar.dart';
import '../bloc/customer_bookings_bloc.dart';
import '../bloc/customer_home_bloc.dart';
import 'customer_bookings_screen.dart';
import 'customer_home_screen.dart';
import 'customer_profile_screen.dart';

class CustomerShellScreen extends StatefulWidget {
  const CustomerShellScreen({
    super.key,
    this.customerHomeBloc,
    this.customerBookingsBloc,
  });

  final CustomerHomeBloc? customerHomeBloc;
  final CustomerBookingsBloc? customerBookingsBloc;

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  int _currentIndex = 0;

  CustomerHomeBloc _resolveHomeBloc() {
    if (widget.customerHomeBloc != null) {
      return widget.customerHomeBloc!;
    }
    if (!sl.isRegistered<CustomerHomeBloc>()) {
      registerCustomerDependencies(serviceLocator: sl);
    }
    return sl<CustomerHomeBloc>();
  }

  CustomerBookingsBloc _resolveBookingsBloc() {
    if (widget.customerBookingsBloc != null) {
      return widget.customerBookingsBloc!;
    }
    if (!sl.isRegistered<CustomerBookingsBloc>()) {
      registerCustomerDependencies(serviceLocator: sl);
    }
    return sl<CustomerBookingsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      LuxuryNavItem(
        label: context.l10n.customerNavHome,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      LuxuryNavItem(
        label: context.l10n.customerNavBookings,
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
      ),
      LuxuryNavItem(
        label: context.l10n.customerNavProfile,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerHomeBloc>(
          create: (context) => _resolveHomeBloc(),
        ),
        BlocProvider<CustomerBookingsBloc>(
          create: (context) => _resolveBookingsBloc(),
        ),
      ],
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            CustomerHomeScreen(),
            CustomerBookingsScreen(),
            CustomerProfileScreen(),
          ],
        ),
        bottomNavigationBar: LuxuryBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: navItems,
        ),
      ),
    );
  }
}
