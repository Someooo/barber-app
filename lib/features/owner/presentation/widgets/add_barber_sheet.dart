import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import 'package:barber_app/core/widgets/luxury_text_field.dart';

class AddBarberResult {
  const AddBarberResult({
    required this.name,
    required this.specialtyEn,
    required this.specialtyAr,
    required this.experienceYears,
    this.imageUrl,
  });

  final String name;
  final String specialtyEn;
  final String specialtyAr;
  final int experienceYears;
  final String? imageUrl;
}

class AddBarberSheet extends StatefulWidget {
  const AddBarberSheet({super.key});

  @override
  State<AddBarberSheet> createState() => _AddBarberSheetState();
}

class _AddBarberSheetState extends State<AddBarberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyEnController = TextEditingController();
  final _specialtyArController = TextEditingController();
  final _experienceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyEnController.dispose();
    _specialtyArController.dispose();
    _experienceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final img = _imageUrlController.text.trim();
    Navigator.of(context).pop(
      AddBarberResult(
        name: _nameController.text.trim(),
        specialtyEn: _specialtyEnController.text.trim(),
        specialtyAr: _specialtyArController.text.trim(),
        experienceYears: int.parse(_experienceController.text.trim()),
        imageUrl: img.isNotEmpty ? img : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
        padding: AppSpacing.screenPadding,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.ownerAddNewBarber,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.verticalMd,
                LuxuryTextField(
                  controller: _nameController,
                  label: l10n.ownerBarberName,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.ownerFieldRequired
                      : null,
                ),
                AppSpacing.verticalSm,
                LuxuryTextField(
                  controller: _specialtyEnController,
                  label: l10n.ownerBarberSpecialtyEn,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.ownerFieldRequired
                      : null,
                ),
                AppSpacing.verticalSm,
                LuxuryTextField(
                  controller: _specialtyArController,
                  label: l10n.ownerBarberSpecialtyAr,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.ownerFieldRequired
                      : null,
                ),
                AppSpacing.verticalSm,
                LuxuryTextField(
                  controller: _experienceController,
                  label: l10n.ownerBarberExperience,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final val = int.tryParse(v?.trim() ?? '');
                    if (val == null || val <= 0) {
                      return l10n.ownerInvalidNumber;
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalSm,
                LuxuryTextField(
                  controller: _imageUrlController,
                  label: l10n.ownerBarberImageUrl,
                ),
                AppSpacing.verticalLg,
                RepaintBoundary(
                  child: LuxuryPrimaryButton(
                    text: l10n.ownerSaveButton,
                    onPressed: _onSave,
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
