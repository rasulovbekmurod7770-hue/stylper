import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/domain/money.dart';
import 'package:stylper/features/posting/presentation/cubits/post_draft_cubit.dart';
import 'package:stylper/features/posting/presentation/pages/tag_items_page.dart';
import 'package:stylper/features/posting/presentation/widgets/posting_widgets.dart';
import 'package:stylper/features/wardrobe/domain/entities/wardrobe.dart';
import 'package:stylper/features/wardrobe/presentation/widgets/add_item_card.dart';
import 'package:stylper/features/wardrobe/presentation/widgets/add_item_sheet.dart';

import '../../helpers/screen_fixtures.dart';
import '../../helpers/screen_harness.dart';

/// "Add New Item" while tagging (Figma 2974:66565): clothes no brand on
/// Stylper sells go to the user's wardrobe and onto the photo.
void main() {
  Future<void> pumpTagging(WidgetTester tester) async {
    final fixture = screenFixtures().firstWhere(
      (f) => f.name == 'posting_add_item',
    );
    await pumpScreen(tester, fixture.build(), precacheImages: fixture.images);
  }

  /// The [index]-th text field of the topmost sheet.
  Finder field(int index) => find
      .descendant(
        of: find.byType(BottomSheet).last,
        matching: find.byType(TextField),
      )
      .at(index);

  PostDraftCubit draft(WidgetTester tester) =>
      tester.element(find.byType(TagItemsPage)).read<PostDraftCubit>();

  Future<void> openForm(WidgetTester tester, Finder card) async {
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    await settleState(tester);
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(addItemSubmitKey));
    await tester.pump();
    await tester.tap(find.byKey(addItemSubmitKey));
    await settleState(tester);
    await settleState(tester);
  }

  Future<void> pickTops(WidgetTester tester) async {
    final tops = find.byKey(const ValueKey(WardrobeCategories.tops));
    await tester.ensureVisible(tops);
    await tester.pump();
    await tester.tap(tops);
    await tester.pump();
  }

  testWidgets('needs a name, brand and category; then tags the new item', (
    tester,
  ) async {
    await pumpTagging(tester);
    await openForm(tester, find.byType(AddItemCard));
    expect(find.text('Item details'), findsOneWidget);

    await tester.enterText(field(0), 'Grey Cardigan');
    await tester.enterText(field(1), 'TIMEOFLESS');
    await submit(tester);
    // No category yet: the form stays open.
    expect(find.text('Item details'), findsOneWidget);

    // The price is optional.
    await pickTops(tester);
    await submit(tester);
    expect(find.text('Item details'), findsNothing);

    final tag = draft(tester).state.draft.tags.single;
    expect(tag.item.own, isTrue);
    expect(tag.item.name, 'Grey Cardigan');
    expect(tag.item.price, isNull);
    expect(find.text('TIMEOFLESS · Grey Cardigan'), findsOneWidget);
    // Listed under the search, as in Figma 2974:67417.
    expect(find.text('Grey Cardigan'), findsOneWidget);
  });

  testWidgets('the price is whole soʻm above 0, grouped as it is typed', (
    tester,
  ) async {
    await pumpTagging(tester);
    await openForm(tester, find.byType(AddItemCard));
    await tester.enterText(field(2), '0');
    await tester.pump();
    expect(find.text('Enter a price above 0'), findsOneWidget);

    await tester.enterText(field(2), '350000');
    await tester.pump();
    expect(find.text('350,000'), findsOneWidget);
    expect(find.text('UZS'), findsOneWidget);
    expect(find.text('Enter a price above 0'), findsNothing);

    // Only digits go in.
    await tester.enterText(field(2), '12.5a');
    await tester.pump();
    expect(find.text('125'), findsOneWidget);
  });

  testWidgets(
    'not found from a photo tap: added there, and tagged at that spot',
    (tester) async {
      await pumpTagging(tester);
      final photo = find.byType(TagCanvas);
      final box = tester.getRect(photo);
      await tester.tapAt(box.topLeft + Offset(box.width * 0.3, box.height / 2));
      await settleState(tester);

      await tester.enterText(field(0), 'nothing like this');
      await tester.pump(const Duration(milliseconds: 400));
      await settleState(tester);
      expect(find.text('No items found'), findsOneWidget);

      await openForm(
        tester,
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(AddItemCard),
        ),
      );
      await tester.enterText(field(0), 'Wool Scarf');
      await tester.enterText(field(1), 'Chorsu Bazaar');
      await tester.enterText(field(2), '120000');
      await pickTops(tester);
      await submit(tester);

      expect(find.byType(BottomSheet), findsNothing);
      final tag = draft(tester).state.draft.tags.single;
      expect(tag.item.label, 'Wool Scarf');
      expect(tag.item.price, const Money(amount: 120000, currency: 'UZS'));
      expect(tag.x, closeTo(0.3, 0.01));
      expect(tag.y, closeTo(0.5, 0.01));
    },
  );
}
