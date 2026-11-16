import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

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
            AppSpacing.verticalMd,
            Center(
              child: LuxuryAvatar(
                fallbackLabel: fullName,
                size: 80.0,
              ),
            ),
            AppSpacing.verticalMd,
            Text(
              fullName,
              style: AppTextStyles.headlineSmall.copyWith(
                color: scheme.onSurface,
              ),
            ),
            if (phone.isNotEmpty) ...[
              AppSpacing.verticalXs,
              Text(
                phone,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            AppSpacing.verticalXl,
            Container(
              decoration: BoxDecoration(
                color: context.cardSurface,
                borderRadius: AppRadius.cardBorder,
                border: Border.all(
                  color: context.borderColor,
                  width: AppSizes.hairline,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.palette_outlined,
                      color: AppColors.secondary,
                    ),
                    title: Text(
                      context.l10n.themeToggleLabel,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: context.isDarkMode,
                      activeTrackColor: AppColors.secondary,
                      onChanged: (_) => context.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.translate_outlined,
                      color: AppColors.secondary,
                    ),
                    title: Text(
                      context.l10n.languageToggleLabel,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () => context.toggleLocale(),
                      child: Text(
                        context.languageCode,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXl,
            RepaintBoundary(
              child: LuxurySecondaryButton(
                text: context.l10n.signOutButton,
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                },
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
