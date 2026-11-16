import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import '../bloc/customer_home_bloc.dart';
import '../bloc/customer_home_state.dart';
import 'service_card.dart';

class ServicesCatalogSection extends StatelessWidget {
  const ServicesCatalogSection({
    super.key,
    this.onServiceTap,
  });

  final ValueChanged<ServiceEntity>? onServiceTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.servicesSectionTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              AppSpacing.verticalXs,
              Text(
                context.l10n.servicesSectionSubtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalMd,
        BlocBuilder<CustomerHomeBloc, CustomerHomeState>(
          buildWhen: (prev, curr) =>
              prev.servicesOrEmpty != curr.servicesOrEmpty ||
              prev.isLoading != curr.isLoading,
          builder: (context, state) {
            if (state.isLoading) {
              return Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  children: const [
                    LuxuryShimmerCard(height: 100.0),
                    AppSpacing.verticalMd,
                    LuxuryShimmerCard(height: 100.0),
                  ],
                ),
              );
            }

            final services = state.servicesOrEmpty;
            if (services.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
              ),
              itemCount: services.length,
              separatorBuilder: (_, __) => AppSpacing.verticalMd,
              itemBuilder: (context, index) {
                final service = services[index];
                return ServiceCard(
                  service: service,
                  onTap: onServiceTap != null
                      ? () => onServiceTap!(service)
                      : null,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
