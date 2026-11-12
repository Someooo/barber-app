import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({
    super.key,
    this.titleBuilder,
  });

  final String Function(AppLocalizations l10n)? titleBuilder;

  Widget _buildSessionSummary(BuildContext context) {
    final hasAuthBloc = context.read<AuthBloc?>() != null;
    if (!hasAuthBloc) {
      return const SizedBox.shrink();
    }

    final scheme = context.colors;
    final l10n = context.l10n;

    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state is Authenticated) ...[
              AppSpacing.verticalLg,
              Text(
                state.user.fullName,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              AppSpacing.verticalXs,
              Text(
                state.user.phoneNumber,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            AppSpacing.verticalLg,
            LuxuryOutlinedButton(
              text: l10n.signOutButton,
              prefixIcon: Icon(
                Icons.logout,
                size: AppSizes.iconSm,
                color: scheme.onSurface,
              ),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    final title = titleBuilder?.call(l10n) ?? l10n.loginScreenTitle;

    return Scaffold(
      appBar: LuxuryAppBar(
        title: title,
        currentLanguage: context.languageCode,
        onLanguageToggle: context.toggleLocale,
        isDarkMode: context.isDarkMode,
        onThemeToggle: context.toggleTheme,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
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
                _buildSessionSummary(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
