import 'package:barber_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Welcome screen renders brand, loader and role actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    expect(find.text('BarberSync'), findsOneWidget);
    expect(find.text("The Modern Gentleman's Grooming"), findsOneWidget);
    expect(find.text('Syncing Salon Systems...'), findsOneWidget);
    expect(find.text('Barber Portal'), findsOneWidget);
    expect(find.text('Customer Booking'), findsOneWidget);
  });

  testWidgets('Role buttons navigate to their login routes',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Barber Portal'));
    await tester.pumpAndSettle();
    expect(find.text('Barber Portal — coming soon'), findsOneWidget);
  });
}
