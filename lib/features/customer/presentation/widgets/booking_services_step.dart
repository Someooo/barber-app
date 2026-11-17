import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import '../bloc/booking_flow_bloc.dart';
import '../bloc/booking_flow_event.dart';
import '../bloc/booking_flow_state.dart';
import 'booking_service_card.dart';

class BookingServicesStep extends StatelessWidget {
  const BookingServicesStep({super.key});

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
                context.l10n.selectServicesTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              AppSpacing.verticalXs,
              Text(
                context.l10n.selectServicesSubtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalMd,
        BlocBuilder<BookingFlowBloc, BookingFlowState>(
          buildWhen: (prev, curr) =>
              prev.selectedServiceIds != curr.selectedServiceIds ||
              prev.availableServices != curr.availableServices,
          builder: (context, state) {
            final services = state.availableServices;
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
                final isSelected = state.isServiceSelected(service.id);
                return BookingServiceCard(
                  service: service,
                  isSelected: isSelected,
                  onTap: () {
                    context
                        .read<BookingFlowBloc>()
                        .add(BookingServiceToggled(service.id));
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
