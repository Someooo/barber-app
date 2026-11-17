import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';

class CustomerIdentityCard extends StatelessWidget {
  const CustomerIdentityCard({
    super.key,
    required this.fullName,
    required this.phoneNumber,
    required this.roleLabel,
    this.profileImagePath,
    this.onPickPhoto,
    this.onRemovePhoto,
  });

  final String fullName;
  final String phoneNumber;
  final String roleLabel;
  final String? profileImagePath;
  final Future<void> Function(ImageSource source)? onPickPhoto;
  final Future<void> Function()? onRemovePhoto;

  File? _resolveValidImageFile() {
    final path = profileImagePath;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  Future<void> _showPhotoOptions(BuildContext context, bool hasPhoto) async {
    if (onPickPhoto == null && onRemovePhoto == null) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        final scheme = sheetContext.colors;

        return Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.changeProfilePhoto,
                style: AppTextStyles.titleMedium.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.verticalMd,
              if (onPickPhoto != null) ...[
                ListTile(
                  contentPadding: EdgeInsetsDirectional.zero,
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: scheme.onSurface,
                  ),
                  title: Text(
                    l10n.chooseFromGallery,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onPickPhoto!(ImageSource.gallery);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsetsDirectional.zero,
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: scheme.onSurface,
                  ),
                  title: Text(
                    l10n.takePhoto,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onPickPhoto!(ImageSource.camera);
                  },
                ),
              ],
              if (hasPhoto && onRemovePhoto != null)
                ListTile(
                  contentPadding: EdgeInsetsDirectional.zero,
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  title: Text(
                    l10n.removePhoto,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onRemovePhoto!();
                  },
                ),
              AppSpacing.verticalSm,
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final imageFile = _resolveValidImageFile();
    final hasPhoto = imageFile != null;
    final isInteractive = onPickPhoto != null || onRemovePhoto != null;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: AppSpacing.cardPadding,
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
            SizedBox(
              width: AppSizes.avatarLg + AppSpacing.md,
              height: AppSizes.avatarLg + AppSpacing.md,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  LuxuryAvatar(
                    image: hasPhoto ? FileImage(imageFile) : null,
                    fallbackLabel: fullName,
                    size: AppSizes.avatarLg,
                    semanticLabel: context.l10n.changeProfilePhoto,
                    onTap: isInteractive
                        ? () => _showPhotoOptions(context, hasPhoto)
                        : null,
                  ),
                  if (isInteractive)
                    PositionedDirectional(
                      end: -AppSpacing.xs,
                      bottom: -AppSpacing.xs,
                      child: RepaintBoundary(
                        child: Semantics(
                          button: true,
                          label: context.l10n.changeProfilePhoto,
                          child: InkResponse(
                            onTap: () => _showPhotoOptions(context, hasPhoto),
                            customBorder: const CircleBorder(),
                            child: SizedBox(
                              width: AppSpacing.xxl,
                              height: AppSpacing.xxl,
                              child: Center(
                                child: Container(
                                  width: AppSizes.iconLg,
                                  height: AppSizes.iconLg,
                                  decoration: BoxDecoration(
                                    color: context.cardSurface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondary,
                                      width: AppSizes.focusBorder,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: AppSizes.iconSm,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            AppSpacing.verticalMd,
            Text(
              fullName,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (phoneNumber.isNotEmpty) ...[
              AppSpacing.verticalXs,
              Text(
                phoneNumber,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            AppSpacing.verticalSm,
            LuxuryBadge.tier(
              label: roleLabel,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              foregroundColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
