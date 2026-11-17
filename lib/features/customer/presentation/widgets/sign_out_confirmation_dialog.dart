import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';

class SignOutConfirmationDialog extends StatelessWidget {
  const SignOutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Dialog(
      backgroundColor: context.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Padding(
        padding: AppSpacing.dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.logout,
                  size: AppSizes.iconLg,
                  color: AppColors.error,
                ),
              ),
            ),
            AppSpacing.verticalMd,
            Text(
              context.l10n.signOutDialogTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalSm,
            Text(
              context.l10n.signOutDialogMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalLg,
            Row(
              children: [
                Expanded(
                  child: LuxuryOutlinedButton(
                    text: context.l10n.cancelButton,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                AppSpacing.horizontalSm,
                Expanded(
                  child: LuxuryPrimaryButton(
                    text: context.l10n.signOutButton,
                    backgroundColor: AppColors.error,
                    height: AppSizes.buttonHeightCompact,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
