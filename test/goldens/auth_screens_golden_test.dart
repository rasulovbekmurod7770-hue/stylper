@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../helpers/screen_fixtures.dart';
import '../helpers/screen_harness.dart';

/// Renders each designed screen at its Figma frame size with the
/// design's sample content. Compare against design/figma/screens/ with
/// `python3 tool/compare_to_figma.py`. Regenerate with:
/// `flutter test --tags golden --update-goldens`.
void main() {
  for (final fixture in screenFixtures()) {
    testWidgets(fixture.name, (tester) async {
      await pumpScreen(
        tester,
        fixture.build(),
        precacheImages: fixture.images,
        size: fixture.goldenSize,
        realShadows: true,
      );
      await fixture.fillIn?.call(tester);
      await expectScreenGolden(fixture.name);
    });
  }
}
