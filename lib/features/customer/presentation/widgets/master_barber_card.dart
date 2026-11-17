import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/core/widgets/luxury_badge.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';

class MasterBarberCard extends StatelessWidget {
  const MasterBarberCard({
    super.key,
    required this.barber,
    this.onTap,
  });

  final BarberEntity barber;
  final VoidCallback? onTap;

  static const double cardWidth = 220.0;
  static const double cardHeight = 276.0;
  static const double photoHeaderHeight = 136.0;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.languageCode == 'AR';
    final specialty = isArabic ? barber.specialtyAr : barber.specialtyEn;
    final scheme = context.colors;

    return RepaintBoundary(
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Material(
          color: context.cardSurface,
          borderRadius: AppRadius.cardBorder,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.cardBorder,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.cardBorder,
                border: Border.all(
                  color: context.borderColor,
                  width: AppSizes.hairline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BarberPhotoHeader(barber: barber),
                  Expanded(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barber.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpacing.verticalXs,
                          Text(
                            specialty,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.yearsExperience(
                                    barber.experienceYears,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalXs,
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: AppSizes.iconSm,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarberPhotoHeader extends StatelessWidget {
  const _BarberPhotoHeader({required this.barber});

  final BarberEntity barber;

  @override
  Widget build(BuildContext context) {
    final imageUrl = barber.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return SizedBox(
      height: MasterBarberCard.photoHeaderHeight,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              RepaintBoundary(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _BarberPhotoFallback(name: barber.name),
                ),
              )
            else
              _BarberPhotoFallback(name: barber.name),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: AppOpacity.scrim),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: AppSpacing.sm,
              start: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.78),
                  borderRadius: AppRadius.stadiumBorder,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.6),
                    width: AppSizes.hairline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: AppSizes.iconSm,
                      color: AppColors.secondary,
                    ),
                    AppSpacing.horizontalXs,
                    Text(
                      barber.rating.toStringAsFixed(1),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              top: AppSpacing.sm,
              end: AppSpacing.sm,
              child: LuxuryBadge.status(
                label: barber.isAvailableToday
                    ? context.l10n.availableTodayBadge
                    : context.l10n.unavailableBadge,
                type: barber.isAvailableToday
                    ? LuxuryStatusType.confirmed
                    : LuxuryStatusType.cancelled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarberPhotoFallback extends StatelessWidget {
  const _BarberPhotoFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Center(
        child: LuxuryAvatar(
          fallbackLabel: name,
          size: AppSizes.avatarLg,
        ),
      ),
    );
  }
}
