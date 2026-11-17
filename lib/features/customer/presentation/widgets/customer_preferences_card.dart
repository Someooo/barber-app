import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';

class CustomerPreferencesCard extends StatelessWidget {
  const CustomerPreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return RepaintBoundary(
      child: Container(
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
              onTap: () => context.toggleTheme(),
              leading: RepaintBoundary(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.toggleTheme(),
                    borderRadius: AppRadius.controlBorder,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: AppRadius.controlBorder,
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          context.isDarkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: AppColors.secondary,
                          size: AppSizes.iconMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                context.l10n.themeToggleLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
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
              onTap: () => context.toggleLocale(),
              leading: RepaintBoundary(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.toggleLocale(),
                    borderRadius: AppRadius.controlBorder,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: AppRadius.controlBorder,
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.translate_outlined,
                          color: AppColors.secondary,
                          size: AppSizes.iconMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                context.l10n.languageToggleLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
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
    );
  }
}
