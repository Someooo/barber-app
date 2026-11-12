import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';

/// Primary action button with high-contrast theme inversion and loading state.
class LuxuryPrimaryButton extends StatelessWidget {
  const LuxuryPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.trailingIcon,
    this.showTrailingArrow = false,
    this.height = AppSizes.buttonHeight,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? trailingIcon;
  final bool showTrailingArrow;
  final double height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final effectiveRadius = borderRadius ?? AppRadius.controlBorder;
    final isEnabled = onPressed != null && !isLoading;

    final bgColor = backgroundColor ?? scheme.primary;
    final fgColor = foregroundColor ?? scheme.onPrimary;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: AppSizes.iconMd,
            height: AppSizes.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.loaderStroke,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          AppSpacing.horizontalSm,
        ] else if (prefixIcon != null) ...[
          prefixIcon!,
          AppSpacing.horizontalSm,
        ],
        Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            color: fgColor,
            letterSpacing: 0.5,
          ),
        ),
        if (!isLoading && (trailingIcon != null || showTrailingArrow)) ...[
          AppSpacing.horizontalSm,
          trailingIcon ??
              Icon(
                Icons.arrow_forward,
                size: AppSizes.iconSm,
                color: fgColor,
              ),
        ],
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor:
              bgColor.withValues(alpha: AppOpacity.disabled),
          disabledForegroundColor:
              fgColor.withValues(alpha: AppOpacity.scrim),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
          ),
        ),
        child: content,
      ),
    );
  }
}

/// Secondary button styled for biometric auth, passkeys, and alternative actions.
class LuxurySecondaryButton extends StatelessWidget {
  const LuxurySecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.trailingIcon,
    this.height = AppSizes.buttonHeight,
    this.borderRadius,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? trailingIcon;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final effectiveRadius = borderRadius ?? AppRadius.controlBorder;
    final isEnabled = onPressed != null && !isLoading;

    final bgColor = context.cardSurface;
    final fgColor = scheme.onSurface;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: AppSizes.iconMd,
            height: AppSizes.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.loaderStroke,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          AppSpacing.horizontalSm,
        ] else if (prefixIcon != null) ...[
          prefixIcon!,
          AppSpacing.horizontalSm,
        ],
        Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            color: fgColor,
          ),
        ),
        if (!isLoading && trailingIcon != null) ...[
          AppSpacing.horizontalSm,
          trailingIcon!,
        ],
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          side: BorderSide(
            color: context.borderColor,
            width: AppSizes.hairline,
          ),
          shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
          ),
          elevation: 0,
        ),
        child: content,
      ),
    );
  }
}

/// Minimalist outlined action button suited for table/timeline actions (e.g. Reschedule, Cancel).
class LuxuryOutlinedButton extends StatelessWidget {
  const LuxuryOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.prefixIcon,
    this.height = AppSizes.buttonHeightCompact,
    this.isFullWidth = false,
    this.borderRadius,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final Widget? prefixIcon;
  final double height;
  final bool isFullWidth;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final effectiveRadius = borderRadius ?? AppRadius.controlBorder;
    final color = textColor ?? scheme.onSurface;
    final border = borderColor ?? context.borderColor;

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: border, width: AppSizes.hairline),
          shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              AppSpacing.horizontalXs,
            ],
            Text(
              text,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

