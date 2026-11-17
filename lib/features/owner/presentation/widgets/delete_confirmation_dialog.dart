import 'package:flutter/material.dart';

import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: context.cardSurface,
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
          child: Text(l10n.ownerDeleteConfirm),
        ),
      ],
    );
  }
}
