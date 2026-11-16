import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';

class CustomerBookingsScreen extends StatelessWidget {
  const CustomerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: LuxuryAppBar(
        title: context.l10n.customerNavBookings,
        currentLanguage: context.languageCode,
        onLanguageToggle: () => context.toggleLocale(),
        onThemeToggle: () => context.toggleTheme(),
        isDarkMode: context.isDarkMode,
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72.0,
                height: 72.0,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: AppSizes.iconLg,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              AppSpacing.verticalMd,
              Text(
                context.l10n.myBookingsPlaceholderTitle,
                style: AppTextStyles.titleLarge.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              AppSpacing.verticalSm,
              Text(
                context.l10n.myBookingsPlaceholderSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
