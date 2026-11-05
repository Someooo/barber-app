import 'package:barber_sync/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BarberSyncApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    expect(find.text('BarberSync'), findsOneWidget);
  });
}
