import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/widgets.dart';

class RoleSelectionActions extends StatelessWidget {
  const RoleSelectionActions({
    super.key,
    this.onLoginPressed,
    this.onRegisterPressed,
  });

  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
            onPressed: onLoginPressed,
          ),
          AppSpacing.verticalMd,
          LuxuryOutlinedButton(
            text: l10n.registerButton,
            height: AppSizes.buttonHeight,
            isFullWidth: true,
            onPressed: onRegisterPressed,
          ),
        ],
      ),
    );
  }
}
