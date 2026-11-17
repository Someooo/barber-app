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
  String get registerButton => 'Create Account';

  @override
  String get registerScreenTitle => 'Create Account';

  @override
  String get registerWelcomeTitle => 'Join BarberSync';

  @override
  String get registerSubtitle => 'Enter your details to get started';

  @override
  String get loginPlaceholderTitle => 'Coming Soon';

  @override
  String get loginPlaceholderBody =>
      'Login screen is currently under active development.';

  @override
  String get customerNavHome => 'Home';

  @override
  String get customerNavBookings => 'My Bookings';

  @override
  String get customerNavProfile => 'Profile';

  @override
  String customerGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get customerDefaultGreeting => 'Welcome back';

  @override
  String get activeBookingTitle => 'Upcoming Appointment';

  @override
  String get bookAppointmentCta => 'Book Appointment';

  @override
  String get servicesSectionTitle => 'Luxury Services';

  @override
  String get servicesSectionSubtitle => 'Crafted for the modern gentleman';

  @override
  String get barbersSectionTitle => 'Master Barbers';

  @override
  String get barbersSectionSubtitle => 'Dedicated craft & precision';

  @override
  String get availableTodayBadge => 'Available Today';

  @override
  String get unavailableBadge => 'Unavailable';

  @override
  String yearsExperience(int years) {
    return '$years yrs exp';
  }

  @override
  String durationMinutesLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String priceDisplay(String price) {
    return '\$$price';
  }

  @override
  String get bookingStatusConfirmed => 'Confirmed';

  @override
  String get bookingStatusRescheduled => 'Rescheduled';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String rescheduledReasonLabel(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get noActiveBooking => 'No upcoming appointments';

  @override
  String get retryButton => 'Retry';

  @override
  String get genericErrorMessage => 'Something went wrong. Please try again.';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get themeToggleLabel => 'Dark Mode';

  @override
  String get languageToggleLabel => 'Language';

  @override
  String get myBookingsPlaceholderTitle => 'My Bookings';

  @override
  String get myBookingsPlaceholderSubtitle =>
      'Your appointment history and upcoming bookings will appear here.';

  @override
  String get customerHomeHeadline => 'Precision Grooming Experience';

  @override
  String get bookNowBanner => 'Ready for your next cut?';

  @override
  String get bookNowBannerSubtitle =>
      'Instant confirmation with your favorite barber';

  @override
  String get customerBookTitle => 'Book Appointment';

  @override
  String get selectServicesTitle => 'Select Services';

  @override
  String get selectServicesSubtitle => 'Choose one or more grooming services';

  @override
  String get selectBarberTitle => 'Select Barber';

  @override
  String get selectBarberSubtitle => 'Choose your master barber';

  @override
  String get selectDateTimeTitle => 'Date & Time';

  @override
  String get selectDateTimeSubtitle => 'Available slots updated in real-time';

  @override
  String get noSlotsAvailable => 'No available time slots for this date';

  @override
  String get selectBarberPrompt =>
      'Please select a barber to view available times';

  @override
  String get bookingNotesLabel => 'Notes (Optional)';

  @override
  String get bookingNotesHint => 'Any special preferences or requests...';

  @override
  String get confirmInstantBookingCta => 'Confirm Instant Booking';

  @override
  String get totalLabel => 'Total';

  @override
  String get bookingConfirmationSuccess => 'Instant Booking Confirmed!';

  @override
  String get bookingConfirmationSubtitle =>
      'Your appointment is confirmed. We look forward to serving you.';

  @override
  String get doneButton => 'Done';

  @override
  String ratingValue(String rating) {
    return '$rating ★';
  }

  @override
  String get bookingError => 'Failed to create booking. Please try again.';

  @override
  String get upcomingBookingsTab => 'Upcoming';

  @override
  String get historyBookingsTab => 'History';

  @override
  String get cancelBookingButton => 'Cancel Booking';

  @override
  String get cancelBookingDialogTitle => 'Cancel Appointment';

  @override
  String get cancelBookingDialogMessage =>
      'Are you sure you want to cancel this appointment? Your reserved time slot will be released immediately.';

  @override
  String get keepBookingButton => 'Keep Appointment';

  @override
  String get confirmCancelButton => 'Yes, Cancel';

  @override
  String get noUpcomingBookingsTitle => 'No Upcoming Bookings';

  @override
  String get noUpcomingBookingsSubtitle =>
      'Your upcoming appointments with our master barbers will appear here.';

  @override
  String get noHistoryBookingsTitle => 'No Booking History';

  @override
  String get noHistoryBookingsSubtitle =>
      'Past completed and cancelled appointments will be listed here.';

  @override
  String cancellationReasonLabel(String reason) {
    return 'Cancellation Reason: $reason';
  }

  @override
  String get barberNoticeLabel => 'Barber Update';

  @override
  String get signOutDialogTitle => 'Sign Out';

  @override
  String get signOutDialogMessage =>
      'Are you sure you want to sign out of your account?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get accountDetailsTitle => 'Account Details';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get bookingCancelledSuccess => 'Booking cancelled successfully';

  @override
  String get bookingCancelError =>
      'Failed to cancel booking. Please try again.';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get chooseFromGallery => 'Choose Photo from Gallery';

  @override
  String get takePhoto => 'Take Photo with Camera';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get profilePhotoUpdated => 'Profile photo updated';
}
