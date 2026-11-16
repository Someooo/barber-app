import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import '../bloc/customer_home_bloc.dart';
import '../bloc/customer_home_event.dart';
import '../bloc/customer_home_state.dart';

class CustomerHomeErrorBanner extends StatelessWidget {
  const CustomerHomeErrorBanner({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerHomeBloc, CustomerHomeState>(
      buildWhen: (prev, curr) => prev.isFailure != curr.isFailure,
      builder: (context, state) {
        if (state is! CustomerHomeFailure) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.cardBorder,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: AppSizes.hairline,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: AppSizes.iconMd,
                      ),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Text(
                          state.message.isNotEmpty
                              ? state.message
                              : context.l10n.genericErrorMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSm,
                  RepaintBoundary(
                    child: LuxurySecondaryButton(
                      text: context.l10n.retryButton,
                      onPressed: () {
                        context.read<CustomerHomeBloc>().add(
                              CustomerHomeLoadRequested(customerId: customerId),
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
