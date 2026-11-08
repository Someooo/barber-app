import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';
import 'luxury_avatar.dart';
import 'luxury_badge.dart';
import 'luxury_buttons.dart';

/// Chronological timeline tile displaying a barber appointment slot.
class TimelineAppointmentTile extends StatelessWidget {
  const TimelineAppointmentTile({
    super.key,
    required this.time,
    required this.period,
    required this.customerName,
    required this.serviceName,
    this.serviceNotes,
    required this.durationText,
    required this.priceText,
    required this.statusLabel,
    this.statusType = LuxuryStatusType.pending,
    this.isActive = false,
    this.isLast = false,
    this.isPaid = false,
    this.customerAvatar,
    this.onReschedule,
    this.onCancel,
    this.onTap,
  });

  final String time; // e.g. "10:00"
  final String period; // e.g. "AM"
  final String customerName;
  final String serviceName;
  final String? serviceNotes;
  final String durationText; // e.g. "45 mins"
  final String priceText; // e.g. "$85"
  final String statusLabel; // e.g. "In Progress"
  final LuxuryStatusType statusType;
  final bool isActive;
  final bool isLast;
  final bool isPaid;
  final ImageProvider? customerAvatar;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  Widget _buildTimelineAxis(BuildContext context) {
    final scheme = context.colors;
    final timeColor = isActive ? AppColors.secondary : scheme.onSurface;
    final lineColor = isActive ? AppColors.secondary : context.borderColor;

    return SizedBox(
      width: AppSizes.timelineTimeWidth,
      child: Column(
        children: [
          Text(
            time,
            style: AppTextStyles.titleMedium.copyWith(
              color: timeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            period.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: timeColor.withValues(alpha: AppOpacity.scrim),
            ),
          ),
          AppSpacing.verticalSm,
          if (!isLast)
            Expanded(
              child: Container(
                width: isActive
                    ? AppSizes.timelineLineWidth + 1.0
                    : AppSizes.timelineLineWidth,
                color: lineColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final scheme = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: isActive ? AppColors.secondary : context.borderColor,
          width: isActive ? AppSizes.focusBorder : AppSizes.hairline,
        ),
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar, Customer Name, and Status Badge
          Row(
            children: [
              LuxuryAvatar(
                image: customerAvatar,
                fallbackLabel: customerName,
                size: AppSizes.avatarMd,
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalXs,
              LuxuryBadge.status(
                label: statusLabel,
                type: statusType,
              ),
            ],
          ),

          if (serviceNotes != null) ...[
            AppSpacing.verticalSm,
            Text(
              serviceNotes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: scheme.onSurfaceVariant.withValues(
                  alpha: AppOpacity.scrim + 0.1,
                ),
              ),
            ),
          ],

          AppSpacing.verticalMd,

          // Row 2: Duration, Price, and Action Controls
          Row(
            children: [
              Text(
                '$durationText • $priceText',
                style: AppTextStyles.labelSmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isPaid) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: AppSizes.iconSm,
                      color: AppColors.secondary,
                    ),
                    AppSpacing.horizontalXs,
                    Text(
                      'Paid',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                if (onReschedule != null) ...[
                  if (isActive)
                    LuxuryPrimaryButton(
                      text: 'Reschedule',
                      isFullWidth: false,
                      height: AppSizes.buttonHeightCompact,
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        size: AppSizes.iconSm,
                      ),
                      onPressed: onReschedule,
                    )
                  else
                    LuxuryOutlinedButton(
                      text: 'Reschedule',
                      onPressed: onReschedule,
                    ),
                  AppSpacing.horizontalSm,
                ],
                if (onCancel != null)
                  LuxuryOutlinedButton(
                    text: 'Cancel',
                    onPressed: onCancel,
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineAxis(context),
          AppSpacing.horizontalSm,
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: AppSpacing.md,
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.cardBorder,
                child: _buildCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

