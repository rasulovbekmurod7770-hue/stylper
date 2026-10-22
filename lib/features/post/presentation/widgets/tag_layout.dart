import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../domain/entities/post.dart';

/// A tag as laid out on the photo, in photo pixels.
class TagPlacement {
  const TagPlacement({
    required this.dot,
    required this.label,
    required this.band,
    required this.text,
    required this.inColumn,
  });

  final Offset dot;

  /// The "Brand · Item" pill.
  final Rect label;

  /// Its tap area: the pill's width, [TagLayout.bandHeight] tall
  /// ([TagLayout.minBandHeight] where space is tight). Bands never overlap.
  final Rect band;

  /// "Brand · Item", or just the item where that doesn't fit.
  final String text;

  /// One of a column of labels, joined to its dot by a line.
  final bool inColumn;
}

/// The size of a label showing `text` in at most `maxWidth`.
typedef MeasureLabel = Size Function(String text, double maxWidth);

/// Lays out close-together tags (layers: a coat over a cardigan) so that no
/// label covers another or another tag's dot, and every tag can be tapped:
///
/// * A lone tag keeps the Figma spot, 9px right of and below its dot (left
///   on the photo's right half); when that collides, it tries the other side.
/// * Tags whose dots are close, or whose labels would still collide, stand
///   in a column beside their dots, top to bottom in the dots' order,
///   centred on them and joined to them by lines. A column steps around
///   other tags' dots.
/// * A column that can't fit "Brand · Item" shows just the items (the tag's
///   card names the brand).
abstract final class TagLayout {
  static const bandHeight = 44.0;
  static const minBandHeight = 40.0;

  /// A tap this close to a dot (and on no label) is for the nearest dot.
  static const dotHitRadius = 22.0;

  static const _clusterRadius = 56.0;
  static const _offset = 9.0;
  static const _columnOffset = 18.0;
  static const _margin = 8.0;
  static const _dotClearance = 4.0;

  /// Clear of the back button at the top, and of the edge at the bottom.
  static const _top = 48.0;
  static const _bottom = 12.0;

  static List<TagPlacement> place(
    List<TaggedProduct> products,
    Size size,
    MeasureLabel measure,
  ) {
    final dots = [
      for (final p in products)
        Offset(p.tagX * size.width, p.tagY * size.height),
    ];
    final group = List<int>.generate(dots.length, (i) => i);
    int find(int i) => group[i] == i ? i : group[i] = find(group[i]);
    void join(int i, int j) => group[find(i)] = find(j);
    bool alone(int i) =>
        Iterable<int>.generate(dots.length)
            .where((k) => find(k) == find(i))
            .length ==
        1;

    for (var i = 0; i < dots.length; i++) {
      for (var j = i + 1; j < dots.length; j++) {
        if ((dots[i] - dots[j]).distance < _clusterRadius) join(i, j);
      }
    }
    final flipped = <int>{};
    var placed = <TagPlacement>[];
    for (var round = 0; round < 3 * dots.length + 1; round++) {
      placed = _place(products, dots, size, measure, find, flipped);
      var changed = false;
      for (var i = 0; i < dots.length && !changed; i++) {
        for (var j = i + 1; j < dots.length && !changed; j++) {
          if (find(i) == find(j) || !_collide(placed[i], placed[j])) continue;
          changed = true;
          if (alone(i) && flipped.add(i)) continue;
          if (alone(j) && flipped.add(j)) continue;
          join(i, j);
        }
      }
      if (!changed) break;
    }
    return placed;
  }

  /// The tag a tap at [point] is for: the label whose band holds it, else
  /// the nearest dot within [dotHitRadius]; null for neither.
  static int? tagAt(Offset point, List<TagPlacement> tags) {
    for (final (i, tag) in tags.indexed) {
      if (tag.band.contains(point)) return i;
    }
    int? nearest;
    var best = dotHitRadius;
    for (final (i, tag) in tags.indexed) {
      final distance = (tag.dot - point).distance;
      if (distance <= best) {
        best = distance;
        nearest = i;
      }
    }
    return nearest;
  }

  static bool _collide(TagPlacement a, TagPlacement b) =>
      a.band.overlaps(b.band) ||
      a.label.inflate(_dotClearance).contains(b.dot) ||
      b.label.inflate(_dotClearance).contains(a.dot);

  static List<TagPlacement> _place(
    List<TaggedProduct> products,
    List<Offset> dots,
    Size size,
    MeasureLabel measure,
    int Function(int) find,
    Set<int> flipped,
  ) {
    String full(int i) => '${products[i].brand} · ${products[i].shortName}';
    String short(int i) => products[i].shortName;
    bool fits(String text, double room) =>
        measure(text, double.infinity).width <= room;

    final groups = <int, List<int>>{};
    for (var i = 0; i < dots.length; i++) {
      (groups[find(i)] ??= []).add(i);
    }
    final placed = List<TagPlacement?>.filled(dots.length, null);
    for (final members in groups.values) {
      final meanX =
          members.map((i) => dots[i].dx).reduce((a, b) => a + b) /
          members.length;
      final lone = members.length == 1;
      final right =
          (meanX <= size.width * 0.55) !=
          (lone && flipped.contains(members[0]));

      if (lone) {
        final i = members.single;
        final dot = dots[i];
        final room = right
            ? size.width - dot.dx - _offset - _margin
            : dot.dx - _offset - _margin;
        final text = fits(full(i), room) ? full(i) : short(i);
        final s = measure(text, room);
        final left = right ? dot.dx + _offset : dot.dx - _offset - s.width;
        // Above the dot when there's no room below it.
        final top = dot.dy + _offset + s.height <= size.height - _bottom
            ? dot.dy + _offset
            : dot.dy - _offset - s.height;
        final label = Rect.fromLTWH(left, top, s.width, s.height);
        placed[i] = TagPlacement(
          dot: dot,
          label: label,
          band: Rect.fromCenter(
            center: label.center,
            width: label.width,
            height: math.max(label.height, bandHeight),
          ),
          text: text,
          inColumn: false,
        );
        continue;
      }

      members.sort((a, b) => dots[a].dy.compareTo(dots[b].dy));
      final edge = right
          ? members.map((i) => dots[i].dx).reduce(math.max) + _columnOffset
          : members.map((i) => dots[i].dx).reduce(math.min) - _columnOffset;
      final room = right ? size.width - edge - _margin : edge - _margin;
      // One column, one form: every label with its brand, or none.
      final brands = members.every((i) => fits(full(i), room));
      final texts = {for (final i in members) i: brands ? full(i) : short(i)};
      final sizes = {for (final i in members) i: measure(texts[i]!, room)};

      // 44px a label, or down to 40px where the column wouldn't fit.
      final available = size.height - _top - _bottom;
      final pitch = members.length * bandHeight <= available
          ? bandHeight
          : math.max(minBandHeight, available / members.length);
      final total = pitch * members.length;
      final dotsTop = members.map((i) => dots[i].dy).reduce(math.min);
      final dotsBottom = members.map((i) => dots[i].dy).reduce(math.max);
      var slot = ((dotsTop + dotsBottom - total) / 2)
          .clamp(_top, math.max(_top, size.height - _bottom - total))
          .toDouble();

      for (final i in members) {
        final s = sizes[i]!;
        Rect labelIn(double slot) => Rect.fromLTWH(
          right ? edge : edge - s.width,
          slot + (pitch - s.height) / 2,
          s.width,
          s.height,
        );
        // Step down past any other tag's dot the label would cover.
        for (var moved = true; moved;) {
          moved = false;
          for (var k = 0; k < dots.length; k++) {
            if (!members.contains(k) &&
                labelIn(slot).inflate(_dotClearance).contains(dots[k])) {
              slot = dots[k].dy + _dotClearance + 2 - (pitch - s.height) / 2;
              moved = true;
            }
          }
        }
        final label = labelIn(slot);
        placed[i] = TagPlacement(
          dot: dots[i],
          label: label,
          band: Rect.fromLTWH(label.left, slot, label.width, pitch),
          text: texts[i]!,
          inColumn: true,
        );
        slot += pitch;
      }
    }
    return placed.cast<TagPlacement>();
  }
}
