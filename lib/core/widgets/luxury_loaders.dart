import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';

/// Progress bar for splash sync and background synchronization tasks.
class ScheduleSyncProgressBar extends StatelessWidget {
  const ScheduleSyncProgressBar({
    super.key,
    this.progress = 0.98,
    this.statusLabel = 'Synchronizing Schedule...',
    this.showPercentage = true,
    this.height = AppSizes.progressBarHeight,
  });

  /// Value between 0.0 and 1.0.
  final double progress;
  final String statusLabel;
  final bool showPercentage;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentageText = '${(clampedProgress * 100).toInt()}%';
    final scheme = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                statusLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (showPercentage) ...[
              AppSpacing.horizontalSm,
              Text(
                percentageText,
                style: AppTextStyles.labelSmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        AppSpacing.verticalSm,
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.borderColor,
            borderRadius: AppRadius.stadiumBorder,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: AppDurations.progress,
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * clampedProgress,
                    height: height,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: AppRadius.stadiumBorder,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Shimmer skeleton loader with 16px card radius and custom dimensions.
class LuxuryShimmerCard extends StatefulWidget {
  const LuxuryShimmerCard({
    super.key,
    this.height = 120.0,
    this.width = double.infinity,
    this.borderRadius,
  });

  final double height;
  final double width;
  final BorderRadius? borderRadius;

  @override
  State<LuxuryShimmerCard> createState() => _LuxuryShimmerCardState();
}

class _LuxuryShimmerCardState extends State<LuxuryShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppRadius.cardBorder;
    final baseColor = context.cardSurface;
    final highlightColor = context.borderColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            gradient: LinearGradient(
              begin: Alignment(-2.0 + (_controller.value * 4.0), 0),
              end: Alignment(-1.0 + (_controller.value * 4.0), 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

