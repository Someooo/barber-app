import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_text_field.dart';

class BarberCancelBookingDialog extends StatefulWidget {
  const BarberCancelBookingDialog({super.key});

  @override
  State<BarberCancelBookingDialog> createState() =>
      _BarberCancelBookingDialogState();
}

class _BarberCancelBookingDialogState extends State<BarberCancelBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_reasonController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;

    return AlertDialog(
      backgroundColor: context.cardSurface,
      title: Text(
        l10n.barberCancelTitle,
        style: AppTextStyles.titleMedium.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LuxuryTextField(
              controller: _reasonController,
              label: l10n.barberReasonLabel,
              hintText: l10n.barberReasonHint,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.barberReasonRequiredError;
                }
                return null;
              },
            ),
            AppSpacing.verticalXs,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
          child: Text(l10n.barberConfirmCancel),
        ),
      ],
    );
  }
}
