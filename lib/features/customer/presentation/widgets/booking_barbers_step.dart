import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import '../bloc/booking_flow_bloc.dart';
import '../bloc/booking_flow_event.dart';
import '../bloc/booking_flow_state.dart';
import 'booking_barber_card.dart';

class BookingBarbersStep extends StatelessWidget {
  const BookingBarbersStep({super.key});

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
                context.l10n.selectBarberTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              AppSpacing.verticalXs,
              Text(
                context.l10n.selectBarberSubtitle,
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
              prev.selectedBarber != curr.selectedBarber ||
              prev.availableBarbers != curr.availableBarbers,
          builder: (context, state) {
            final barbers = state.availableBarbers;
            if (barbers.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
              ),
              itemCount: barbers.length,
              separatorBuilder: (_, __) => AppSpacing.verticalMd,
              itemBuilder: (context, index) {
                final barber = barbers[index];
                final isSelected = state.selectedBarber?.id == barber.id;
                return BookingBarberCard(
                  barber: barber,
                  isSelected: isSelected,
                  onTap: () {
                    context
                        .read<BookingFlowBloc>()
                        .add(BookingBarberSelected(barber));
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
