import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/owner_dashboard_event.dart';
import '../widgets/owner_kpi_grid.dart';

class OwnerOverviewScreen extends StatelessWidget {
  const OwnerOverviewScreen({
    super.key,
    required this.onNavigateToServices,
    required this.onNavigateToBarbers,
  });

  final VoidCallback onNavigateToServices;
  final VoidCallback onNavigateToBarbers;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final ownerName = authState is Authenticated
        ? authState.user.fullName
        : context.l10n.roleOwnerOption;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: LuxuryAppBar(
        title: context.l10n.ownerDashboardTitle,
        subtitle: ownerName,
        currentLanguage: context.languageCode,
        onLanguageToggle: () => context.toggleLocale(),
        onThemeToggle: () => context.toggleTheme(),
        isDarkMode: context.isDarkMode,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<OwnerDashboardBloc>()
              .add(const OwnerDashboardLoadRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: OwnerKpiGrid(
            onAddServiceTap: onNavigateToServices,
            onAddBarberTap: onNavigateToBarbers,
          ),
        ),
      ),
    );
  }
}
