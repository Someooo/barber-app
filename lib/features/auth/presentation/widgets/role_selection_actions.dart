import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class RoleSelectionActions extends StatelessWidget {
  const RoleSelectionActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LuxuryPrimaryButton(
          text: l10n.barberPortal,
          prefixIcon: const Icon(Icons.content_cut, size: AppSizes.iconMd),
          onPressed: () => context.push(AppRoutes.barberLogin),
        ),
        AppSpacing.verticalMd,
        LuxurySecondaryButton(
          text: l10n.customerBooking,
          prefixIcon:
              const Icon(Icons.event_available_outlined, size: AppSizes.iconMd),
          onPressed: () => context.push(AppRoutes.customerLogin),
        ),
      ],
    );
  }
}
