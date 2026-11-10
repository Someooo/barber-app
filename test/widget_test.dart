import 'package:barber_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Switches the app language through the real EN/AR chip in the top bar.
Future<void> _tapLanguageChip(WidgetTester tester, String currentCode) async {
  await tester.tap(find.text(currentCode));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Welcome screen renders English strings by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    expect(find.text('BarberSync'), findsOneWidget);
    expect(find.text("The Modern Gentleman's Grooming"), findsOneWidget);
    expect(find.text('Barber Portal'), findsOneWidget);
    expect(find.text('Customer Booking'), findsOneWidget);

    final context = tester.element(find.text('BarberSync'));
    expect(Directionality.of(context), TextDirection.ltr);
  });

  testWidgets('Toggling EN/AR translates strings and inverts direction',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    await _tapLanguageChip(tester, 'EN');

    expect(find.text('تجربة الحلاقة العصرية الفاخرة'), findsOneWidget);
    expect(find.text('بوابة الحلاقين'), findsOneWidget);
    expect(find.text('حجز المواعيد للزبائن'), findsOneWidget);
    expect(find.text('Barber Portal'), findsNothing);

    final context = tester.element(find.text('BarberSync'));
    expect(Directionality.of(context), TextDirection.rtl);

    // And back to English.
    await _tapLanguageChip(tester, 'AR');
    expect(find.text('Barber Portal'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('BarberSync'))),
      TextDirection.ltr,
    );
  });

  testWidgets('Role buttons open localized login placeholders',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Barber Portal'));
    await tester.pumpAndSettle();
    expect(find.text('Coming Soon'), findsOneWidget);
    expect(
      find.text('Login screen is currently under active development.'),
      findsOneWidget,
    );
  });

  testWidgets('Login placeholder is localized in Arabic',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    await _tapLanguageChip(tester, 'EN');
    await tester.tap(find.text('حجز المواعيد للزبائن'));
    await tester.pumpAndSettle();

    expect(find.text('قريباً'), findsOneWidget);
    expect(find.text('شاشة تسجيل الدخول قيد التطوير حالياً.'), findsOneWidget);
  });
}
