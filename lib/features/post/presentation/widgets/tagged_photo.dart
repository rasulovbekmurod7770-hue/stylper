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
import '../../../../core/presentation/price_format.dart';

/// "Image-Frame" (2775:2861): the outfit photo with a back button, a dot and
/// "Brand · Item" label per tagged product, and a dark fade along the bottom.
/// Tapping a tag opens its "expanded-tag-card" (variant 2775:2953); tapping
/// the tag again or the photo closes it.
class TaggedPhoto extends StatefulWidget {
  const TaggedPhoto({super.key, required this.post});

  final Post post;

  /// The Figma photo is 390×516.
  static const aspectRatio = 390 / 516;

  @override
  State<TaggedPhoto> createState() => _TaggedPhotoState();
}

class _TaggedPhotoState extends State<TaggedPhoto> {
  int? _open;

  void _toggle(int index) =>
      setState(() => _open = _open == index ? null : index);

  @override
  Widget build(BuildContext context) {
    final products = widget.post.products;
    final open = _open;

    return AspectRatio(
      aspectRatio: TaggedPhoto.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _open = null),
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
              for (final (index, product) in products.indexed)
                ..._tag(product, size, selected: index == open, index: index),
              if (open != null && open < products.length)
                _cardFor(products[open], size),
              const Positioned(left: 19, top: 12, child: _BackButton()),
            ],
          );
        },
      ),
    );
  }

  /// A dark dot with a light ring centred on the tag point (8px while its
  /// card is open), and the label 9px right and down of it (flipped to the
  /// left on the right half of the photo).
  List<Widget> _tag(
    TaggedProduct product,
    Size size, {
    required bool selected,
    required int index,
  }) {
    final center = Offset(
      product.tagX * size.width,
      product.tagY * size.height,
    );
    final dot = selected ? 8.0 : 6.0;
    final flip = product.tagX > 0.55;
    void onTap() => _toggle(index);

    return [
      Positioned(
        left: center.dx - dot / 2,
        top: center.dy - dot / 2,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: dot,
            height: dot,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background),
            ),
          ),
        ),
      ),
      Positioned(
        left: flip ? null : center.dx + 9,
        right: flip ? size.width - center.dx + 9 : null,
        top: center.dy + 9,
        child: Semantics(
          button: true,
          selected: selected,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: _TagLabel('${product.brand} · ${product.shortName}'),
          ),
        ),
      ),
    ];
  }

  /// The expanded card sits under the tag's label, or above the tag when
  /// there's no room below.
  Widget _cardFor(TaggedProduct product, Size size) {
    const height = 142.0;
    final y = product.tagY * size.height;
    final below = y + 45;
    return Positioned(
      left: 16,
      right: 16,
      top: below + height <= size.height - 8 ? below : null,
      bottom: below + height <= size.height - 8 ? null : size.height - y + 20,
      child: _TagCard(product: product),
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
  const _TagLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 999,
      blur: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: AppTypography.onPhotoLabel.copyWith(
            color: AppColors.background,
          ),
        ),
      ),
    );
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

    const onGlass = AppColors.background;
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
            const SizedBox(height: 4),
            Text(
              formatPrice(product.price, l10n.localeName),
              style: AppTypography.label.copyWith(color: onGlass),
            ),
            const SizedBox(height: 4),
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
