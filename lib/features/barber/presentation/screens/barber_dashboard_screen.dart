import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/customer/domain/usecases/get_available_time_slots_usecase.dart';
import '../bloc/barber_dashboard_bloc.dart';
import '../bloc/barber_dashboard_event.dart';
import '../bloc/barber_dashboard_state.dart';
import '../widgets/barber_schedule_section.dart';

class BarberDashboardScreen extends StatelessWidget {
  const BarberDashboardScreen({
    super.key,
    this.barberId,
    this.barberName,
    this.getAvailableTimeSlotsUseCase,
  });

  final String? barberId;
  final String? barberName;
  final GetAvailableTimeSlotsUseCase? getAvailableTimeSlotsUseCase;

  String _resolveBarberId(BuildContext context) {
    if (barberId != null && barberId!.isNotEmpty) return barberId!;
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) return authState.user.uid;
    return 'barber_1';
  }

  String _resolveBarberName(BuildContext context) {
    if (barberName != null && barberName!.isNotEmpty) return barberName!;
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) return authState.user.fullName;
    return context.l10n.roleBarberOption;
  }

  void _onActionFeedback(BuildContext context, BarberDashboardState state) {
    if (state is! BarberDashboardLoaded) return;
    final l10n = context.l10n;
    String? message;
    if (state.lastActionSuccessCode == 'completed') {
      message = l10n.barberBookingCompletedSuccess;
    } else if (state.lastActionSuccessCode == 'rescheduled') {
      message = l10n.barberBookingRescheduledSuccess;
    } else if (state.lastActionSuccessCode == 'cancelled') {
      message = l10n.barberBookingCancelledSuccess;
    } else if (state.actionError != null) {
      message = state.actionError!.message;
    }

    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedId = _resolveBarberId(context);
    final resolvedName = _resolveBarberName(context);

    return BlocListener<BarberDashboardBloc, BarberDashboardState>(
      listenWhen: (prev, curr) {
        if (curr is! BarberDashboardLoaded) return false;
        final prevSuccess =
            prev is BarberDashboardLoaded ? prev.lastActionSuccessCode : null;
        final prevError =
            prev is BarberDashboardLoaded ? prev.actionError : null;
        return (curr.lastActionSuccessCode != null &&
                curr.lastActionSuccessCode != prevSuccess) ||
            (curr.actionError != null && curr.actionError != prevError);
      },
      listener: _onActionFeedback,
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: LuxuryAppBar(
          title: context.l10n.barberDashboardTitle,
          subtitle: resolvedName,
          currentLanguage: context.languageCode,
          onLanguageToggle: () => context.toggleLocale(),
          onThemeToggle: () => context.toggleTheme(),
          isDarkMode: context.isDarkMode,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<BarberDashboardBloc>().add(
                  BarberDashboardLoadRequested(
                    barberId: resolvedId,
                    barberName: resolvedName,
                  ),
                );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: BarberScheduleSection(
              barberId: resolvedId,
              getAvailableTimeSlotsUseCase: getAvailableTimeSlotsUseCase,
            ),
          ),
        ),
      ),
    );
  }
}
