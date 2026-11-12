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

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LuxuryPrimaryButton(
            text: l10n.loginButton,
            onPressed: () => context.push(AppRoutes.login),
          ),
          AppSpacing.verticalMd,
          LuxuryOutlinedButton(
            borderColor: Colors.black,
            text: l10n.registerButton,
            height: AppSizes.buttonHeight,
            isFullWidth: true,
            onPressed: () => context.push(AppRoutes.register),
          ),
        ],
      ),
    );
  }
}
