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
  String get loginPlaceholderTitle => 'قريباً';

  @override
  String get loginPlaceholderBody => 'شاشة تسجيل الدخول قيد التطوير حالياً.';
}
