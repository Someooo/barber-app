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

  @override
  String get barberNavSchedule => 'Schedule';

  @override
  String get barberNavHistory => 'History';

  @override
  String get barberNavProfile => 'Profile';

  @override
  String get barberTodayAppointments => 'Today\'s Appointments';

  @override
  String get barberExpectedRevenue => 'Expected Revenue';

  @override
  String get barberTodayTab => 'Today';

  @override
  String get barberUpcomingTab => 'Upcoming';

  @override
  String get barberCompleteAction => 'Complete';

  @override
  String get barberRescheduleAction => 'Reschedule';

  @override
  String get barberCancelAction => 'Cancel';

  @override
  String get barberNoTodayBookingsTitle => 'No Appointments Today';

  @override
  String get barberNoTodayBookingsSubtitle =>
      'Your schedule for today is clear.';

  @override
  String get barberNoUpcomingBookingsTitle => 'No Upcoming Appointments';

  @override
  String get barberNoUpcomingBookingsSubtitle =>
      'New customer bookings will appear here.';

  @override
  String get barberHistoryAllFilter => 'All';

  @override
  String get barberHistoryCompletedFilter => 'Completed';

  @override
  String get barberHistoryCancelledFilter => 'Cancelled';

  @override
  String get barberRescheduleTitle => 'Reschedule Appointment';

  @override
  String get barberCancelTitle => 'Cancel Appointment';

  @override
  String get barberReasonLabel => 'Reason (Required)';

  @override
  String get barberReasonHint => 'Enter a clear reason for the customer...';

  @override
  String get barberReasonRequiredError => 'Please enter a reason';

  @override
  String get barberConfirmReschedule => 'Confirm Reschedule';

  @override
  String get barberConfirmCancel => 'Confirm Cancel';

  @override
  String get barberSelectNewDate => 'Select New Date';

  @override
  String get barberSelectNewTime => 'Select New Time';

  @override
  String get barberBookingCompletedSuccess => 'Appointment marked as completed';

  @override
  String get barberBookingRescheduledSuccess => 'Appointment rescheduled';

  @override
  String get barberBookingCancelledSuccess => 'Appointment cancelled';

  @override
  String get roleOwnerOption => 'Shop Owner';

  @override
  String get ownerDashboardTitle => 'Shop Management';

  @override
  String get ownerNavOverview => 'Overview';

  @override
  String get ownerNavServices => 'Services';

  @override
  String get ownerNavBarbers => 'Barbers';

  @override
  String get ownerNavProfile => 'Profile';

  @override
  String get ownerTotalRevenue => 'Total Revenue';

  @override
  String get ownerActiveAppointments => 'Active Appointments';

  @override
  String get ownerTotalBarbers => 'Total Barbers';

  @override
  String get ownerTotalServices => 'Total Services';

  @override
  String get ownerQuickActions => 'Quick Actions';

  @override
  String get ownerAddNewService => 'Add New Service';

  @override
  String get ownerAddNewBarber => 'Add New Barber';

  @override
  String get ownerRecentActivity => 'Recent Shop Activity';

  @override
  String get ownerNoServicesTitle => 'No Services Yet';

  @override
  String get ownerNoBarbersTitle => 'No Barbers Yet';

  @override
  String get ownerDeleteServiceTitle => 'Delete Service';

  @override
  String get ownerDeleteServiceMessage =>
      'Are you sure you want to remove this service from the barbershop catalog?';

  @override
  String get ownerDeleteBarberTitle => 'Delete Barber';

  @override
  String get ownerDeleteBarberMessage =>
      'Are you sure you want to remove this barber from the barbershop?';

  @override
  String get ownerDeleteConfirm => 'Delete';

  @override
  String get ownerServiceNameEn => 'Service Name (English)';

  @override
  String get ownerServiceNameAr => 'Service Name (Arabic)';

  @override
  String get ownerServiceDescEn => 'Description (English)';

  @override
  String get ownerServiceDescAr => 'Description (Arabic)';

  @override
  String get ownerServicePrice => 'Price (\$)';

  @override
  String get ownerServiceDuration => 'Duration (Minutes)';

  @override
  String get ownerServiceIcon => 'Service Icon';

  @override
  String get ownerBarberName => 'Barber Full Name';

  @override
  String get ownerBarberSpecialtyEn => 'Specialty (English)';

  @override
  String get ownerBarberSpecialtyAr => 'Specialty (Arabic)';

  @override
  String get ownerBarberExperience => 'Experience (Years)';

  @override
  String get ownerBarberImageUrl => 'Photo URL (Optional)';

  @override
  String get ownerFieldRequired => 'This field is required';

  @override
  String get ownerInvalidNumber => 'Enter a valid positive number';

  @override
  String get ownerSaveButton => 'Save';
}
