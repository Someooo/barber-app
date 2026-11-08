import 'dart:ui';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';
import 'luxury_avatar.dart';

/// Editorial image card with frosted badge and headline typography.
class HeroCardBanner extends StatelessWidget {
  const HeroCardBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeText = 'MAISON DE BEAUTÉ',
    this.backgroundImage,
    this.watermarkIcon = Icons.spa_outlined,
    this.height = AppSizes.heroBannerHeight,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? badgeText;
  final ImageProvider? backgroundImage;
  final IconData? watermarkIcon;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: AppRadius.cardBorder,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          image: backgroundImage != null
              ? DecorationImage(
                  image: backgroundImage!,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary.withValues(alpha: AppOpacity.scrim),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Stack(
          children: [
            // Dark gradient scrim
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: AppOpacity.scrim),
                      AppColors.primary.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Text and badge content
            PositionedDirectional(
              start: AppSpacing.md,
              bottom: AppSpacing.md,
              end: AppSpacing.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badgeText != null) ...[
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: AppRadius.stadiumBorder,
                      ),
                      child: Text(
                        badgeText!.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.neutral,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    AppSpacing.verticalSm,
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neutral.withValues(
                        alpha: AppOpacity.scrim + 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Frosted translucent watermark icon
            if (watermarkIcon != null)
              PositionedDirectional(
                end: AppSpacing.md,
                bottom: AppSpacing.md,
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: AppSizes.frostBlur,
                      sigmaY: AppSizes.frostBlur,
                    ),
                    child: Container(
                      width: AppSizes.avatarMd,
                      height: AppSizes.avatarMd,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(
                          alpha: AppOpacity.soft,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(
                            alpha: AppOpacity.medium,
                          ),
                          width: AppSizes.hairline,
                        ),
                      ),
                      child: Icon(
                        watermarkIcon,
                        color: AppColors.neutral,
                        size: AppSizes.iconMd,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: content,
      );
    }

    return content;
  }
}

/// Obsidian card summarizing the user's immediate next appointment.
class ActiveAppointmentBanner extends StatelessWidget {
  const ActiveAppointmentBanner({
    super.key,
    required this.serviceName,
    required this.barberName,
    this.chairNumber = '01',
    required this.scheduleTime,
    this.scheduleTimeArabic,
    this.countdownText = 'In 2h 15m',
    this.barberAvatar,
    this.onDetailsTap,
  });

  final String serviceName;
  final String barberName;
  final String chairNumber;
  final String scheduleTime;
  final String? scheduleTimeArabic;
  final String countdownText;
  final ImageProvider? barberAvatar;
  final VoidCallback? onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: AppColors.borderDark,
          width: AppSizes.hairline,
        ),
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Status pill + Live Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: AppRadius.stadiumBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSizes.dot,
                      height: AppSizes.dot,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.horizontalXs,
                    Text(
                      'NEXT APPOINTMENT',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neutral,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: AppRadius.stadiumBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: AppSizes.iconSm,
                      color: AppColors.secondary,
                    ),
                    AppSpacing.horizontalXs,
                    Text(
                      countdownText,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,

          // Center: Barber avatar, service info, Details button
          Row(
            children: [
              LuxuryAvatar(
                image: barberAvatar,
                fallbackLabel: barberName,
                size: AppSizes.avatarLg,
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.neutral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      'with $barberName • Chair #$chairNumber',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neutral.withValues(
                          alpha: AppOpacity.scrim + 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalSm,
              if (onDetailsTap != null)
                InkWell(
                  onTap: onDetailsTap,
                  borderRadius: AppRadius.controlBorder,
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: AppRadius.controlBorder,
                      border: Border.all(
                        color: AppColors.borderDark,
                        width: AppSizes.hairline,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Details',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.neutral,
                          ),
                        ),
                        AppSpacing.horizontalXs,
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: AppSizes.iconSm - 4,
                          color: AppColors.neutral,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.verticalMd,

          // Footer: Time representation in English and Arabic
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardDark.withValues(alpha: AppOpacity.scrim),
              borderRadius: AppRadius.controlBorder,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppSizes.iconSm,
                  color: AppColors.secondary,
                ),
                AppSpacing.horizontalSm,
                Expanded(
                  child: Text(
                    scheduleTime,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neutral,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (scheduleTimeArabic != null)
                  Text(
                    scheduleTimeArabic!,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neutral.withValues(
                        alpha: AppOpacity.scrim + 0.1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

