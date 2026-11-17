import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/luxury_bottom_nav_bar.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/owner_dashboard_event.dart';
import 'owner_barbers_screen.dart';
import 'owner_overview_screen.dart';
import 'owner_profile_screen.dart';
import 'owner_services_screen.dart';

class OwnerShellScreen extends StatefulWidget {
  const OwnerShellScreen({
    super.key,
    this.ownerDashboardBloc,
  });

  final OwnerDashboardBloc? ownerDashboardBloc;

  @override
  State<OwnerShellScreen> createState() => _OwnerShellScreenState();
}

class _OwnerShellScreenState extends State<OwnerShellScreen> {
  int _currentIndex = 0;
  late final OwnerDashboardBloc _bloc;
  late final bool _ownsBloc;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.ownerDashboardBloc == null;
    _bloc = widget.ownerDashboardBloc ?? _resolveBloc();
    if (_bloc.state.isInitial) {
      _bloc.add(const OwnerDashboardLoadRequested());
    }
  }

  OwnerDashboardBloc _resolveBloc() {
    if (!sl.isRegistered<OwnerDashboardBloc>()) {
      registerOwnerDependencies(serviceLocator: sl);
    }
    return sl<OwnerDashboardBloc>();
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
    final l10n = context.l10n;
    final navItems = [
      LuxuryNavItem(
        label: l10n.ownerNavOverview,
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
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

    return BlocProvider<OwnerDashboardBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            OwnerOverviewScreen(
              onNavigateToServices: () => setState(() => _currentIndex = 1),
              onNavigateToBarbers: () => setState(() => _currentIndex = 2),
            ),
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
