import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_fixtures.dart';
import '../../helpers/screen_harness.dart';

void main() {
  testWidgets('tapping a product tag opens its card; tapping again closes it', (
    tester,
  ) async {
    final post = screenFixtures().firstWhere((f) => f.name == 'post');
    await pumpScreen(tester, post.build(), precacheImages: post.images);
    expect(find.text('Cotton Cardigan'), findsNothing);
    // The cardigan's price under "Outfit details".
    expect(find.text('1,130,000 UZS'), findsOneWidget);

    await tester.tap(find.text('COS · Cardigan'));
    await tester.pumpAndSettle();
    expect(find.text('Cotton Cardigan'), findsOneWidget);
    expect(find.text('1,130,000 UZS'), findsNWidgets(2));
    expect(find.text('124 people styled this'), findsOneWidget);

    await tester.tap(find.text('COS · Cardigan'));
    await tester.pumpAndSettle();
    expect(find.text('Cotton Cardigan'), findsNothing);
  });

  testWidgets('guests are asked to sign in before saving', (tester) async {
    final post = screenFixtures().firstWhere((f) => f.name == 'post');
    await pumpScreen(tester, post.build(), precacheImages: post.images);

    await tester.tap(find.bySemanticsLabel('Save'));
    await tester.pump();
    expect(find.text('Sign in to like and save posts.'), findsOneWidget);
  });

  testWidgets('guests are asked to sign in before following', (tester) async {
    final post = screenFixtures().firstWhere((f) => f.name == 'post');
    await pumpScreen(tester, post.build(), precacheImages: post.images);

    await tester.tap(find.text('Follow'));
    await tester.pump();
    expect(find.text('Sign in to follow people.'), findsOneWidget);
    expect(find.text('Following'), findsNothing);
  });

  testWidgets(
    "an item the author added shows who added it, and nothing to open",
    (tester) async {
      final post = screenFixtures().firstWhere(
        (f) => f.name == 'post_own_item',
      );
      await pumpScreen(tester, post.build(), precacheImages: post.images);

      // Under "Outfit details": only Kink's jeans can be shopped.
      expect(find.text('Added by John. B'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);

      await tester.tap(find.text('TIMEOFLESS · Grey Cardigan'));
      await tester.pumpAndSettle();
      expect(find.text('Added by John. B'), findsNWidgets(2));
      expect(find.text('350,000 UZS'), findsNWidgets(2));
      expect(find.text('See looks'), findsNothing);
      expect(find.textContaining('people styled this'), findsNothing);
    },
  );
}
