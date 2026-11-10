import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';
import 'luxury_avatar.dart';

/// Top navigation bar with brand monogram, title/caption, and action controls.
class LuxuryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LuxuryAppBar({
    super.key,
    this.title = 'BarberSync',
    this.subtitle,
    this.leadingMonogram,
    this.currentLanguage = 'EN',
    this.onLanguageToggle,
    this.onThemeToggle,
    this.isDarkMode,
    this.profileImage,
    this.profileFallbackLabel,
    this.onProfileTap,
    this.notificationCount,
    this.onNotificationTap,
    this.additionalActions,
    this.backgroundColor,
    this.showBottomBorder = true,
    this.showBrand = true,
  });

  /// Overrides the bar surface color (defaults to the theme surface).
  final Color? backgroundColor;

  /// Whether to draw the hairline divider under the bar.
  final bool showBottomBorder;

  /// When false, hides the monogram/title block so only actions are shown.
  final bool showBrand;

  final String title;
  final String? subtitle;
  final Widget? leadingMonogram;
  final String currentLanguage;
  final VoidCallback? onLanguageToggle;
  final VoidCallback? onThemeToggle;
  final bool? isDarkMode;
  final ImageProvider? profileImage;
  final String? profileFallbackLabel;
  final VoidCallback? onProfileTap;
  final int? notificationCount;
  final VoidCallback? onNotificationTap;
  final List<Widget>? additionalActions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  Widget _buildMonogram(BuildContext context) {
    if (leadingMonogram != null) return leadingMonogram!;

    return Container(
      width: AppSizes.avatarSm,
      height: AppSizes.avatarSm,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.controlBorder,
      ),
      child: const Center(
        child: Icon(
          Icons.content_cut,
          size: AppSizes.iconSm,
          color: AppColors.neutral,
        ),
      ),
    );
  }

  Widget _buildLanguageChip(BuildContext context) {
    final scheme = context.colors;
    return InkWell(
      onTap: onLanguageToggle,
      borderRadius: AppRadius.stadiumBorder,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: AppRadius.stadiumBorder,
          border: Border.all(
            color: context.borderColor,
            width: AppSizes.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate,
              size: AppSizes.iconSm,
              color: scheme.onSurfaceVariant,
            ),
            AppSpacing.horizontalXs,
            Text(
              currentLanguage.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(BuildContext context) {
    final darkMode = isDarkMode ?? context.isDarkMode;
    final scheme = context.colors;

    return IconButton(
      onPressed: onThemeToggle,
      iconSize: AppSizes.iconMd,
      tooltip: darkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      icon: Icon(
        darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: scheme.onSurface,
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final scheme = context.colors;
    final hasBadge = (notificationCount ?? 0) > 0;

    return IconButton(
      onPressed: onNotificationTap,
      iconSize: AppSizes.iconMd,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            color: scheme.onSurface,
          ),
          if (hasBadge)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Container(
                width: AppSizes.dot,
                height: AppSizes.dot,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return SafeArea(
      bottom: false,
      child: Container(
        height: AppSizes.appBarHeight,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.colors.surface,
          border: showBottomBorder
              ? Border(
                  bottom: BorderSide(
                    color: context.borderColor,
                    width: AppSizes.hairline,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            if (showBrand) ...[
              _buildMonogram(context),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      AppSpacing.verticalXs,
                      Text(
                        subtitle!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else
              const Spacer(),
            AppSpacing.horizontalSm,
            if (onLanguageToggle != null) ...[
              _buildLanguageChip(context),
              AppSpacing.horizontalXs,
            ],
            if (onThemeToggle != null) ...[
              _buildThemeButton(context),
            ],
            if (onNotificationTap != null) ...[
              _buildNotificationButton(context),
            ],
            if (profileImage != null || profileFallbackLabel != null) ...[
              AppSpacing.horizontalXs,
              LuxuryAvatar(
                image: profileImage,
                fallbackLabel: profileFallbackLabel,
                size: AppSizes.avatarSm,
                onTap: onProfileTap,
              ),
            ],
            if (additionalActions != null) ...additionalActions!,
          ],
        ),
      ),
    );
  }
}

