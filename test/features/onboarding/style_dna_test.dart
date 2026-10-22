import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/domain/style_keys.dart';
import 'package:stylper/features/onboarding/data/datasources/style_quiz_local_data_source.dart';
import 'package:stylper/features/onboarding/domain/entities/style_quiz.dart';

void main() {
  final items = {
    for (final model in const StyleQuizLocalDataSource().getItems())
      model.id: model.toEntity(),
  };
  List<String> dnaOf(String top, String bottom) =>
      styleDnaOf([items[top]!, items[bottom]!]);

  test('every quiz item has one or two known styles', () {
    for (final item in items.values) {
      expect(item.styles, hasLength(inInclusiveRange(1, 2)), reason: item.id);
      expect(StyleKeys.all, containsAll(item.styles), reason: item.id);
    }
  });

  // The examples approved with the tag mapping.
  test('White T-Shirt + Baggy Jeans', () {
    expect(dnaOf('terra-pro-white-tshirt', 'kink-baggy-jeans'), [
      StyleKeys.minimal,
      StyleKeys.neutral,
      StyleKeys.streetwear,
      StyleKeys.oversized,
    ]);
  });

  test('Oversized Tee + Baggy Jeans: shared styles once, in tag order', () {
    expect(dnaOf('zara-oversized-white-tshirt', 'kink-baggy-jeans'), [
      StyleKeys.oversized,
      StyleKeys.streetwear,
    ]);
  });

  test('Cardigan + Wide Leg Trousers', () {
    expect(
      dnaOf('cos-cotton-cardigan', 'zara-wide-leg-tailored-trousers'),
      [StyleKeys.smartCasual, StyleKeys.minimal],
    );
  });

  test('the most frequent style leads, and there are at most five', () {
    final liked = [
      items['terra-pro-white-tshirt']!, // minimal, neutral
      items['zara-vintage-jeans']!, // streetwear, casual
      items['uniqlo-waffle-long-sleeve']!, // casual, neutral
      items['cos-barrel-loose-fit-jeans']!, // oversized, casual
      items['cos-cotton-cardigan']!, // smart_casual, minimal
    ];
    expect(styleDnaOf(liked), [
      StyleKeys.casual, // 3
      StyleKeys.minimal, // 2, seen first
      StyleKeys.neutral, // 2
      StyleKeys.streetwear,
      StyleKeys.oversized,
    ]);
  });
}
