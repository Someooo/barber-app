import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:barber_app/features/auth/presentation/widgets/role_dropdown_field.dart';

typedef LoginFormSubmitCallback = void Function(
  String fullName,
  String phoneNumber,
  String password,
  UserRole selectedRole,
);

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
    this.initialRole = UserRole.customer,
  });

  final LoginFormSubmitCallback? onSubmit;
  final bool isLoading;
  final String? errorMessage;
  final UserRole initialRole;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
    widget.onSubmit?.call(
      _fullNameController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
      _selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.errorMessage != null) ...[
            AuthErrorBanner(message: widget.errorMessage!),
            AppSpacing.verticalMd,
          ],
          RoleDropdownField(
            selectedRole: _selectedRole,
            enabled: !widget.isLoading,
            onChanged: (role) {
              setState(() {
                _selectedRole = role;
              });
            },
          ),
          AppSpacing.verticalXl,
          LuxuryTextField(
            controller: _fullNameController,
            label: l10n.fullNameLabel,
            hintText: l10n.fullNameHint,
            enabled: !widget.isLoading,
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
            enabled: !widget.isLoading,
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
            enabled: !widget.isLoading,
            isPassword: true,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            prefixIcon: Icon(
              Icons.lock_outline,
              size: AppSizes.iconMd,
              color: scheme.onSurfaceVariant,
            ),
            onFieldSubmitted: (_) => _handleSubmit(),
            validator: (value) =>
                _validatePassword(value, l10n.passwordShortError),
          ),
          AppSpacing.verticalMd,
          LuxuryPrimaryButton(
            text: l10n.continueButton,
            isLoading: widget.isLoading,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.neutral,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
