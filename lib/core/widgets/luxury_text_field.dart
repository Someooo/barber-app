import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context_x.dart';

/// Form text input field with dual-language top labels, custom icons, and validation support.
class LuxuryTextField extends StatefulWidget {
  const LuxuryTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.arabicLabel,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
    this.autofillHints,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? arabicLabel;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int maxLines;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  @override
  State<LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<LuxuryTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  Widget _buildTopLabel(BuildContext context) {
    if (widget.label == null && widget.arabicLabel == null) {
      return const SizedBox.shrink();
    }

    final scheme = context.colors;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.label != null)
            Text(
              widget.label!.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.1,
              ),
            ),
          if (widget.arabicLabel != null)
            Text(
              widget.arabicLabel!,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.labelSmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: AppSizes.iconMd,
          color: context.colors.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    final border = OutlineInputBorder(
      borderRadius: AppRadius.controlBorder,
      borderSide: BorderSide(
        color: context.borderColor,
        width: AppSizes.hairline,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: AppRadius.controlBorder,
      borderSide: const BorderSide(
        color: AppColors.secondary,
        width: AppSizes.focusBorder,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: AppRadius.controlBorder,
      borderSide: const BorderSide(
        color: AppColors.error,
        width: AppSizes.hairline,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTopLabel(context),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          maxLines: widget.maxLines,
          autofillHints: widget.autofillHints,
          style: AppTextStyles.bodyMedium.copyWith(
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.inputFill,
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant.withValues(
                alpha: AppOpacity.scrim,
              ),
            ),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.md,
                      end: AppSpacing.sm,
                    ),
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: AppSizes.iconLg,
              minHeight: AppSizes.iconLg,
            ),
            suffixIcon: _buildSuffixIcon(context),
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder.copyWith(
              borderSide: const BorderSide(
                color: AppColors.error,
                width: AppSizes.focusBorder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

