import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/features/auth/presentation/widgets/widgets.dart';

class WelcomeRoleScreen extends StatelessWidget {
  const WelcomeRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = settings.isDarkMode(platformBrightness);

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              LuxuryAppBar(
                showBrand: false,
                showBottomBorder: false,
                backgroundColor: AppColors.cream,
                currentLanguage: settings.languageCode,
                onLanguageToggle: settings.toggleLocale,
                isDarkMode: isDark,
                onThemeToggle: () => settings.toggleTheme(platformBrightness),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              constraints.maxHeight - (AppSpacing.lg * 2),
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Spacer(flex: 2),
                              const WelcomeBrandHeader(),
                              AppSpacing.verticalXl,
                              const Spacer(flex: 1),
                              const RoleSelectionActions(),
                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
