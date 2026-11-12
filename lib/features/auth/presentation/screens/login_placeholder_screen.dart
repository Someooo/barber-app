import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/theme/theme_context_x.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/l10n/app_localizations.dart';

/// Temporary lightweight placeholder screen used for routes pending full UI.
class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({
    super.key,
    this.titleBuilder,
  });

  final String Function(AppLocalizations l10n)? titleBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = context.colors;
    final settings = AppSettingsScope.of(context);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = settings.isDarkMode(platformBrightness);
    final title = titleBuilder?.call(l10n) ?? l10n.loginScreenTitle;

    return Scaffold(
      appBar: LuxuryAppBar(
        title: title,
        currentLanguage: settings.languageCode,
        onLanguageToggle: settings.toggleLocale,
        isDarkMode: isDark,
        onThemeToggle: () => settings.toggleTheme(platformBrightness),
      ),
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

