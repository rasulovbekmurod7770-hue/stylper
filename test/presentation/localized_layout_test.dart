import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/screen_fixtures.dart';
import '../helpers/screen_harness.dart';

/// Every auth / onboarding screen must lay out without overflow in each
/// language, on the Figma frame and on a small Android phone.
void main() {
  const devices = {
    'iPhone 390x844': (size: Size(390, 844), safeArea: figmaSafeArea),
    'Android 360x640': (
      size: Size(360, 640),
      safeArea: FakeViewPadding(top: 24),
    ),
  };

  for (final locale in const [Locale('en'), Locale('ru'), Locale('uz')]) {
    for (final MapEntry(key: device, value: spec) in devices.entries) {
      for (final fixture in authScreenFixtures()) {
        testWidgets('${fixture.name} · ${locale.languageCode} · $device', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            fixture.build(),
            locale: locale,
            size: spec.size,
            safeArea: spec.safeArea,
            precacheImages: fixture.images,
          );
          await fixture.fillIn?.call(tester);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
