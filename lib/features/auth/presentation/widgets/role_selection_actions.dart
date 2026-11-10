import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/widgets/widgets.dart';

class RoleSelectionActions extends StatelessWidget {
  const RoleSelectionActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LuxuryPrimaryButton(
          text: 'Barber Portal',
          prefixIcon: const Icon(Icons.content_cut, size: AppSizes.iconMd),
          onPressed: () => context.push(AppRoutes.barberLogin),
        ),
        AppSpacing.verticalMd,
        LuxurySecondaryButton(
          text: 'Customer Booking',
          prefixIcon:
              const Icon(Icons.event_available_outlined, size: AppSizes.iconMd),
          onPressed: () => context.push(AppRoutes.customerLogin),
        ),
      ],
    );
  }
}
