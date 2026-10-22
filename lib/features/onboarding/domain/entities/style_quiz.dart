import 'package:equatable/equatable.dart';

enum OutfitCategory { top, bottom }

/// A clothing item shown in the style quiz, tagged with its brand.
class OutfitItem extends Equatable {
  const OutfitItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.imagePath,
    required this.category,
    this.styles = const [],
  });

  final String id;
  final String name;
  final String brand;

  /// Bundled asset path for now; an image URL once items come from the API.
  final String imagePath;
  final OutfitCategory category;

  /// One or two `StyleKeys`, the stronger first.
  final List<String> styles;

  @override
  List<Object?> get props => [id, name, brand, imagePath, category, styles];
}

class StyleQuiz extends Equatable {
  const StyleQuiz({required this.tops, required this.bottoms});

  final List<OutfitItem> tops;
  final List<OutfitItem> bottoms;

  @override
  List<Object?> get props => [tops, bottoms];
}

/// Style DNA from the outfit items someone liked: each style is counted
/// across the items and the most frequent comes first; ties keep the order
/// styles first appear in (top before bottom, an item's first style before
/// its second). At most [max].
List<String> styleDnaOf(Iterable<OutfitItem> liked, {int max = 5}) {
  final counts = <String, int>{}; // in order of first appearance
  for (final item in liked) {
    for (final style in item.styles) {
      counts[style] = (counts[style] ?? 0) + 1;
    }
  }
  final firstSeen = {for (final (i, style) in counts.keys.indexed) style: i};
  final styles = counts.keys.toList()
    ..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      return byCount != 0 ? byCount : firstSeen[a]!.compareTo(firstSeen[b]!);
    });
  return styles.take(max).toList();
}
