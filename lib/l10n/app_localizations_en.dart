// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BarberSync';

  @override
  String get welcomeTagline => 'The Modern Gentleman\'s Grooming';

  @override
  String get syncingSystems => 'Syncing Salon Systems...';

  @override
  String get barberPortal => 'Barber Portal';

  @override
  String get customerBooking => 'Customer Booking';

  @override
  String get loginPlaceholderTitle => 'Coming Soon';

  @override
  String get loginPlaceholderBody =>
      'Login screen is currently under active development.';
}
