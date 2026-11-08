import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';

/// Luxury circular avatar with presence indicator and graceful fallback.
class LuxuryAvatar extends StatelessWidget {
  const LuxuryAvatar({
    super.key,
    this.image,
    this.fallbackLabel,
    this.size = AppSizes.avatarMd,
    this.statusColor,
    this.onTap,
    this.semanticLabel,
  });

  final ImageProvider? image;
  final String? fallbackLabel;
  final double size;
  final Color? statusColor;
  final VoidCallback? onTap;
  final String? semanticLabel;

  static const double _dotRatio = 0.28;
  static const double _iconRatio = 0.55;

  Widget _buildFallback(BuildContext context) {
    final label = fallbackLabel?.trim();
    final scheme = context.colors;
    return ColoredBox(
      color: context.borderColor,
      child: Center(
        child: (label != null && label.isNotEmpty)
            ? Text(
                String.fromCharCode(label.runes.first).toUpperCase(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: scheme.onSurface,
                ),
              )
            : Icon(
                Icons.person_outline,
                size: size * _iconRatio,
                color: scheme.onSurfaceVariant,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = size * _dotRatio;

    Widget avatar = SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          ClipOval(
            child: image == null
                ? _buildFallback(context)
                : Image(
                    image: image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallback(context),
                  ),
          ),
          if (statusColor != null)
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: AppSizes.hairline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      avatar = InkResponse(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      );
    }

    return Semantics(
      label: semanticLabel,
      image: true,
      button: onTap != null,
      child: avatar,
    );
  }
}

