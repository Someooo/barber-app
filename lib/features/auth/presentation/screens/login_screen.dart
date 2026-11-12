import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/theme_context_x.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/auth/presentation/utils/auth_failure_mapper.dart';
import 'package:barber_app/features/auth/presentation/widgets/widgets.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    this.onSubmit,
    this.isLoading = false,
  });

  final LoginFormSubmitCallback? onSubmit;
  final bool isLoading;

  Widget _buildInteractiveForm(BuildContext context) {
    final hasAuthBloc = context.read<AuthBloc?>() != null;
    if (!hasAuthBloc) {
      return LoginForm(
        onSubmit: onSubmit,
        isLoading: isLoading,
      );
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthFailureState,
      listener: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      buildWhen: (previous, current) =>
          (previous is AuthLoading) != (current is AuthLoading) ||
          (previous is AuthFailureState) != (current is AuthFailureState) ||
          (previous is AuthFailureState &&
              current is AuthFailureState &&
              previous.failure != current.failure),
      builder: (context, state) {
        final effectiveLoading = isLoading || state is AuthLoading;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state is AuthFailureState) ...[
              AuthErrorBanner(
                message: mapAuthFailureToMessage(context, state.failure),
              ),
              AppSpacing.verticalMd,
            ],
            LoginForm(
              isLoading: effectiveLoading,
              onSubmit: (fullName, phoneNumber, password, selectedRole) {
                onSubmit?.call(fullName, phoneNumber, password, selectedRole);
                context.read<AuthBloc>().add(
                      AuthSubmitRequested(
                        fullName: fullName,
                        phoneNumber: phoneNumber,
                        password: password,
                        selectedRole: selectedRole,
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = AppSettingsScope.of(context);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = settings.isDarkMode(platformBrightness);
    final bgColor =
        context.isDarkMode ? context.colors.surface : AppColors.cream;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: LuxuryAppBar(
        title: l10n.loginScreenTitle,
        backgroundColor: bgColor,
        showBackButton: true,
        onBackTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.welcome);
          }
        },
        currentLanguage: settings.languageCode,
        onLanguageToggle: settings.toggleLocale,
        isDarkMode: isDark,
        onThemeToggle: () => settings.toggleTheme(platformBrightness),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LoginHeader(),
                      AppSpacing.verticalXl,
                      _buildInteractiveForm(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
