import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import 'package:barber_app/core/widgets/luxury_text_field.dart';

class AddServiceResult {
  const AddServiceResult({
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.durationMinutes,
    required this.iconName,
  });

  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double price;
  final int durationMinutes;
  final String iconName;
}

class AddServiceSheet extends StatefulWidget {
  const AddServiceSheet({super.key});

  @override
  State<AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<AddServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedIcon = 'content_cut';

  static const _iconOptions = [
    ('content_cut', Icons.content_cut),
    ('face', Icons.face),
    ('spa', Icons.spa),
    ('brush', Icons.brush),
    ('star', Icons.star),
  ];

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      AddServiceResult(
        nameEn: _nameEnController.text.trim(),
        nameAr: _nameArController.text.trim(),
        descriptionEn: _descEnController.text.trim(),
        descriptionAr: _descArController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        durationMinutes: int.parse(_durationController.text.trim()),
        iconName: _selectedIcon,
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
                  l10n.ownerAddNewService,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.verticalMd,
                LuxuryTextField(
                  controller: _nameEnController,
                  label: l10n.ownerServiceNameEn,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.ownerFieldRequired
                      : null,
                ),
                AppSpacing.verticalSm,
                LuxuryTextField(
                  controller: _nameArController,
                  label: l10n.ownerServiceNameAr,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.ownerFieldRequired
                      : null,
                ),
                AppSpacing.verticalSm,
                LuxuryTextField(
                  controller: _descEnController,
                  label: l10n.ownerServiceDescEn,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.ownerFieldRequired
                      : null,
                ),
                AppSpacing.verticalSm,
                LuxuryTextField(
                  controller: _descArController,
                  label: l10n.ownerServiceDescAr,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.ownerFieldRequired
                      : null,
                ),
                AppSpacing.verticalSm,
                Row(
                  children: [
                    Expanded(
                      child: LuxuryTextField(
                        controller: _priceController,
                        label: l10n.ownerServicePrice,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          final val = double.tryParse(v?.trim() ?? '');
                          if (val == null || val <= 0) {
                            return l10n.ownerInvalidNumber;
                          }
                          return null;
                        },
                      ),
                    ),
                    AppSpacing.horizontalSm,
                    Expanded(
                      child: LuxuryTextField(
                        controller: _durationController,
                        label: l10n.ownerServiceDuration,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final val = int.tryParse(v?.trim() ?? '');
                          if (val == null || val <= 0) {
                            return l10n.ownerInvalidNumber;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalMd,
                Text(
                  l10n.ownerServiceIcon,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.verticalXs,
                Wrap(
                  spacing: AppSpacing.sm,
                  children: _iconOptions.map((item) {
                    final selected = _selectedIcon == item.$1;
                    return ChoiceChip(
                      label: Icon(
                        item.$2,
                        size: AppSizes.iconSm,
                        color: selected ? AppColors.primary : scheme.onSurface,
                      ),
                      selected: selected,
                      selectedColor: AppColors.secondary,
                      onSelected: (_) =>
                          setState(() => _selectedIcon = item.$1),
                    );
                  }).toList(),
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
