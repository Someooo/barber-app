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
  String get loginButton => 'Login';

  @override
  String get loginScreenTitle => 'Sign In';

  @override
  String get barberDashboardTitle => 'Barber Dashboard';

  @override
  String get customerHomeTitle => 'Customer Booking';

  @override
  String get loginWelcomeTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in or create an account to continue';

  @override
  String get fullNameLabel => 'Full Name (First & Last)';

  @override
  String get fullNameHint => 'e.g. Sami Almuhur';

  @override
  String get fullNameRequiredError => 'Please enter your first and last name';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get phoneHint => '07XXXXXXXX';

  @override
  String get phoneInvalidError => 'Please enter a valid phone number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Minimum 6 characters';

  @override
  String get passwordShortError => 'Password must be at least 6 characters';

  @override
  String get selectRoleLabel => 'Account Type';

  @override
  String get roleBarberOption => 'Barber';

  @override
  String get roleCustomerOption => 'Customer';

  @override
  String get continueButton => 'Continue';

  @override
  String get roleMismatchError =>
      'Access denied: The selected account type does not match your registered role.';

  @override
  String get invalidCredentialsError =>
      'Incorrect phone number or password. Please try again.';

  @override
  String get weakPasswordError =>
      'Password is too weak. Please choose a stronger password.';

  @override
  String get networkError =>
      'No internet connection. Please check your network and try again.';

  @override
  String get unknownAuthError =>
      'Authentication failed. Please try again later.';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get loginPlaceholderTitle => 'Coming Soon';

  @override
  String get loginPlaceholderBody =>
      'Login screen is currently under active development.';
}
