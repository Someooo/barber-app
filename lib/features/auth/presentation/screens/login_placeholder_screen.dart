import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/theme/theme_context_x.dart';
import 'package:barber_app/l10n/app_localizations.dart';

/// Roles selectable from the welcome gate.
enum AuthRole { barber, customer }

/// Temporary destination for the role-specific login routes.
/// Replaced by the real login screens in a later phase.
class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key, required this.role});

  final AuthRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = context.colors;
    final roleLabel = switch (role) {
      AuthRole.barber => l10n.barberPortal,
      AuthRole.customer => l10n.customerBooking,
    };

    return Scaffold(
      appBar: AppBar(title: Text(roleLabel)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.loginPlaceholderTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  l10n.loginPlaceholderBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
