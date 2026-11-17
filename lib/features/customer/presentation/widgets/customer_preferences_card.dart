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
              leading: const Icon(
                Icons.palette_outlined,
                color: AppColors.secondary,
                size: AppSizes.iconMd,
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
              leading: const Icon(
                Icons.translate_outlined,
                color: AppColors.secondary,
                size: AppSizes.iconMd,
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
