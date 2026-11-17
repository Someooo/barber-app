import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/owner_dashboard_event.dart';
import '../bloc/owner_dashboard_state.dart';
import '../widgets/add_barber_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/owner_barber_card.dart';

class OwnerBarbersScreen extends StatelessWidget {
  const OwnerBarbersScreen({super.key});

  Future<void> _onAddBarber(BuildContext context) async {
    final result = await showModalBottomSheet<AddBarberResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddBarberSheet(),
    );
    if (result != null && context.mounted) {
      context.read<OwnerDashboardBloc>().add(OwnerBarberAdded(
            name: result.name,
            specialtyEn: result.specialtyEn,
            specialtyAr: result.specialtyAr,
            experienceYears: result.experienceYears,
            imageUrl: result.imageUrl,
          ));
    }
  }

  Future<void> _onDeleteBarber(BuildContext context, String barberId) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: l10n.ownerDeleteBarberTitle,
        message: l10n.ownerDeleteBarberMessage,
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<OwnerDashboardBloc>().add(OwnerBarberDeleted(barberId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: LuxuryAppBar(
        title: l10n.ownerNavBarbers,
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
            RepaintBoundary(
              child: LuxuryPrimaryButton(
                text: l10n.ownerAddNewBarber,
                onPressed: () => _onAddBarber(context),
              ),
            ),
            AppSpacing.verticalMd,
            Expanded(
              child: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
                buildWhen: (prev, curr) {
                  if (prev is OwnerDashboardLoaded &&
                      curr is OwnerDashboardLoaded) {
                    return prev.barbers != curr.barbers;
                  }
                  return prev.runtimeType != curr.runtimeType;
                },
                builder: (context, state) {
                  if (state.isLoading || state.isInitial) {
                    return const Column(
                      children: [
                        LuxuryShimmerCard(height: 90.0),
                        AppSpacing.verticalMd,
                        LuxuryShimmerCard(height: 90.0),
                      ],
                    );
                  }
                  if (state is! OwnerDashboardLoaded) {
                    return const SizedBox.shrink();
                  }
                  if (state.barbers.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.ownerNoBarbersTitle,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: state.barbers.length,
                    separatorBuilder: (_, __) => AppSpacing.verticalMd,
                    itemBuilder: (_, index) {
                      final barber = state.barbers[index];
                      return OwnerBarberCard(
                        barber: barber,
                        onDelete: () => _onDeleteBarber(context, barber.id),
                      );
                    },
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
