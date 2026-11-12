import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/features/auth/presentation/widgets/widgets.dart';

class WelcomeRoleScreen extends StatelessWidget {
  const WelcomeRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.colors.surface;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            LuxuryAppBar(
              showBrand: false,
              showBottomBorder: false,
              backgroundColor: surfaceColor,
              currentLanguage: context.languageCode,
              onLanguageToggle: context.toggleLocale,
              isDarkMode: context.isDarkMode,
              onThemeToggle: context.toggleTheme,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - (AppSpacing.lg * 2),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            const WelcomeBrandHeader(),
                            AppSpacing.verticalXl,
                            const Spacer(flex: 1),
                            RoleSelectionActions(
                              onLoginPressed: () =>
                                  context.push(AppRoutes.login),
                              onRegisterPressed: () =>
                                  context.push(AppRoutes.register),
                            ),
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
    );
  }
}
