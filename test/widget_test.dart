import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/core/widgets/widgets.dart';
import 'package:barber_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _tapLanguageChip(WidgetTester tester, String currentCode) async {
  await tester.tap(find.text(currentCode));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('BarberSyncApp initializes with ThemeMode.light by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);
    expect(materialApp.theme?.colorScheme.surface, AppColors.cream);
    expect(materialApp.theme?.colorScheme.primary, AppColors.primary);
    expect(materialApp.theme?.scaffoldBackgroundColor, AppColors.cream);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    final darkMaterialApp =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(darkMaterialApp.themeMode, ThemeMode.dark);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();

    final lightMaterialApp =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(lightMaterialApp.themeMode, ThemeMode.light);
  });

  testWidgets('Welcome screen renders English strings and single Login button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    expect(find.text('BarberSync'), findsOneWidget);
    expect(find.text("The Modern Gentleman's Grooming"), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(LuxuryPrimaryButton), findsOneWidget);
    expect(find.text('Barber Portal'), findsNothing);
    expect(find.text('Customer Booking'), findsNothing);

    final context = tester.element(find.text('BarberSync'));
    expect(Directionality.of(context), TextDirection.ltr);
  });

  testWidgets('Toggling EN/AR translates strings and inverts direction',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    await _tapLanguageChip(tester, 'EN');

    expect(find.text('تجربة الحلاقة العصرية الفاخرة'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('Login'), findsNothing);

    final context = tester.element(find.text('BarberSync'));
    expect(Directionality.of(context), TextDirection.rtl);

    await _tapLanguageChip(tester, 'AR');
    expect(find.text('Login'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('BarberSync'))),
      TextDirection.ltr,
    );
  });

  testWidgets('Login button navigates to /login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(
      find.text('Sign in or create an account to continue'),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Login screen is localized in Arabic',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    await _tapLanguageChip(tester, 'EN');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('مرحباً بعودتك'), findsOneWidget);
    expect(find.text('سجّل دخولك أو أنشئ حساباً للمتابعة'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
  });
}
