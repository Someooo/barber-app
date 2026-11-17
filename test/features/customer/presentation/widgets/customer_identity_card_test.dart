import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/features/customer/presentation/widgets/customer_identity_card.dart';
import 'package:barber_app/l10n/app_localizations.dart';

const List<int> _kTestPngBytes = [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
  0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, //
  0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, //
  0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
];

Widget _buildHost(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('CustomerIdentityCard Photo Picker', () {
    testWidgets(
        'renders initials and opens picker sheet without Remove when no photo is set',
        (WidgetTester tester) async {
      ImageSource? selectedSource;

      await tester.pumpWidget(
        _buildHost(
          CustomerIdentityCard(
            fullName: 'Sami Almuhur',
            phoneNumber: '0799999999',
            roleLabel: 'Customer',
            onPickPhoto: (source) async {
              selectedSource = source;
            },
            onRemovePhoto: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('S'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Change Profile Photo'), findsOneWidget);
      expect(find.text('Choose Photo from Gallery'), findsOneWidget);
      expect(find.text('Take Photo with Camera'), findsOneWidget);
      expect(find.text('Remove Photo'), findsNothing);

      await tester.tap(find.text('Choose Photo from Gallery'));
      await tester.pumpAndSettle();

      expect(selectedSource, ImageSource.gallery);
    });

    testWidgets(
        'displays FileImage when photo is set and invokes onRemovePhoto',
        (WidgetTester tester) async {
      final tempDir = Directory.systemTemp.createTempSync('id_card_test_');
      final photoFile = File('${tempDir.path}/avatar.png')
        ..writeAsBytesSync(_kTestPngBytes);

      var removed = false;

      await tester.pumpWidget(
        _buildHost(
          CustomerIdentityCard(
            fullName: 'Sami Almuhur',
            phoneNumber: '0799999999',
            roleLabel: 'Customer',
            profileImagePath: photoFile.path,
            onPickPhoto: (_) async {},
            onRemovePhoto: () async {
              removed = true;
            },
          ),
        ),
      );
      await tester.pump();

      final avatar = tester.widget<LuxuryAvatar>(find.byType(LuxuryAvatar));
      expect(avatar.image, isA<FileImage>());
      expect((avatar.image! as FileImage).file.path, photoFile.path);

      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Remove Photo'), findsOneWidget);
      await tester.tap(find.text('Remove Photo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(removed, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}
