import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:barber_app/core/constants/app_constants.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';
import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/core/widgets/luxury_buttons.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import '../widgets/customer_identity_card.dart';
import '../widgets/customer_preferences_card.dart';
import '../widgets/sign_out_confirmation_dialog.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    this.imagePicker,
  });

  final ImagePicker? imagePicker;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : null;
    final settings = AppSettingsScope.maybeOf(context);
    if (userId != null && settings != null && settings.activeUserId != userId) {
      Future.microtask(() {
        if (mounted) {
          settings.setActiveUser(userId);
        }
      });
    }
  }

  Future<void> _onSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const SignOutConfirmationDialog(),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }

  Future<void> _onPickPhoto(
    BuildContext context,
    ImageSource source,
    String userId,
  ) async {
    final settings = AppSettingsScope.maybeOf(context);
    if (settings == null) return;

    try {
      final picker = widget.imagePicker ?? ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (pickedFile == null || pickedFile.path.isEmpty) {
        return;
      }
      await settings.saveProfileImage(
        sourcePath: pickedFile.path,
        userId: userId,
      );
    } on PlatformException {
      return;
    } catch (_) {
      return;
    }
  }

  Future<void> _onRemovePhoto(BuildContext context, String userId) async {
    final settings = AppSettingsScope.maybeOf(context);
    if (settings == null) return;
    await settings.removeProfileImage(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final userId = user?.uid ?? 'guest_customer';
    final fullName = user?.fullName ?? 'Customer';
    final phone = user?.phoneNumber ?? '';
    final settings = AppSettingsScope.maybeOf(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: LuxuryAppBar(
        title: context.l10n.profileScreenTitle,
        currentLanguage: context.languageCode,
        onLanguageToggle: () => context.toggleLocale(),
        onThemeToggle: () => context.toggleTheme(),
        isDarkMode: context.isDarkMode,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            if (settings != null)
              ValueListenableBuilder<String?>(
                valueListenable: settings.profileImagePathListenable,
                builder: (context, profileImagePath, _) {
                  return CustomerIdentityCard(
                    fullName: fullName,
                    phoneNumber: phone,
                    roleLabel: context.l10n.roleCustomerOption,
                    profileImagePath: profileImagePath,
                    onPickPhoto: (source) =>
                        _onPickPhoto(context, source, userId),
                    onRemovePhoto: () => _onRemovePhoto(context, userId),
                  );
                },
              )
            else
              CustomerIdentityCard(
                fullName: fullName,
                phoneNumber: phone,
                roleLabel: context.l10n.roleCustomerOption,
              ),
            AppSpacing.verticalLg,
            const CustomerPreferencesCard(),
            AppSpacing.verticalXl,
            RepaintBoundary(
              child: LuxurySecondaryButton(
                text: context.l10n.signOutButton,
                onPressed: () => _onSignOut(context),
                prefixIcon: const Icon(
                  Icons.logout,
                  size: AppSizes.iconSm,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
