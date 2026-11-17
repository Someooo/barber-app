import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import '../widgets/customer_identity_card.dart';
import '../widgets/customer_preferences_card.dart';
import '../widgets/sign_out_confirmation_dialog.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  Future<void> _onSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const SignOutConfirmationDialog(),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final fullName = user?.fullName ?? 'Customer';
    final phone = user?.phoneNumber ?? '';

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: LuxuryAppBar(
        title: context.l10n.profileScreenTitle,
        currentLanguage: context.languageCode,
        onLanguageToggle: () => context.toggleLocale(),
        onThemeToggle: () => context.toggleTheme(),
        isDarkMode: context.isDarkMode,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            CustomerIdentityCard(
              fullName: fullName,
              phoneNumber: phone,
              roleLabel: context.l10n.roleCustomerOption,
            ),
            AppSpacing.verticalLg,
            const CustomerPreferencesCard(),
            AppSpacing.verticalXl,
            RepaintBoundary(
              child: LuxurySecondaryButton(
                text: context.l10n.signOutButton,
                onPressed: () => _onSignOut(context),
                prefixIcon: const Icon(
                  Icons.logout,
                  size: AppSizes.iconSm,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
