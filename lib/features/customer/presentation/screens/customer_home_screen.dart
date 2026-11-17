import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/customer_home_bloc.dart';
import '../bloc/customer_home_event.dart';
import '../widgets/active_booking_hero_card.dart';
import '../widgets/barbers_showcase_section.dart';
import '../widgets/customer_home_error_banner.dart';
import '../widgets/quick_book_cta_banner.dart';
import '../widgets/services_catalog_section.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({
    super.key,
    this.customerId,
    this.customerName,
  });

  final String? customerId;
  final String? customerName;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _resolveCustomerId() {
    if (widget.customerId != null && widget.customerId!.isNotEmpty) {
      return widget.customerId!;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.uid;
    }
    return 'guest_customer';
  }

  String _resolveCustomerName() {
    if (widget.customerName != null && widget.customerName!.isNotEmpty) {
      return widget.customerName!;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.fullName;
    }
    return '';
  }

  String _resolveCustomerPhone() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.phoneNumber;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    final customerId = _resolveCustomerId();
    final currentState = context.read<CustomerHomeBloc>().state;
    if (currentState.isInitial) {
      context.read<CustomerHomeBloc>().add(
            CustomerHomeLoadRequested(customerId: customerId),
          );
    }
  }

  Future<void> _onRefresh() async {
    final customerId = _resolveCustomerId();
    context.read<CustomerHomeBloc>().add(
          CustomerHomeRefreshRequested(customerId: customerId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final customerId = _resolveCustomerId();
    final customerName = _resolveCustomerName();
    final customerPhone = _resolveCustomerPhone();
    final greetingSubtitle = customerName.isNotEmpty
        ? customerName
        : context.l10n.customerDefaultGreeting;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: LuxuryAppBar(
        title: context.l10n.customerHomeTitle,
        subtitle: greetingSubtitle,
        currentLanguage: context.languageCode,
        onLanguageToggle: () => context.toggleLocale(),
        onThemeToggle: () => context.toggleTheme(),
        isDarkMode: context.isDarkMode,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (customerName.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                      if (customerPhone.isNotEmpty) ...[
                        AppSpacing.verticalXs,
                        Text(
                          customerPhone,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.verticalMd,
              ],
              CustomerHomeErrorBanner(customerId: customerId),
              const ActiveBookingHeroCard(),
              AppSpacing.verticalMd,
              QuickBookCtaBanner(
                onBookPressed: () => context.push(AppRoutes.customerBook),
              ),
              AppSpacing.verticalLg,
              ServicesCatalogSection(
                onServiceTap: (service) => context.push(
                  AppRoutes.customerBook,
                  extra: {'serviceId': service.id},
                ),
              ),
              AppSpacing.verticalLg,
              BarbersShowcaseSection(
                onBarberTap: (barber) => context.push(
                  AppRoutes.customerBook,
                  extra: {'barberId': barber.id},
                ),
              ),
              AppSpacing.verticalXl,
            ],
          ),
        ),
      ),
    );
  }
}
