import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final effectiveIconColor = iconColor ?? AppColors.secondary;

    Widget card = Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: context.borderColor,
          width: AppSizes.hairline,
        ),
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                icon,
                size: AppSizes.iconSm + 2,
                color: effectiveIconColor,
              ),
            ],
          ),
          AppSpacing.verticalSm,
          Text(
            count,
            style: AppTextStyles.headlineMedium.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.verticalXs,
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: card,
      );
    }

    return card;
  }
}
