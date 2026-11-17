import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/luxury_bottom_nav_bar.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/barber_dashboard_bloc.dart';
import '../bloc/barber_dashboard_event.dart';
import 'barber_dashboard_screen.dart';
import 'barber_history_screen.dart';
import 'barber_profile_screen.dart';

class BarberShellScreen extends StatefulWidget {
  const BarberShellScreen({
    super.key,
    this.barberDashboardBloc,
  });

  final BarberDashboardBloc? barberDashboardBloc;

  @override
  State<BarberShellScreen> createState() => _BarberShellScreenState();
}

class _BarberShellScreenState extends State<BarberShellScreen> {
  int _currentIndex = 0;
  late final BarberDashboardBloc _bloc;
  late final bool _ownsBloc;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.barberDashboardBloc == null;
    _bloc = widget.barberDashboardBloc ?? _resolveBloc();

    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    if (_bloc.state.isInitial && user != null) {
      _bloc.add(BarberDashboardLoadRequested(
        barberId: user.uid,
        barberName: user.fullName,
      ));
    }
  }

  BarberDashboardBloc _resolveBloc() {
    if (!sl.isRegistered<BarberDashboardBloc>()) {
      registerBarberDependencies(serviceLocator: sl);
    }
    return sl<BarberDashboardBloc>();
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      LuxuryNavItem(
        label: context.l10n.barberNavSchedule,
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
      ),
      LuxuryNavItem(
        label: context.l10n.barberNavHistory,
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
      ),
      LuxuryNavItem(
        label: context.l10n.barberNavProfile,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
    ];

    return BlocProvider<BarberDashboardBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            BarberDashboardScreen(),
            BarberHistoryScreen(),
            BarberProfileScreen(),
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
