import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import 'package:barber_app/core/widgets/luxury_text_field.dart';
import 'package:barber_app/features/customer/domain/entities/booking_entity.dart';
import 'package:barber_app/features/customer/domain/usecases/get_available_time_slots_usecase.dart';

class RescheduleResult {
  const RescheduleResult({
    required this.newDateTime,
    required this.reason,
  });

  final DateTime newDateTime;
  final String reason;
}

class RescheduleBookingDialog extends StatefulWidget {
  const RescheduleBookingDialog({
    super.key,
    required this.booking,
    required this.getAvailableTimeSlotsUseCase,
  });

  final BookingEntity booking;
  final GetAvailableTimeSlotsUseCase getAvailableTimeSlotsUseCase;

  @override
  State<RescheduleBookingDialog> createState() =>
      _RescheduleBookingDialogState();
}

class _RescheduleBookingDialogState extends State<RescheduleBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  late DateTime _selectedDate;
  List<DateTime> _slots = const [];
  DateTime? _selectedSlot;
  bool _isLoadingSlots = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.booking.dateTime.year,
      widget.booking.dateTime.month,
      widget.booking.dateTime.day,
    );
    _loadSlots();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _selectedSlot = null;
    });
    try {
      final loaded = await widget.getAvailableTimeSlotsUseCase(
        barberId: widget.booking.barberId,
        date: _selectedDate,
        durationMinutes: widget.booking.totalDurationMinutes,
      );
      if (!mounted) return;
      setState(() {
        _slots = loaded;
        _selectedSlot = loaded.isNotEmpty ? loaded.first : null;
        _isLoadingSlots = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _slots = const [];
        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked != null && mounted) {
      _selectedDate = picked;
      await _loadSlots();
    }
  }

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSlot == null) return;
    Navigator.of(context).pop(
      RescheduleResult(
        newDateTime: _selectedSlot!,
        reason: _reasonController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    final isArabic = context.languageCode == 'AR';
    final dateLabel =
        DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(_selectedDate);

    return AlertDialog(
      backgroundColor: context.cardSurface,
      title: Text(
        l10n.barberRescheduleTitle,
        style: AppTextStyles.titleMedium.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    size: AppSizes.iconSm,
                    color: AppColors.secondary,
                  ),
                  label: Text('${l10n.barberSelectNewDate}: $dateLabel'),
                ),
                AppSpacing.verticalMd,
                Text(
                  l10n.barberSelectNewTime,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.verticalXs,
                if (_isLoadingSlots)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_slots.isEmpty)
                  Text(
                    l10n.noSlotsAvailable,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  )
                else
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: _slots.take(12).map((slot) {
                      final selected = _selectedSlot == slot;
                      final timeText =
                          DateFormat.jm(isArabic ? 'ar' : 'en').format(slot);
                      return ChoiceChip(
                        label: Text(timeText),
                        selected: selected,
                        selectedColor: AppColors.secondary,
                        labelStyle: AppTextStyles.labelSmall.copyWith(
                          color:
                              selected ? AppColors.primary : scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedSlot = slot;
                          });
                        },
                      );
                    }).toList(),
                  ),
                AppSpacing.verticalMd,
                LuxuryTextField(
                  controller: _reasonController,
                  label: l10n.barberReasonLabel,
                  hintText: l10n.barberReasonHint,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.barberReasonRequiredError;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        LuxuryPrimaryButton(
          text: l10n.barberConfirmReschedule,
          onPressed: _selectedSlot == null ? null : _onConfirm,
        ),
      ],
    );
  }
}
