import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/di/injection_container.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/booking_flow_bloc.dart';
import '../bloc/booking_flow_event.dart';
import '../bloc/booking_flow_state.dart';
import '../bloc/customer_home_bloc.dart';
import '../bloc/customer_home_event.dart';
import '../widgets/booking_barbers_step.dart';
import '../widgets/booking_confirmation_sheet.dart';
import '../widgets/booking_date_time_step.dart';
import '../widgets/booking_notes_input.dart';
import '../widgets/booking_services_step.dart';
import '../widgets/booking_summary_bottom_bar.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({
    super.key,
    this.preselectedServiceId,
    this.preselectedBarberId,
    this.customerId,
    this.customerName,
    this.bookingFlowBloc,
  });

  final String? preselectedServiceId;
  final String? preselectedBarberId;
  final String? customerId;
  final String? customerName;
  final BookingFlowBloc? bookingFlowBloc;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  late final BookingFlowBloc _bloc;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _bloc = widget.bookingFlowBloc ?? _resolveBloc();
    _bloc.add(BookingFlowInitialized(
      preselectedServiceId: widget.preselectedServiceId,
      preselectedBarberId: widget.preselectedBarberId,
    ));
  }

  static BookingFlowBloc _resolveBloc() {
    if (!sl.isRegistered<BookingFlowBloc>()) {
      registerCustomerDependencies(serviceLocator: sl);
    }
    return sl<BookingFlowBloc>();
  }

  @override
  void dispose() {
    _notesController.dispose();
    if (widget.bookingFlowBloc == null) {
      _bloc.close();
    }
    super.dispose();
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

  String _resolveCustomerName() {
    if (widget.customerName != null && widget.customerName!.isNotEmpty) {
      return widget.customerName!;
    }
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        return authState.user.fullName;
      }
    } catch (_) {}
    return 'Customer';
  }

  void _onConfirmPressed() {
    final customerId = _resolveCustomerId();
    final customerName = _resolveCustomerName();
    final notes = _notesController.text.trim();

    _bloc.add(BookingSubmitted(
      customerId: customerId,
      customerName: customerName,
      notes: notes.isNotEmpty ? notes : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingFlowBloc>.value(
      value: _bloc,
      child: BlocListener<BookingFlowBloc, BookingFlowState>(
        listenWhen: (prev, curr) =>
            (prev.createdBooking != curr.createdBooking &&
                curr.createdBooking != null) ||
            (prev.failure != curr.failure && curr.failure != null),
        listener: (context, state) {
          if (state.createdBooking != null) {
            try {
              final homeBloc = context.read<CustomerHomeBloc>();
              homeBloc.add(CustomerHomeRefreshRequested(
                customerId: _resolveCustomerId(),
              ));
            } catch (_) {}

            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (dialogContext) => BookingConfirmationSheet(
                booking: state.createdBooking!,
                onDone: () {
                  Navigator.of(dialogContext).pop();
                  if (context.mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          } else if (state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.failure!.message.isNotEmpty
                      ? state.failure!.message
                      : context.l10n.bookingError,
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: context.colors.surface,
          appBar: LuxuryAppBar(
            title: context.l10n.customerBookTitle,
            showBackButton: true,
            onBackTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            currentLanguage: context.languageCode,
            onLanguageToggle: () => context.toggleLocale(),
            onThemeToggle: () => context.toggleTheme(),
            isDarkMode: context.isDarkMode,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BookingServicesStep(),
                AppSpacing.verticalLg,
                const BookingBarbersStep(),
                AppSpacing.verticalLg,
                const BookingDateTimeStep(),
                AppSpacing.verticalLg,
                BookingNotesInput(controller: _notesController),
                AppSpacing.verticalXl,
              ],
            ),
          ),
          bottomNavigationBar: BookingSummaryBottomBar(
            onConfirmPressed: _onConfirmPressed,
          ),
        ),
      ),
    );
  }
}
