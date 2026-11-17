import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';

class OwnerPreferencesCard extends StatelessWidget {
  const OwnerPreferencesCard({super.key});

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
              leading: _LeadingIconBox(
                icon: context.isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              title: Text(
                context.l10n.themeToggleLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: _LuxuryOwnerSwitch(
                value: context.isDarkMode,
                onChanged: (_) => context.toggleTheme(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              onTap: () => context.toggleLocale(),
              leading: const _LeadingIconBox(icon: Icons.translate_outlined),
              title: Text(
                context.l10n.languageToggleLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.languageCode,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  _LuxuryOwnerSwitch(
                    value: context.languageCode == 'AR',
                    onChanged: (_) => context.toggleLocale(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIconBox extends StatelessWidget {
  const _LeadingIconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: AppSpacing.xxl,
        height: AppSpacing.xxl,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: AppOpacity.subtle),
          borderRadius: AppRadius.controlBorder,
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.4),
            width: AppSizes.focusBorder,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppColors.secondary,
            size: AppSizes.iconMd,
          ),
        ),
      ),
    );
  }
}

class _LuxuryOwnerSwitch extends StatelessWidget {
  const _LuxuryOwnerSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return RepaintBoundary(
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.secondary,
        inactiveThumbColor: isDark ? AppColors.neutral : AppColors.primary,
        inactiveTrackColor: isDark ? AppColors.borderDark : AppColors.cream,
        trackOutlineColor: WidgetStatePropertyAll(
          AppColors.secondary.withValues(alpha: 0.5),
        ),
        trackOutlineWidth: const WidgetStatePropertyAll(AppSizes.hairline),
      ),
    );
  }
}
