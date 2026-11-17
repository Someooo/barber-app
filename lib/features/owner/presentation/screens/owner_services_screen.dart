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
import '../widgets/add_service_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/owner_service_card.dart';

class OwnerServicesScreen extends StatelessWidget {
  const OwnerServicesScreen({super.key});

  Future<void> _onAddService(BuildContext context) async {
    final result = await showModalBottomSheet<AddServiceResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddServiceSheet(),
    );
    if (result != null && context.mounted) {
      context.read<OwnerDashboardBloc>().add(OwnerServiceAdded(
            nameEn: result.nameEn,
            nameAr: result.nameAr,
            descriptionEn: result.descriptionEn,
            descriptionAr: result.descriptionAr,
            price: result.price,
            durationMinutes: result.durationMinutes,
            iconName: result.iconName,
          ));
    }
  }

  Future<void> _onDeleteService(BuildContext context, String serviceId) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: l10n.ownerDeleteServiceTitle,
        message: l10n.ownerDeleteServiceMessage,
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<OwnerDashboardBloc>().add(OwnerServiceDeleted(serviceId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: LuxuryAppBar(
        title: l10n.ownerNavServices,
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
                text: l10n.ownerAddNewService,
                onPressed: () => _onAddService(context),
              ),
            ),
            AppSpacing.verticalMd,
            Expanded(
              child: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
                buildWhen: (prev, curr) {
                  if (prev is OwnerDashboardLoaded &&
                      curr is OwnerDashboardLoaded) {
                    return prev.services != curr.services;
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
                  if (state.services.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.ownerNoServicesTitle,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: state.services.length,
                    separatorBuilder: (_, __) => AppSpacing.verticalMd,
                    itemBuilder: (_, index) {
                      final service = state.services[index];
                      return OwnerServiceCard(
                        service: service,
                        onDelete: () => _onDeleteService(context, service.id),
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
