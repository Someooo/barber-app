// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'باربر سينك';

  @override
  String get welcomeTagline => 'تجربة الحلاقة العصرية الفاخرة';

  @override
  String get syncingSystems => 'جاري مزامنة أنظمة الصالون...';

  @override
  String get barberPortal => 'بوابة الحلاقين';

  @override
  String get customerBooking => 'حجز المواعيد للزبائن';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginScreenTitle => 'تسجيل الدخول';

  @override
  String get barberDashboardTitle => 'لوحة تحكم الحلاق';

  @override
  String get customerHomeTitle => 'حجز المواعيد';

  @override
  String get loginWelcomeTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجّل دخولك أو أنشئ حساباً للمتابعة';

  @override
  String get fullNameLabel => 'الاسم الثنائي';

  @override
  String get fullNameHint => 'مثال: سامي المهر';

  @override
  String get fullNameRequiredError => 'يرجى إدخال الاسم الثنائي';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneHint => '07XXXXXXXX';

  @override
  String get phoneInvalidError => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => '6 خانات على الأقل';

  @override
  String get passwordShortError => 'كلمة المرور يجب أن تكون 6 خانات على الأقل';

  @override
  String get selectRoleLabel => 'نوع الحساب';

  @override
  String get roleBarberOption => 'حلاق';

  @override
  String get roleCustomerOption => 'زبون';

  @override
  String get continueButton => 'متابعة';

  @override
  String get roleMismatchError =>
      'تم رفض الدخول: نوع الحساب المختار لا يتطابق مع صلاحيات حسابك المسجل.';

  @override
  String get invalidCredentialsError =>
      'رقم الهاتف أو كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.';

  @override
  String get weakPasswordError =>
      'كلمة المرور ضعيفة جداً. يرجى اختيار كلمة مرور أقوى.';

  @override
  String get networkError =>
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مرة أخرى.';

  @override
  String get unknownAuthError =>
      'فشلت عملية تسجيل الدخول. يرجى المحاولة لاحقاً.';

  @override
  String get signOutButton => 'تسجيل الخروج';

  @override
  String get registerButton => 'إنشاء حساب جديد';

  @override
  String get registerScreenTitle => 'إنشاء حساب';

  @override
  String get registerWelcomeTitle => 'انضم إلى BarberSync';

  @override
  String get registerSubtitle => 'أدخل بياناتك للبدء';

  @override
  String get loginPlaceholderTitle => 'قريباً';

  @override
  String get loginPlaceholderBody => 'شاشة تسجيل الدخول قيد التطوير حالياً.';

  @override
  String get customerNavHome => 'الرئيسية';

  @override
  String get customerNavBookings => 'حجوزاتي';

  @override
  String get customerNavProfile => 'حسابي';

  @override
  String customerGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get customerDefaultGreeting => 'مرحباً بعودتك';

  @override
  String get activeBookingTitle => 'موعدك القادم';

  @override
  String get bookAppointmentCta => 'حجز موعد';

  @override
  String get servicesSectionTitle => 'الخدمات الفاخرة';

  @override
  String get servicesSectionSubtitle => 'مصممة لتناسب أناقة الرجل العصري';

  @override
  String get barbersSectionTitle => 'أمهر الحلاقين';

  @override
  String get barbersSectionSubtitle => 'حرفية عالية ودقة متناهية';

  @override
  String get availableTodayBadge => 'متاح اليوم';

  @override
  String get unavailableBadge => 'غير متاح';

  @override
  String yearsExperience(int years) {
    return 'خبرة $years سنوات';
  }

  @override
  String durationMinutesLabel(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String priceDisplay(String price) {
    return '$price د.أ';
  }

  @override
  String get bookingStatusConfirmed => 'مؤكد';

  @override
  String get bookingStatusRescheduled => 'معاد جدولته';

  @override
  String get bookingStatusCompleted => 'مكتمل';

  @override
  String get bookingStatusCancelled => 'ملغي';

  @override
  String rescheduledReasonLabel(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get noActiveBooking => 'لا توجد مواعيد قادمة';

  @override
  String get retryButton => 'إعادة المحاولة';

  @override
  String get genericErrorMessage => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get profileScreenTitle => 'الملف الشخصي';

  @override
  String get themeToggleLabel => 'الوضع الليلي';

  @override
  String get languageToggleLabel => 'اللغة';

  @override
  String get myBookingsPlaceholderTitle => 'حجوزاتي';

  @override
  String get myBookingsPlaceholderSubtitle =>
      'ستظهر هنا سجلات مواعيدك وحجوزاتك القادمة.';

  @override
  String get customerHomeHeadline => 'تجربة حلاقة استثنائية متكاملة';

  @override
  String get bookNowBanner => 'جاهز لموعد حلاقتك القادم؟';

  @override
  String get bookNowBannerSubtitle => 'تأكيد فوري للحجز مع حلاقك المفضل';

  @override
  String get customerBookTitle => 'حجز موعد';

  @override
  String get selectServicesTitle => 'اختر الخدمات';

  @override
  String get selectServicesSubtitle => 'اختر خدمة واحدة أو أكثر للعناية بمظهرك';

  @override
  String get selectBarberTitle => 'اختر الحلاق';

  @override
  String get selectBarberSubtitle => 'اختر الحلاق المتخصص المفضل لديك';

  @override
  String get selectDateTimeTitle => 'التاريخ والوقت';

  @override
  String get selectDateTimeSubtitle => 'المواعيد المتاحة تتحدث فورياً ومباشرة';

  @override
  String get noSlotsAvailable => 'لا توجد مواعيد متاحة في هذا التاريخ';

  @override
  String get selectBarberPrompt => 'يرجى اختيار الحلاق لعرض الأوقات المتاحة';

  @override
  String get bookingNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get bookingNotesHint => 'أي تفضيلات أو طلبات خاصة...';

  @override
  String get confirmInstantBookingCta => 'تأكيد الحجز الفوري';

  @override
  String get totalLabel => 'المجموع';

  @override
  String get bookingConfirmationSuccess => 'تم تأكيد الحجز الفوري بنجاح!';

  @override
  String get bookingConfirmationSubtitle =>
      'تم تثبيت موعدك فورياً، نتطلع لاستقبالك وتقديم أفضل تجربة.';

  @override
  String get doneButton => 'تم';

  @override
  String ratingValue(String rating) {
    return '$rating ★';
  }

  @override
  String get bookingError => 'فشل في إتمام الحجز. يرجى المحاولة مرة أخرى.';

  @override
  String get upcomingBookingsTab => 'المواعيد القادمة';

  @override
  String get historyBookingsTab => 'السجل';

  @override
  String get cancelBookingButton => 'إلغاء الموعد';

  @override
  String get cancelBookingDialogTitle => 'إلغاء الموعد';

  @override
  String get cancelBookingDialogMessage =>
      'هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟ سيتم إتاحة الوقت المحجوز فورياً للآخرين.';

  @override
  String get keepBookingButton => 'الاحتفاظ بالموعد';

  @override
  String get confirmCancelButton => 'نعم، إلغاء';

  @override
  String get noUpcomingBookingsTitle => 'لا توجد مواعيد قادمة';

  @override
  String get noUpcomingBookingsSubtitle =>
      'ستظهر هنا مواعيدك القادمة مع أمهر حلاّقينا.';

  @override
  String get noHistoryBookingsTitle => 'لا يوجد سجل مواعيد';

  @override
  String get noHistoryBookingsSubtitle =>
      'ستظهر هنا سجلات المواعيد السابقة المكتملة أو الملغاة.';

  @override
  String cancellationReasonLabel(String reason) {
    return 'سبب الإلغاء: $reason';
  }

  @override
  String get barberNoticeLabel => 'تحديث من الحلاق';

  @override
  String get signOutDialogTitle => 'تسجيل الخروج';

  @override
  String get signOutDialogMessage =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get accountDetailsTitle => 'تفاصيل الحساب';

  @override
  String get preferencesTitle => 'التفضيلات';

  @override
  String get bookingCancelledSuccess => 'تم إلغاء الموعد بنجاح';

  @override
  String get bookingCancelError =>
      'فشل في إلغاء الموعد. يرجى المحاولة مرة أخرى.';

  @override
  String get changeProfilePhoto => 'تغيير الصورة الشخصية';

  @override
  String get chooseFromGallery => 'اختيار صورة من المعرض';

  @override
  String get takePhoto => 'التقاط صورة بالكاميرا';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get profilePhotoUpdated => 'تم تحديث الصورة الشخصية';

  @override
  String get barberNavSchedule => 'المواعيد';

  @override
  String get barberNavHistory => 'السجل';

  @override
  String get barberNavProfile => 'الملف الشخصي';

  @override
  String get barberTodayAppointments => 'مواعيد اليوم';

  @override
  String get barberExpectedRevenue => 'الإيراد المتوقع';

  @override
  String get barberTodayTab => 'اليوم';

  @override
  String get barberUpcomingTab => 'القادمة';

  @override
  String get barberCompleteAction => 'إكمال';

  @override
  String get barberRescheduleAction => 'إعادة جدولة';

  @override
  String get barberCancelAction => 'إلغاء';

  @override
  String get barberNoTodayBookingsTitle => 'لا توجد مواعيد اليوم';

  @override
  String get barberNoTodayBookingsSubtitle => 'جدولك لليوم فارغ حالياً.';

  @override
  String get barberNoUpcomingBookingsTitle => 'لا توجد مواعيد قادمة';

  @override
  String get barberNoUpcomingBookingsSubtitle =>
      'ستظهر هنا حجوزات العملاء القادمة.';

  @override
  String get barberHistoryAllFilter => 'الكل';

  @override
  String get barberHistoryCompletedFilter => 'المكتملة';

  @override
  String get barberHistoryCancelledFilter => 'الملغاة';

  @override
  String get barberRescheduleTitle => 'إعادة جدولة الموعد';

  @override
  String get barberCancelTitle => 'إلغاء الموعد';

  @override
  String get barberReasonLabel => 'السبب (مطلوب)';

  @override
  String get barberReasonHint => 'أدخل سبباً واضحاً للعميل...';

  @override
  String get barberReasonRequiredError => 'يرجى إدخال السبب';

  @override
  String get barberConfirmReschedule => 'تأكيد إعادة الجدولة';

  @override
  String get barberConfirmCancel => 'تأكيد الإلغاء';

  @override
  String get barberSelectNewDate => 'اختر تاريخاً جديداً';

  @override
  String get barberSelectNewTime => 'اختر وقتاً جديداً';

  @override
  String get barberBookingCompletedSuccess => 'تم تحديد الموعد كمكتمل';

  @override
  String get barberBookingRescheduledSuccess => 'تمت إعادة جدولة الموعد';

  @override
  String get barberBookingCancelledSuccess => 'تم إلغاء الموعد';
}
