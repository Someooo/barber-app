import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';

class LuxuryNavItem {
  const LuxuryNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badgeCount,
    this.showBadgeDot = false,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final int? badgeCount;
  final bool showBadgeDot;
}

class LuxuryBottomNavBar extends StatelessWidget {
  const LuxuryBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<LuxuryNavItem>? items;

  static const List<LuxuryNavItem> defaultItems = [
    LuxuryNavItem(
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    LuxuryNavItem(
      label: 'Bookings',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
    ),
    LuxuryNavItem(
      label: 'Schedule',
      icon: Icons.chair_outlined,
      activeIcon: Icons.chair,
    ),
    LuxuryNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  Widget _buildItem(
    BuildContext context, {
    required LuxuryNavItem item,
    required bool isSelected,
    required VoidCallback onItemTap,
  }) {
    final scheme = context.colors;
    final fg = isSelected ? scheme.primary : scheme.onSurfaceVariant;
    final iconData =
        (isSelected && item.activeIcon != null) ? item.activeIcon! : item.icon;

    return Expanded(
      child: InkWell(
        onTap: onItemTap,
        borderRadius: AppRadius.controlBorder,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    iconData,
                    size: AppSizes.iconLg,
                    color: fg,
                  ),
                  if (item.showBadgeDot || (item.badgeCount ?? 0) > 0)
                    PositionedDirectional(
                      top: -2,
                      end: -4,
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
              AppSpacing.verticalXs,
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: fg,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navItems = items ?? defaultItems;

    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        border: Border(
          top: BorderSide(
            color: context.borderColor,
            width: AppSizes.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              return _buildItem(
                context,
                item: navItems[index],
                isSelected: index == currentIndex,
                onItemTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}
