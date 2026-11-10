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
  String get loginPlaceholderTitle => 'قريباً';

  @override
  String get loginPlaceholderBody => 'شاشة تسجيل الدخول قيد التطوير حالياً.';
}
