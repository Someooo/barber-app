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
import 'package:barber_app/features/customer/presentation/widgets/sign_out_confirmation_dialog.dart';
import '../bloc/barber_dashboard_bloc.dart';
import '../bloc/barber_dashboard_event.dart';
import '../bloc/barber_dashboard_state.dart';
import '../widgets/barber_identity_card.dart';
import '../widgets/barber_preferences_card.dart';

class BarberProfileScreen extends StatefulWidget {
  const BarberProfileScreen({super.key, this.imagePicker});

  final ImagePicker? imagePicker;

  @override
  State<BarberProfileScreen> createState() => _BarberProfileScreenState();
}

class _BarberProfileScreenState extends State<BarberProfileScreen> {
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
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked != null && picked.path.isNotEmpty) {
        await settings.saveProfileImage(
            sourcePath: picked.path, userId: userId);
      }
    } on PlatformException {
      return;
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final userId = user?.uid ?? 'barber_1';
    final fullName = user?.fullName ?? context.l10n.roleBarberOption;
    final phone = user?.phoneNumber ?? '';
    final settings = AppSettingsScope.maybeOf(context);

    return Scaffold(
      backgroundColor: context.colors.surface,
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
                builder: (context, path, _) => BarberIdentityCard(
                  fullName: fullName,
                  phoneNumber: phone,
                  roleLabel: context.l10n.roleBarberOption,
                  profileImagePath: path,
                  onPickPhoto: (src) => _onPickPhoto(context, src, userId),
                  onRemovePhoto: () =>
                      settings.removeProfileImage(userId: userId),
                ),
              )
            else
              BarberIdentityCard(
                fullName: fullName,
                phoneNumber: phone,
                roleLabel: context.l10n.roleBarberOption,
              ),
            AppSpacing.verticalLg,
            BlocBuilder<BarberDashboardBloc, BarberDashboardState>(
              buildWhen: (prev, curr) {
                if (prev is BarberDashboardLoaded &&
                    curr is BarberDashboardLoaded) {
                  return prev.barberProfile.isAvailableToday !=
                      curr.barberProfile.isAvailableToday;
                }
                return prev.runtimeType != curr.runtimeType;
              },
              builder: (context, state) {
                final available = state is BarberDashboardLoaded
                    ? state.barberProfile.isAvailableToday
                    : true;
                return BarberPreferencesCard(
                  isAvailableToday: available,
                  onAvailabilityChanged: (value) {
                    context.read<BarberDashboardBloc>().add(
                          BarberAvailabilityToggled(
                            barberId: userId,
                            isAvailableToday: value,
                          ),
                        );
                  },
                );
              },
            ),
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
