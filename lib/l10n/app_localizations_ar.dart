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
}
