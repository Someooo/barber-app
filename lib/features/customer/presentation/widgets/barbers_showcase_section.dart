import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import 'package:barber_app/features/customer/domain/entities/barber_entity.dart';
import '../bloc/customer_home_bloc.dart';
import '../bloc/customer_home_state.dart';
import 'master_barber_card.dart';

class BarbersShowcaseSection extends StatelessWidget {
  const BarbersShowcaseSection({
    super.key,
    this.onBarberTap,
  });

  final ValueChanged<BarberEntity>? onBarberTap;

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
                context.l10n.barbersSectionTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              AppSpacing.verticalXs,
              Text(
                context.l10n.barbersSectionSubtitle,
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
              prev.barbersOrEmpty != curr.barbersOrEmpty ||
              prev.isLoading != curr.isLoading,
          builder: (context, state) {
            if (state.isLoading) {
              return SizedBox(
                height: MasterBarberCard.cardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: 2,
                  separatorBuilder: (_, __) => AppSpacing.horizontalMd,
                  itemBuilder: (_, __) => const SizedBox(
                    width: MasterBarberCard.cardWidth,
                    child: LuxuryShimmerCard(
                      height: MasterBarberCard.cardHeight,
                    ),
                  ),
                ),
              );
            }

            final barbers = state.barbersOrEmpty;
            if (barbers.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: MasterBarberCard.cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                ),
                itemCount: barbers.length,
                separatorBuilder: (_, __) => AppSpacing.horizontalMd,
                itemBuilder: (context, index) {
                  final barber = barbers[index];
                  return MasterBarberCard(
                    barber: barber,
                    onTap:
                        onBarberTap != null ? () => onBarberTap!(barber) : null,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
