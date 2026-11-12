import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 96.0,
    this.borderRadius,
    this.fit = BoxFit.contain,
  });

  final double size;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark ? AppAssets.darkLogo : AppAssets.lightLogo;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: borderRadius ?? AppRadius.controlBorder,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: fit,
        ),
      ),
    );
  }
}
