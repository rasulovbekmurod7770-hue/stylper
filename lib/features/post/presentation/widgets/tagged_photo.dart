import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../wardrobe/presentation/wardrobe_actions.dart';
import '../../domain/entities/post.dart';
import 'tag_layout.dart';
import '../../../../core/presentation/price_format.dart';

/// "Image-Frame" (2775:2861): the outfit photo with a back button, a dot and
/// "Brand · Item" label per tagged product, and a dark fade along the bottom.
/// Close-together tags (layers) are laid out by [TagLayout], so no label
/// covers another or another tag's dot, and each has its own tap area.
/// Tapping a tag opens its "expanded-tag-card" (variant 2775:2953); tapping
/// the tag again or the photo closes it. A post with more than
/// [TaggedPhoto.tagsShownUpTo] tags starts with them hidden behind a badge
/// with their count (top right); tapping the photo or the badge shows or
/// hides them.
class TaggedPhoto extends StatefulWidget {
  const TaggedPhoto({super.key, required this.post});

  final Post post;

  /// The Figma photo is 390×516.
  static const aspectRatio = 390 / 516;

  /// Posts with more tags start with them hidden.
  static const tagsShownUpTo = 4;

  @override
  State<TaggedPhoto> createState() => _TaggedPhotoState();
}

class _TaggedPhotoState extends State<TaggedPhoto> {
  int? _open;
  late bool _showTags = !_many;

  bool get _many => widget.post.products.length > TaggedPhoto.tagsShownUpTo;

  void _toggle(int index) =>
      setState(() => _open = _open == index ? null : index);

  void _toggleTags() => setState(() {
    _showTags = !_showTags;
    _open = null;
  });

  /// A tap on the photo outside every label: the nearest dot's tag, else it
  /// closes the open card, else (many tags) shows or hides them.
  void _tapPhoto(Offset point, List<TagPlacement> tags) {
    final tag = _showTags ? TagLayout.tagAt(point, tags) : null;
    if (tag != null) return _toggle(tag);
    if (_open != null) return setState(() => _open = null);
    if (_many) _toggleTags();
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.post.products;
    final textScaler = MediaQuery.textScalerOf(context);

    return AspectRatio(
      aspectRatio: TaggedPhoto.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final tags = TagLayout.place(
            products,
            size,
            (text, maxWidth) => _TagLabel.measure(text, maxWidth, textScaler),
          );
          final open = _showTags ? _open : null;
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTapUp: (details) => _tapPhoto(details.localPosition, tags),
                  child: FeedPhoto(path: widget.post.imagePath, radius: 0),
                ),
              ),
              // "Gradient-Fade": the bottom 119px darken.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size.height * 119 / 516,
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: AppColors.photoFade,
                      ),
                    ),
                  ),
                ),
              ),
              if (_showTags) ...[
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ColumnLines(tags, selected: open),
                    ),
                  ),
                ),
                for (final (index, tag) in tags.indexed)
                  ..._tag(tag, index, selected: open),
              ],
              if (open != null && open < products.length)
                _cardFor(products[open], tags[open], size),
              // Top right, opposite the back button: clear of the floating
              // tab bar on short screens.
              if (_many)
                Positioned(
                  right: 11,
                  top: 4,
                  child: _TagsBadge(
                    count: products.length,
                    shown: _showTags,
                    onTap: _toggleTags,
                  ),
                ),
              const Positioned(left: 19, top: 12, child: _BackButton()),
            ],
          );
        },
      ),
    );
  }

  /// A dark dot with a light ring on the tag point (bigger while its card is
  /// open), and its label, whose whole tap band opens the card. While a card
  /// is open, the other tags dim.
  List<Widget> _tag(TagPlacement tag, int index, {required int? selected}) {
    final isSelected = index == selected;
    final dot = isSelected ? 12.0 : 8.0;
    return [
      Positioned(
        left: tag.dot.dx - dot / 2,
        top: tag.dot.dy - dot / 2,
        child: IgnorePointer(child: _Dot(size: dot)),
      ),
      Positioned.fromRect(
        rect: tag.band,
        child: Semantics(
          button: true,
          selected: isSelected,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggle(index),
            child: Center(
              child: SizedBox.fromSize(
                size: tag.label.size,
                child: Opacity(
                  opacity: selected == null || isSelected ? 1 : 0.55,
                  child: _TagLabel(tag.text, selected: isSelected),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  /// The expanded card sits under the tag's label, or above it when there's
  /// no room below.
  Widget _cardFor(TaggedProduct product, TagPlacement tag, Size size) {
    // Padding, brand, name, (price), then the styled count and buttons — or
    // just "Added by …" for an item the author added.
    final height = product.addedByAuthor
        ? 14 + 18 + 4 + 21 + (product.price == null ? 0 : 4 + 20) + 4 + 17 + 14
        : 142.0;
    final below = tag.label.bottom + 8;
    final fitsBelow = below + height <= size.height - 8;
    return Positioned(
      left: 16,
      right: 16,
      top: fitsBelow ? below : null,
      bottom: fitsBelow ? null : size.height - tag.label.top + 8,
      child: product.addedByAuthor
          ? _AddedTagCard(product: product, by: widget.post.author.name)
          : _TagCard(product: product),
    );
  }
}

/// Thin lines from each dot in a column to its label.
class _ColumnLines extends CustomPainter {
  _ColumnLines(this.tags, {required this.selected});

  final List<TagPlacement> tags;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (index, tag) in tags.indexed) {
      if (!tag.inColumn) continue;
      final end = Offset(
        tag.label.left > tag.dot.dx ? tag.label.left : tag.label.right,
        tag.label.center.dy,
      );
      final dim = selected != null && selected != index;
      canvas.drawLine(
        tag.dot,
        end,
        Paint()
          ..color = AppColors.background.withValues(alpha: dim ? 0.4 : 0.85)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_ColumnLines old) => true;
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
    );
  }
}

/// How many items are tagged, when they start hidden; shows or hides them.
class _TagsBadge extends StatelessWidget {
  const _TagsBadge({
    required this.count,
    required this.shown,
    required this.onTap,
  });

  final int count;
  final bool shown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: shown ? l10n.postHideTags : l10n.postShowTags,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // A bigger target than the badge itself.
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _Glass(
            radius: 999,
            blur: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sell_outlined,
                    size: 14,
                    color: AppColors.background,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: AppTypography.onPhotoLabel.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted dark glass over the photo, as the tags and their card.
class _Glass extends StatelessWidget {
  const _Glass({
    required this.radius,
    required this.blur,
    required this.child,
    this.shadows,
  });

  final double radius;

  /// Figma's background blur; Flutter's sigma is half of it.
  final double blur;
  final List<BoxShadow>? shadows;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur / 2, sigmaY: blur / 2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.glass,
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TagLabel extends StatelessWidget {
  const _TagLabel(this.text, {required this.selected});

  final String text;

  /// White while its card is open.
  final bool selected;

  static const _padding = EdgeInsets.symmetric(horizontal: 10, vertical: 6);

  /// The label's size showing [text] in at most [maxWidth].
  static Size measure(String text, double maxWidth, TextScaler textScaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTypography.onPhotoLabel),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(0, maxWidth - _padding.horizontal));
    final size = Size(
      painter.width.ceilToDouble() + _padding.horizontal,
      painter.height.ceilToDouble() + _padding.vertical,
    );
    painter.dispose();
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.onPhotoLabel.copyWith(
      color: selected ? AppColors.ink : AppColors.background,
    );
    final content = Padding(
      padding: _padding,
      child: Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (selected) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
        child: content,
      );
    }
    return _Glass(radius: 999, blur: 5, child: content);
  }
}

/// "expanded-tag-card": dark glass with the brand, full name, price, how many
/// people styled it, "See looks" (the product's looks) and "Save" (to the
/// wardrobe).
class _TagCard extends StatelessWidget {
  const _TagCard({required this.product});

  final TaggedProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final inWardrobe = watchInWardrobe(
      context,
      product.id,
      loaded: product.inWardrobe,
    );

    return _TagCardFrame(
      product: product,
      children: [
        Text(
          l10n.postStyledCount(product.styledCount),
          style: AppTypography.meta.copyWith(color: AppColors.onDarkMuted),
        ),
        const SizedBox(height: 12),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: _CardButton(
                label: l10n.postSeeLooks,
                filled: false,
                onTap: () => context.openProductLooks(product.id),
              ),
            ),
            Expanded(
              // Saves the item to the wardrobe.
              child: _CardButton(
                label: inWardrobe ? l10n.postSaved : l10n.postSave,
                filled: true,
                onTap: () => toggleInWardrobe(
                  context,
                  product.id,
                  inWardrobe: inWardrobe,
                  announce: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The card for an item the author added themselves: what it is, and who
/// added it — so nobody takes it for a brand's listing. Nothing to open.
class _AddedTagCard extends StatelessWidget {
  const _AddedTagCard({required this.product, required this.by});

  final TaggedProduct product;
  final String by;

  @override
  Widget build(BuildContext context) {
    return _TagCardFrame(
      product: product,
      children: [
        Text(
          context.l10n.postAddedBy(by),
          style: AppTypography.meta.copyWith(color: AppColors.onDarkMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// The glass card's brand, name and price (when known), then [children].
class _TagCardFrame extends StatelessWidget {
  const _TagCardFrame({required this.product, required this.children});

  final TaggedProduct product;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const onGlass = AppColors.background;
    final price = product.price;
    return _Glass(
      radius: 18,
      blur: 9,
      shadows: const [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.brand,
              style: AppTypography.captionMuted.copyWith(color: onGlass),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              style: AppTypography.bodyStrong.copyWith(color: onGlass),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (price != null) ...[
              const SizedBox(height: 4),
              Text(
                formatPrice(price, context.l10n),
                style: AppTypography.label.copyWith(color: onGlass),
              ),
            ],
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.ink : null,
            border: filled
                ? null
                : Border.all(color: AppColors.glassButtonBorder),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            label,
            style: AppTypography.captionStrong.copyWith(
              color: AppColors.background,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// The 30×30 back button over the photo's top-left corner.
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.back,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.home),
        child: Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.only(left: 6, top: 5),
          alignment: Alignment.topLeft,
          decoration: const BoxDecoration(
            color: Color(0xCCFAFAF7), // background @ 80%
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: SvgPicture.asset(
            AppIcons.chevronLeftSmall,
            width: 18,
            height: 18,
          ),
        ),
      ),
    );
  }
}
