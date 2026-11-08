import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';

enum LuxuryBadgeVariant { status, tier, liveSlot, custom }

enum LuxuryStatusType {
  completed,
  inProgress,
  pending,
  upcoming,
  confirmed,
  cancelled,
}

/// Stadium chip for status flags, craftsman levels, and availability counters.
class LuxuryBadge extends StatelessWidget {
  const LuxuryBadge({
    super.key,
    required this.label,
    this.variant = LuxuryBadgeVariant.status,
    this.statusType = LuxuryStatusType.pending,
    this.showDot = false,
    this.dotColor,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  const LuxuryBadge.status({
    super.key,
    required this.label,
    required LuxuryStatusType type,
    bool? dot,
    this.dotColor,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  })  : variant = LuxuryBadgeVariant.status,
        statusType = type,
        showDot = dot ?? (type == LuxuryStatusType.inProgress);

  const LuxuryBadge.tier({
    super.key,
    required this.label,
    this.showDot = false,
    this.dotColor,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  })  : variant = LuxuryBadgeVariant.tier,
        statusType = LuxuryStatusType.pending;

  const LuxuryBadge.liveSlot({
    super.key,
    required this.label,
    this.showDot = false,
    this.dotColor,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  })  : variant = LuxuryBadgeVariant.liveSlot,
        statusType = LuxuryStatusType.pending;

  final String label;
  final LuxuryBadgeVariant variant;
  final LuxuryStatusType statusType;
  final bool showDot;
  final Color? dotColor;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  ({Color bg, Color fg, Color dot}) _resolvePalette(BuildContext context) {
    final scheme = context.colors;

    switch (variant) {
      case LuxuryBadgeVariant.tier:
        return (
          bg: AppColors.secondary.withValues(alpha: AppOpacity.soft),
          fg: AppColors.secondary,
          dot: AppColors.secondary,
        );
      case LuxuryBadgeVariant.liveSlot:
        return (
          bg: context.borderColor,
          fg: AppColors.secondary,
          dot: AppColors.success,
        );
      case LuxuryBadgeVariant.custom:
        return (
          bg: backgroundColor ?? context.cardSurface,
          fg: foregroundColor ?? scheme.onSurface,
          dot: dotColor ?? AppColors.secondary,
        );
      case LuxuryBadgeVariant.status:
        switch (statusType) {
          case LuxuryStatusType.inProgress:
            return (
              bg: AppColors.secondary.withValues(alpha: AppOpacity.medium),
              fg: scheme.onSurface,
              dot: AppColors.secondary,
            );
          case LuxuryStatusType.confirmed:
            return (
              bg: AppColors.success.withValues(alpha: AppOpacity.soft),
              fg: AppColors.success,
              dot: AppColors.success,
            );
          case LuxuryStatusType.cancelled:
            return (
              bg: AppColors.error.withValues(alpha: AppOpacity.soft),
              fg: AppColors.error,
              dot: AppColors.error,
            );
          case LuxuryStatusType.completed:
          case LuxuryStatusType.pending:
          case LuxuryStatusType.upcoming:
            return (
              bg: context.borderColor,
              fg: scheme.onSurfaceVariant,
              dot: scheme.onSurfaceVariant,
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _resolvePalette(context);
    final fg = foregroundColor ?? palette.fg;
    final bg = backgroundColor ?? palette.bg;
    final isUppercase = variant == LuxuryBadgeVariant.tier ||
        variant == LuxuryBadgeVariant.liveSlot;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.stadiumBorder,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: AppSizes.dot,
                height: AppSizes.dot,
                decoration: BoxDecoration(
                  color: dotColor ?? palette.dot,
                  shape: BoxShape.circle,
                ),
              ),
              AppSpacing.horizontalXs,
            ],
            if (icon != null) ...[
              Icon(icon, size: AppSizes.iconSm, color: fg),
              AppSpacing.horizontalXs,
            ],
            Flexible(
              child: Text(
                isUppercase ? label.toUpperCase() : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef LuxuryChip = LuxuryBadge;

