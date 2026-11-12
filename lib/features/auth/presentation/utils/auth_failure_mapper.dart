import 'package:flutter/widgets.dart';

import 'package:barber_app/core/errors/failures.dart';
import 'package:barber_app/core/extensions/context_extensions.dart';

String mapAuthFailureToMessage(BuildContext context, Failure failure) {
  final l10n = context.l10n;

  return switch (failure) {
    RoleMismatchFailure() => l10n.roleMismatchError,
    InvalidCredentialsFailure() => l10n.invalidCredentialsError,
    WeakPasswordFailure() => l10n.weakPasswordError,
    NetworkFailure() => l10n.networkError,
    _ => l10n.unknownAuthError,
  };
}
