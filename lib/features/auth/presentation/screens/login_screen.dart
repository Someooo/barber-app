import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/auth/presentation/utils/auth_failure_mapper.dart';
import 'package:barber_app/features/auth/presentation/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onSubmit,
    this.isLoading = false,
  });

  final LoginFormSubmitCallback? onSubmit;
  final bool isLoading;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ValueNotifier<bool> _isSubmitting = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isSubmitting.dispose();
    super.dispose();
  }

  Widget _buildInteractiveForm(BuildContext context) {
    final hasAuthBloc = context.read<AuthBloc?>() != null;
    if (!hasAuthBloc) {
      return LoginForm(
        onSubmit: widget.onSubmit,
        isLoading: widget.isLoading,
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting ||
          current is AuthFailureState,
      listener: (context, state) {
        _isSubmitting.value = state.isSubmitting;
        if (state is AuthFailureState) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: LoginForm(
        isLoading: widget.isLoading,
        isSubmittingListenable: _isSubmitting,
        errorBanner: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) =>
              previous.activeFailure != current.activeFailure,
          builder: (context, state) {
            final failure = state.activeFailure;
            if (failure == null) {
              return const SizedBox.shrink();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthErrorBanner(
                  message: mapAuthFailureToMessage(context, failure),
                ),
                AppSpacing.verticalMd,
              ],
            );
          },
        ),
        submitButtonBuilder: (context, handleSubmit) {
          return BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                previous.isSubmitting != current.isSubmitting,
            builder: (context, state) {
              return LuxuryPrimaryButton(
                text: context.l10n.continueButton,
                isLoading: widget.isLoading || state.isSubmitting,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.neutral,
                onPressed: handleSubmit,
              );
            },
          );
        },
        onSubmit: (fullName, phoneNumber, password, selectedRole) {
          FocusManager.instance.primaryFocus?.unfocus();
          widget.onSubmit?.call(fullName, phoneNumber, password, selectedRole);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        context.isDarkMode ? context.colors.surface : AppColors.cream;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: LuxuryAppBar(
        title: context.l10n.loginScreenTitle,
        backgroundColor: bgColor,
        showBackButton: true,
        onBackTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.welcome);
          }
        },
        currentLanguage: context.languageCode,
        onLanguageToggle: context.toggleLocale,
        isDarkMode: context.isDarkMode,
        onThemeToggle: context.toggleTheme,
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
