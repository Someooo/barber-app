import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';

class BarberScheduleFilterTab extends StatelessWidget {
  const BarberScheduleFilterTab({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: AppRadius.controlBorder,
          border: Border.all(
            color: context.borderColor,
            width: AppSizes.hairline,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: context.l10n.barberTodayTab,
                isSelected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
            AppSpacing.horizontalXs,
            Expanded(
              child: _SegmentButton(
                label: context.l10n.barberUpcomingTab,
                isSelected: selectedIndex == 1,
                onTap: () => onChanged(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Material(
      color: isSelected ? AppColors.secondary : Colors.transparent,
      borderRadius: AppRadius.controlBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.controlBorder,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.primary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
