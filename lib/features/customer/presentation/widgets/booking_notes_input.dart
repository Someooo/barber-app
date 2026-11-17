import 'package:flutter/material.dart';

import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_text_styles.dart';
import 'package:barber_app/core/widgets/luxury_text_field.dart';

class BookingNotesInput extends StatelessWidget {
  const BookingNotesInput({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.bookingNotesLabel,
            style: AppTextStyles.titleSmall.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.verticalSm,
          LuxuryTextField(
            controller: controller,
            hintText: context.l10n.bookingNotesHint,
            prefixIcon: const Icon(Icons.edit_note_outlined),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
