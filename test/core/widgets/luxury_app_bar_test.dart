import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/core/widgets/luxury_app_bar.dart';
import 'package:barber_app/core/widgets/luxury_avatar.dart';
import 'package:barber_app/l10n/app_localizations.dart';

const List<int> _kTestPngBytes = [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
  0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, //
  0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, //
  0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
];

void main() {
  group('LuxuryAppBar Profile Photo Integration', () {
    testWidgets(
        'displays profile photo when set and hides cleanly when removed',
        (WidgetTester tester) async {
      final tempDir = Directory.systemTemp.createTempSync('app_bar_test_');
      final photoFile = File('${tempDir.path}/avatar.png')
        ..writeAsBytesSync(_kTestPngBytes);

      final pathNotifier = ValueNotifier<String?>(null);
      addTearDown(pathNotifier.dispose);

      await tester.pumpWidget(
        AppSettingsScope(
          controller: AppSettingsController(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: LuxuryAppBar(
                title: 'BarberSync',
                profileImagePathListenable: pathNotifier,
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LuxuryAvatar), findsNothing);

      pathNotifier.value = photoFile.path;
      await tester.pump();

      expect(find.byType(LuxuryAvatar), findsOneWidget);
      final avatar = tester.widget<LuxuryAvatar>(find.byType(LuxuryAvatar));
      expect(avatar.image, isA<FileImage>());

      pathNotifier.value = null;
      await tester.pump();

      expect(find.byType(LuxuryAvatar), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });
  });
}
