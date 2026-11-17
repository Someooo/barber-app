import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';

class BookingsSegmentedTab extends StatelessWidget {
  const BookingsSegmentedTab({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.borderColor.withValues(alpha: 0.3),
          borderRadius: AppRadius.controlBorder,
          border: Border.all(
            color: context.borderColor,
            width: AppSizes.hairline,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTab(
                context: context,
                index: 0,
                label: context.l10n.upcomingBookingsTab,
                icon: Icons.calendar_today_outlined,
                isSelected: selectedIndex == 0,
                scheme: scheme,
              ),
            ),
            AppSpacing.horizontalXs,
            Expanded(
              child: _buildTab(
                context: context,
                index: 1,
                label: context.l10n.historyBookingsTab,
                icon: Icons.history_outlined,
                isSelected: selectedIndex == 1,
                scheme: scheme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
    required ColorScheme scheme,
  }) {
    return Material(
      color: isSelected ? context.cardSurface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.control - 2),
      elevation: isSelected ? 1 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () => onTabChanged(index),
        borderRadius: BorderRadius.circular(AppRadius.control - 2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppSizes.iconSm,
                color:
                    isSelected ? AppColors.secondary : scheme.onSurfaceVariant,
              ),
              AppSpacing.horizontalXs,
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color:
                      isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
