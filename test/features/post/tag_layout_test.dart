import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/features/post/data/models/post_json.dart';
import 'package:stylper/features/post/domain/entities/post.dart';
import 'package:stylper/features/post/presentation/widgets/tag_layout.dart';

import '../../helpers/layered_posts.dart';

/// Labels 6px a character plus padding, 29px tall, like the real pill.
Size _measure(String text, double maxWidth) =>
    Size(math.min(6.0 * text.length + 20, maxWidth), 29);

Size _photo(double width) => Size(width, width * 516 / 390);

void main() {
  late List<TaggedProduct> real;

  setUpAll(() async {
    real = PostJson.post(
      await FakeBackend(latency: Duration.zero).post('post_john_coat'),
    ).products;
  });

  void expectReadable(List<TaggedProduct> tags, Size size) {
    final placed = TagLayout.place(tags, size, _measure);
    expect(placed, hasLength(tags.length));
    for (final (i, a) in placed.indexed) {
      expect(a.band.height, greaterThanOrEqualTo(TagLayout.minBandHeight));
      expect(a.label.left, greaterThanOrEqualTo(0), reason: a.text);
      expect(a.label.right, lessThanOrEqualTo(size.width), reason: a.text);
      expect(a.label.top, greaterThanOrEqualTo(0), reason: a.text);
      expect(a.label.bottom, lessThanOrEqualTo(size.height), reason: a.text);
      for (final (j, b) in placed.indexed) {
        if (i == j) continue;
        expect(
          a.band.overlaps(b.band),
          isFalse,
          reason: '${a.text} and ${b.text} tap areas overlap',
        );
        expect(
          a.label.inflate(2).contains(b.dot),
          isFalse,
          reason: '${a.text} covers the dot of ${b.text}',
        );
      }
      // Tapping a label opens that tag.
      expect(TagLayout.tagAt(a.label.center, placed), i);
    }
  }

  for (final width in [390.0, 360.0]) {
    test('the coat post at $width: nothing overlaps, every tag tappable', () {
      expectReadable(real, _photo(width));
    });

    test('the worst case at $width: nothing overlaps, every tag tappable', () {
      expectReadable(worstCaseTags, _photo(width));
    });
  }

  test('layers close together share a column, in top-to-bottom order, with '
      '44px tap bands', () {
    final placed = TagLayout.place(worstCaseTags, _photo(390), _measure);
    final column = [
      for (final tag in placed)
        if (tag.inColumn) tag,
    ]..sort((a, b) => a.label.top.compareTo(b.label.top));
    expect(column.map((t) => t.text), [
      'TIMEOFLESS · Scarf',
      'Terra Pro · T-Shirt',
      'TIMEOFLESS · Coat',
      'COS · Cardigan',
    ]);
    for (final tag in column) {
      expect(tag.band.height, TagLayout.bandHeight);
      expect(tag.label.left, column.first.label.left, reason: 'one column');
    }
    // The trousers and the watch keep their own spots.
    final trousers = placed[4];
    expect(trousers.inColumn, isFalse);
    expect(trousers.label.topLeft, trousers.dot + const Offset(9, 9));
  });

  test('a column too tall for 44px a label gets less, never under 40px', () {
    final ten = [
      for (var i = 0; i < 10; i++)
        layeredTag('Brand', 'Item $i', 0.30 + i * 0.005, 0.40 + i * 0.01),
    ];
    final placed = TagLayout.place(ten, _photo(360), _measure);
    expect(placed.every((t) => t.inColumn), isTrue);
    // Only as tight as needed: one height, under 44 and at least 40.
    final heights = placed.map((t) => t.band.height.toStringAsFixed(3));
    expect(heights.toSet(), hasLength(1));
    expect(
      placed.first.band.height,
      inInclusiveRange(TagLayout.minBandHeight, TagLayout.bandHeight - 0.1),
    );
    expectReadable(ten, _photo(360));
  });

  test('a column that can\'t fit the brands shows only the items', () {
    // Dots on the right edge of the left half leave little room.
    final tags = [
      layeredTag('TIMEOFLESS', 'Chunky Scarf', 0.54, 0.30),
      layeredTag('TIMEOFLESS', 'Wool Coat', 0.53, 0.33),
    ];
    final placed = TagLayout.place(tags, _photo(360), _measure);
    expect(placed.map((t) => t.text), ['Chunky Scarf', 'Wool Coat']);
  });

  group('tagAt', () {
    late List<TagPlacement> placed;
    setUp(() => placed = TagLayout.place(worstCaseTags, _photo(390), _measure));

    test('a label wins over any dot', () {
      for (final (i, tag) in placed.indexed) {
        expect(
          TagLayout.tagAt(tag.band.topLeft + const Offset(1, 1), placed),
          i,
        );
      }
    });

    test('near the dots, the nearest dot wins', () {
      final coat = placed[0].dot;
      final cardigan = placed[1].dot;
      final between = Offset.lerp(coat, cardigan, 0.4)!;
      expect(TagLayout.tagAt(between, placed), 0);
      expect(TagLayout.tagAt(Offset.lerp(coat, cardigan, 0.6)!, placed), 1);
    });

    test('far from every tag, nothing', () {
      expect(TagLayout.tagAt(const Offset(20, 480), placed), isNull);
    });
  });
}
