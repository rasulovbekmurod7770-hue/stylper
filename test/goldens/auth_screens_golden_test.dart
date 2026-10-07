@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../helpers/screen_fixtures.dart';
import '../helpers/screen_harness.dart';

/// Renders each auth / onboarding screen at Figma frame size with the
/// design's sample content. Compare against design/figma/screens/ with
/// `python3 tool/compare_to_figma.py`. Regenerate with:
/// `flutter test --tags golden --update-goldens`.
void main() {
  for (final fixture in authScreenFixtures()) {
    testWidgets(fixture.name, (tester) async {
      await pumpScreen(
        tester,
        fixture.build(),
        precacheImages: fixture.images,
        realShadows: true,
      );
      await fixture.fillIn?.call(tester);
      await expectScreenGolden(fixture.name);
    });
  }
}
