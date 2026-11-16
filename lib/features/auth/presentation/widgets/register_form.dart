import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:barber_app/features/auth/presentation/widgets/role_dropdown_field.dart';

typedef RegisterFormSubmitCallback = void Function(
  String fullName,
  String phoneNumber,
  String password,
  UserRole selectedRole,
);

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
    this.errorBanner,
    this.submitButtonBuilder,
    this.submitButton,
    this.isSubmittingListenable,
    this.initialRole = UserRole.customer,
  });

  final RegisterFormSubmitCallback? onSubmit;
  final bool isLoading;
  final String? errorMessage;
  final Widget? errorBanner;
  final Widget Function(BuildContext context, VoidCallback handleSubmit)?
      submitButtonBuilder;
  final Widget? submitButton;
  final ValueListenable<bool>? isSubmittingListenable;
  final UserRole initialRole;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value, String errorText) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return errorText;
    }
    final words =
        trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (words.length < 2) {
      return errorText;
    }
    return null;
  }

  String? _validatePhone(String? value, String errorText) {
    final digits = (value ?? '').trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 15) {
      return errorText;
    }
    return null;
  }

  String? _validatePassword(String? value, String errorText) {
    if (value == null || value.length < 6) {
      return errorText;
    }
    return null;
  }

  void _handleSubmit() {
    if (widget.isLoading) {
      return;
    }
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSubmit?.call(
      _fullNameController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
      _selectedRole,
    );
  }

  Widget _buildFields(
    BuildContext context,
    bool isFieldDisabled,
    ColorScheme scheme,
  ) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RoleDropdownField(
          selectedRole: _selectedRole,
          enabled: !isFieldDisabled,
          onChanged: (role) {
            _selectedRole = role;
          },
        ),
        AppSpacing.verticalXl,
        LuxuryTextField(
          controller: _fullNameController,
          label: l10n.fullNameLabel,
          hintText: l10n.fullNameHint,
          enabled: !isFieldDisabled,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          prefixIcon: Icon(
            Icons.badge_outlined,
            size: AppSizes.iconMd,
            color: scheme.onSurfaceVariant,
          ),
          validator: (value) =>
              _validateFullName(value, l10n.fullNameRequiredError),
        ),
        AppSpacing.verticalMd,
        LuxuryTextField(
          controller: _phoneController,
          label: l10n.phoneLabel,
          hintText: l10n.phoneHint,
          enabled: !isFieldDisabled,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefixIcon: Icon(
            Icons.phone_outlined,
            size: AppSizes.iconMd,
            color: scheme.onSurfaceVariant,
          ),
          validator: (value) => _validatePhone(value, l10n.phoneInvalidError),
        ),
        AppSpacing.verticalMd,
        LuxuryTextField(
          controller: _passwordController,
          label: l10n.passwordLabel,
          hintText: l10n.passwordHint,
          enabled: !isFieldDisabled,
          isPassword: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          prefixIcon: Icon(
            Icons.lock_outline,
            size: AppSizes.iconMd,
            color: scheme.onSurfaceVariant,
          ),
          onFieldSubmitted: (_) => _handleSubmit(),
          validator: (value) =>
              _validatePassword(value, l10n.passwordShortError),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;

    Widget fieldsWidget;
    if (widget.isSubmittingListenable != null) {
      fieldsWidget = ValueListenableBuilder<bool>(
        valueListenable: widget.isSubmittingListenable!,
        builder: (context, isSubmitting, _) {
          return _buildFields(
            context,
            widget.isLoading || isSubmitting,
            scheme,
          );
        },
      );
    } else {
      fieldsWidget = _buildFields(context, widget.isLoading, scheme);
    }

    Widget? effectiveErrorBanner = widget.errorBanner;
    if (effectiveErrorBanner == null && widget.errorMessage != null) {
      effectiveErrorBanner = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthErrorBanner(message: widget.errorMessage!),
          AppSpacing.verticalMd,
        ],
      );
    }

    Widget effectiveSubmitButton = widget.submitButtonBuilder?.call(
          context,
          _handleSubmit,
        ) ??
        widget.submitButton ??
        LuxuryPrimaryButton(
          text: l10n.registerButton,
          isLoading: widget.isLoading,
          onPressed: _handleSubmit,
        );

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (effectiveErrorBanner != null) effectiveErrorBanner,
          fieldsWidget,
          AppSpacing.verticalMd,
          effectiveSubmitButton,
        ],
      ),
    );
  }
}
