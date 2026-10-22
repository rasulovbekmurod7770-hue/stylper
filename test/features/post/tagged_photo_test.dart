import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/features/post/data/models/post_json.dart';
import 'package:stylper/features/post/domain/entities/post.dart';
import 'package:stylper/features/post/presentation/widgets/tagged_photo.dart';
import 'package:stylper/features/wardrobe/domain/usecases/wardrobe_usecases.dart';
import 'package:stylper/features/wardrobe/presentation/cubits/wardrobe_membership_cubit.dart';

import '../../helpers/screen_harness.dart';
import '../../helpers/layered_posts.dart';

class _MockSetInWardrobe extends Mock implements SetInWardrobe {}

void main() {
  late Post coatPost;

  setUpAll(() async {
    coatPost = PostJson.post(
      await FakeBackend(latency: Duration.zero).post('post_john_coat'),
    );
  });

  Post worstCase() => Post(
    id: coatPost.id,
    imagePath: coatPost.imagePath,
    author: coatPost.author,
    engagement: coatPost.engagement,
    commentCount: 0,
    products: worstCaseTags,
  );

  Future<void> pumpPhoto(WidgetTester tester, Post post) => pumpScreen(
    tester,
    BlocProvider(
      create: (_) => WardrobeMembershipCubit(_MockSetInWardrobe()),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: TaggedPhoto(post: post),
        ),
      ),
    ),
    size: const Size(390, 516),
    precacheImages: [post.imagePath],
  );

  /// A point on the photo, in fractions of its size. (0.1, 0.75) is clear
  /// of every tag and of the count badge.
  Future<void> tapPhotoAt(WidgetTester tester, double x, double y) async {
    final photo = tester.getRect(find.byType(TaggedPhoto));
    await tester.tapAt(
      photo.topLeft + Offset(x * photo.width, y * photo.height),
    );
    await tester.pumpAndSettle();
  }

  final badge = find.byIcon(Icons.sell_outlined);

  testWidgets('four tags show at once; a tag in a column opens its card, '
      'tapping it again or the photo closes it', (tester) async {
    await pumpPhoto(tester, coatPost);
    for (final label in [
      'TIMEOFLESS · Wool Coat',
      'COS · Cardigan',
      'ZARA · Trousers',
      'TIMEOFLESS · Chunky Scarf',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(badge, findsNothing);

    await tester.tap(find.text('COS · Cardigan'));
    await tester.pumpAndSettle();
    expect(find.text('Cotton Cardigan'), findsOneWidget);
    await tester.tap(find.text('COS · Cardigan'));
    await tester.pumpAndSettle();
    expect(find.text('Cotton Cardigan'), findsNothing);

    await tester.tap(find.text('TIMEOFLESS · Wool Coat'));
    await tester.pumpAndSettle();
    expect(find.text('Added by John. B'), findsOneWidget);
    await tapPhotoAt(tester, 0.1, 0.75);
    expect(find.text('Added by John. B'), findsNothing);
    expect(find.text('COS · Cardigan'), findsOneWidget, reason: 'tags stay');
  });

  testWidgets('a tap near the dots, off every label, is for the nearest dot', (
    tester,
  ) async {
    await pumpPhoto(tester, worstCase());
    await tapPhotoAt(tester, 0.1, 0.75); // shows the tags
    // Between the coat (0.40, 0.38) and the cardigan (0.43, 0.41), nearer
    // the coat.
    await tapPhotoAt(tester, 0.41, 0.39);
    expect(find.text('Coat'), findsOneWidget, reason: "the coat's card");
    await tapPhotoAt(tester, 0.1, 0.75); // closes it
    await tapPhotoAt(tester, 0.425, 0.405);
    expect(find.text('Cardigan'), findsOneWidget, reason: "the cardigan's");
  });

  testWidgets('more than four tags start hidden behind a count badge; '
      'tapping the photo or the badge shows and hides them', (tester) async {
    await pumpPhoto(tester, worstCase());
    expect(find.text('TIMEOFLESS · Coat'), findsNothing);
    expect(badge, findsOneWidget);
    expect(find.text('6'), findsOneWidget);

    await tapPhotoAt(tester, 0.1, 0.75);
    for (final label in [
      'TIMEOFLESS · Coat',
      'COS · Cardigan',
      'Terra Pro · T-Shirt',
      'TIMEOFLESS · Scarf',
      'ZARA · Trousers',
      'Kink · Watch',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    await tapPhotoAt(tester, 0.1, 0.75);
    expect(find.text('TIMEOFLESS · Coat'), findsNothing);

    await tester.tap(badge);
    await tester.pumpAndSettle();
    expect(find.text('TIMEOFLESS · Coat'), findsOneWidget);
    expect(find.bySemanticsLabel('Hide tagged items'), findsOneWidget);
  });
}
