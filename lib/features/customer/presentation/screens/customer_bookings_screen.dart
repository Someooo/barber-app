import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/core/widgets/luxury_loaders.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/customer_bookings_bloc.dart';
import '../bloc/customer_bookings_event.dart';
import '../bloc/customer_bookings_state.dart';
import '../bloc/customer_home_bloc.dart';
import '../bloc/customer_home_event.dart';
import '../widgets/booking_ticket_card.dart';
import '../widgets/bookings_empty_state.dart';
import '../widgets/bookings_segmented_tab.dart';
import '../widgets/cancel_booking_confirmation_dialog.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({
    super.key,
    this.customerId,
    this.customerBookingsBloc,
  });

  final String? customerId;
  final CustomerBookingsBloc? customerBookingsBloc;

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  late final CustomerBookingsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.customerBookingsBloc ?? _resolveBloc();
    final customerId = _resolveCustomerId();
    if (_bloc.state.isInitial) {
      _bloc.add(CustomerBookingsLoadRequested(customerId));
    }
  }

  CustomerBookingsBloc _resolveBloc() {
    try {
      return context.read<CustomerBookingsBloc>();
    } catch (_) {
      if (!sl.isRegistered<CustomerBookingsBloc>()) {
        registerCustomerDependencies(serviceLocator: sl);
      }
      return sl<CustomerBookingsBloc>();
    }
  }

  String _resolveCustomerId() {
    if (widget.customerId != null && widget.customerId!.isNotEmpty) {
      return widget.customerId!;
    }
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        return authState.user.uid;
      }
    } catch (_) {}
    return 'guest_customer';
  }

  Future<void> _onCancel(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const CancelBookingConfirmationDialog(),
    );

    if (confirmed == true && mounted) {
      final customerId = _resolveCustomerId();
      _bloc.add(CustomerBookingCancelRequested(
        bookingId: bookingId,
        customerId: customerId,
      ));

      try {
        final homeBloc = context.read<CustomerHomeBloc>();
        homeBloc.add(CustomerHomeRefreshRequested(customerId: customerId));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final customerId = _resolveCustomerId();

    return BlocProvider<CustomerBookingsBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: LuxuryAppBar(
          title: context.l10n.customerNavBookings,
          currentLanguage: context.languageCode,
          onLanguageToggle: () => context.toggleLocale(),
          onThemeToggle: () => context.toggleTheme(),
          isDarkMode: context.isDarkMode,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _bloc.add(CustomerBookingsLoadRequested(customerId));
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: BlocBuilder<CustomerBookingsBloc, CustomerBookingsState>(
                  buildWhen: (prev, curr) =>
                      prev.currentTabIndex != curr.currentTabIndex,
                  builder: (context, state) {
                    return BookingsSegmentedTab(
                      selectedIndex: state.currentTabIndex,
                      onTabChanged: (index) {
                        _bloc.add(CustomerBookingsTabChanged(index));
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<CustomerBookingsBloc, CustomerBookingsState>(
                  buildWhen: (prev, curr) =>
                      prev.currentTabBookings != curr.currentTabBookings ||
                      prev.isLoading != curr.isLoading ||
                      prev.isFailure != curr.isFailure ||
                      prev.currentTabIndex != curr.currentTabIndex,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        children: const [
                          LuxuryShimmerCard(height: 140.0),
                          AppSpacing.verticalMd,
                          LuxuryShimmerCard(height: 140.0),
                        ],
                      );
                    }

                    final bookings = state.currentTabBookings;
                    if (bookings.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          BookingsEmptyState(
                            isUpcoming: state.currentTabIndex == 0,
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => AppSpacing.verticalMd,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return BookingTicketCard(
                          booking: booking,
                          isCancelling: state.isCancelling(booking.id),
                          onCancel: () => _onCancel(booking.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
