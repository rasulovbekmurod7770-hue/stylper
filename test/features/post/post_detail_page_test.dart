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

    await tester.tap(find.text('COS · Cardigan'));
    await tester.pumpAndSettle();
    expect(find.text('Cotton Cardigan'), findsOneWidget);
    expect(find.text('\$89'), findsOneWidget);
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
}
