import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import 'package:barber_app/features/customer/domain/entities/booking_status.dart';
import '../bloc/barber_dashboard_bloc.dart';
import '../bloc/barber_dashboard_state.dart';
import '../widgets/barber_appointment_card.dart';

class BarberHistoryScreen extends StatefulWidget {
  const BarberHistoryScreen({super.key});

  @override
  State<BarberHistoryScreen> createState() => _BarberHistoryScreenState();
}

class _BarberHistoryScreenState extends State<BarberHistoryScreen> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: LuxuryAppBar(
        title: l10n.barberNavHistory,
        currentLanguage: context.languageCode,
        onLanguageToggle: () => context.toggleLocale(),
        onThemeToggle: () => context.toggleTheme(),
        isDarkMode: context.isDarkMode,
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: Text(l10n.barberHistoryAllFilter),
                  selected: _filterIndex == 0,
                  selectedColor: AppColors.secondary,
                  onSelected: (_) => setState(() => _filterIndex = 0),
                ),
                ChoiceChip(
                  label: Text(l10n.barberHistoryCompletedFilter),
                  selected: _filterIndex == 1,
                  selectedColor: AppColors.secondary,
                  onSelected: (_) => setState(() => _filterIndex = 1),
                ),
                ChoiceChip(
                  label: Text(l10n.barberHistoryCancelledFilter),
                  selected: _filterIndex == 2,
                  selectedColor: AppColors.secondary,
                  onSelected: (_) => setState(() => _filterIndex = 2),
                ),
              ],
            ),
            AppSpacing.verticalMd,
            Expanded(
              child: BlocBuilder<BarberDashboardBloc, BarberDashboardState>(
                buildWhen: (prev, curr) {
                  if (prev is BarberDashboardLoaded &&
                      curr is BarberDashboardLoaded) {
                    return prev.historyBookings != curr.historyBookings;
                  }
                  return prev.runtimeType != curr.runtimeType;
                },
                builder: (context, state) {
                  if (state.isLoading || state.isInitial) {
                    return const Column(
                      children: [
                        LuxuryShimmerCard(height: 110.0),
                        AppSpacing.verticalMd,
                        LuxuryShimmerCard(height: 110.0),
                      ],
                    );
                  }
                  if (state is! BarberDashboardLoaded) {
                    return const SizedBox.shrink();
                  }

                  final filtered = state.historyBookings.where((b) {
                    if (_filterIndex == 1) {
                      return b.status == BookingStatus.completed;
                    }
                    if (_filterIndex == 2) {
                      return b.status == BookingStatus.cancelled;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noHistoryBookingsTitle,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => AppSpacing.verticalMd,
                    itemBuilder: (_, index) => BarberAppointmentCard(
                      booking: filtered[index],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
