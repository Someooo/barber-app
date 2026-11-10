import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/theme/theme_context_x.dart';

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key, required this.roleLabel});

  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text(roleLabel)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              '$roleLabel — coming soon',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
