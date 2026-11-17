import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/luxury_bottom_nav_bar.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/barber/presentation/bloc/barber_dashboard_bloc.dart';
import 'package:barber_app/features/barber/presentation/bloc/barber_dashboard_event.dart';
import 'package:barber_app/features/barber/presentation/bloc/barber_dashboard_state.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/owner_dashboard_event.dart';
import 'owner_barbers_screen.dart';
import 'owner_overview_screen.dart';
import 'owner_profile_screen.dart';
import 'owner_schedule_screen.dart';
import 'owner_services_screen.dart';

class OwnerShellScreen extends StatefulWidget {
  const OwnerShellScreen({
    super.key,
    this.ownerDashboardBloc,
    this.barberDashboardBloc,
  });

  final OwnerDashboardBloc? ownerDashboardBloc;
  final BarberDashboardBloc? barberDashboardBloc;

  @override
  State<OwnerShellScreen> createState() => _OwnerShellScreenState();
}

class _OwnerShellScreenState extends State<OwnerShellScreen> {
  int _currentIndex = 0;
  late final OwnerDashboardBloc _ownerBloc;
  late final bool _ownsOwnerBloc;
  late final BarberDashboardBloc _barberBloc;
  late final bool _ownsBarberBloc;
  StreamSubscription<BarberDashboardState>? _barberSub;

  @override
  void initState() {
    super.initState();
    _ownsOwnerBloc = widget.ownerDashboardBloc == null;
    _ownerBloc = widget.ownerDashboardBloc ?? _resolveOwnerBloc();
    _ownsBarberBloc = widget.barberDashboardBloc == null;
    _barberBloc = widget.barberDashboardBloc ?? _resolveBarberBloc();

    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    if (user != null && _barberBloc.state.isInitial) {
      _barberSub = _barberBloc.stream
          .where(
              (s) => s is BarberDashboardLoaded || s is BarberDashboardFailure)
          .take(1)
          .listen((_) {
        if (mounted && _ownerBloc.state.isInitial) {
          _ownerBloc.add(const OwnerDashboardLoadRequested());
        }
      });
      _barberBloc.add(BarberDashboardLoadRequested(
        barberId: user.uid,
        barberName: user.fullName,
      ));
    } else if (_ownerBloc.state.isInitial) {
      _ownerBloc.add(const OwnerDashboardLoadRequested());
    }
  }

  OwnerDashboardBloc _resolveOwnerBloc() {
    if (!sl.isRegistered<OwnerDashboardBloc>()) {
      registerOwnerDependencies(serviceLocator: sl);
    }
    return sl<OwnerDashboardBloc>();
  }

  BarberDashboardBloc _resolveBarberBloc() {
    if (!sl.isRegistered<BarberDashboardBloc>()) {
      registerBarberDependencies(serviceLocator: sl);
    }
    return sl<BarberDashboardBloc>();
  }

  @override
  void dispose() {
    _barberSub?.cancel();
    if (_ownsOwnerBloc) {
      _ownerBloc.close();
    }
    if (_ownsBarberBloc) {
      _barberBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navItems = [
      LuxuryNavItem(
        label: l10n.ownerNavOverview,
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
      ),
      LuxuryNavItem(
        label: l10n.myScheduleTab,
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
      ),
      LuxuryNavItem(
        label: l10n.ownerNavServices,
        icon: Icons.design_services_outlined,
        activeIcon: Icons.design_services,
      ),
      LuxuryNavItem(
        label: l10n.ownerNavBarbers,
        icon: Icons.content_cut_outlined,
        activeIcon: Icons.content_cut,
      ),
      LuxuryNavItem(
        label: l10n.ownerNavProfile,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<OwnerDashboardBloc>.value(value: _ownerBloc),
        BlocProvider<BarberDashboardBloc>.value(value: _barberBloc),
      ],
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            OwnerOverviewScreen(
              onNavigateToServices: () => setState(() => _currentIndex = 2),
              onNavigateToBarbers: () => setState(() => _currentIndex = 3),
            ),
            const OwnerScheduleScreen(),
            const OwnerServicesScreen(),
            const OwnerBarbersScreen(),
            const OwnerProfileScreen(),
          ],
        ),
        bottomNavigationBar: LuxuryBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: navItems,
        ),
      ),
    );
  }
}
