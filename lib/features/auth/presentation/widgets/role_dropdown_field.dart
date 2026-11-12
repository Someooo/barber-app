import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/theme/theme_context_x.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/l10n/app_localizations.dart';

class RoleDropdownField extends StatelessWidget {
  const RoleDropdownField({
    super.key,
    required this.selectedRole,
    required this.onChanged,
    this.enabled = true,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = context.colors;

    final border = OutlineInputBorder(
      borderRadius: AppRadius.controlBorder,
      borderSide: BorderSide(
        color: context.borderColor,
        width: AppSizes.hairline,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: AppRadius.controlBorder,
      borderSide: const BorderSide(
        color: AppColors.secondary,
        width: AppSizes.focusBorder,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: AppRadius.controlBorder,
      borderSide: const BorderSide(
        color: AppColors.error,
        width: AppSizes.hairline,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
          child: Text(
            l10n.selectRoleLabel.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
        ),
        DropdownButtonFormField<UserRole>(
          key: ValueKey<UserRole>(selectedRole),
          initialValue: selectedRole,
          isExpanded: true,
          dropdownColor: context.cardSurface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: AppSizes.iconLg,
            color: scheme.onSurfaceVariant,
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.inputFill,
            enabled: enabled,
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
          ),
          items: [
            DropdownMenuItem<UserRole>(
              value: UserRole.customer,
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: AppSizes.iconMd,
                    color: scheme.onSurfaceVariant,
                  ),
                  AppSpacing.horizontalSm,
                  Text(
                    l10n.roleCustomerOption,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem<UserRole>(
              value: UserRole.barber,
              child: Row(
                children: [
                  Icon(
                    Icons.content_cut,
                    size: AppSizes.iconMd,
                    color: scheme.onSurfaceVariant,
                  ),
                  AppSpacing.horizontalSm,
                  Text(
                    l10n.roleBarberOption,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: enabled
              ? (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                }
              : null,
        ),
      ],
    );
  }
}
