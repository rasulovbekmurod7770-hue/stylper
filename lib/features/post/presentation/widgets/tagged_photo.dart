import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
/// "Brand · Item" label per tagged product, and a fade into the page. Tapping
/// a tag opens its "expanded-tag-card" (variant 2775:2953); tapping the tag
/// again or the photo closes it.
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
              // "Gradient-Fade": the bottom 119px fade into the page.
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
                        colors: [Color(0x00FAFAF7), AppColors.background],
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

  /// Dot centred on the tag point, label 9px right and down of it (flipped
  /// to the left on the right half of the photo).
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 4)],
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

class _TagLabel extends StatelessWidget {
  const _TagLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    // PROVISIONAL look until the post frame's design context is cached.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x731A1A1A),
        border: Border.all(color: const Color(0x26FFFFFF)),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(text, style: AppTypography.productTagLabel),
      ),
    );
  }
}

/// "expanded-tag-card": brand, full name, price, how many people styled it,
/// "See looks" (the product's looks) and "Save" (to the wardrobe).
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

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x261A1A1A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(product.brand, style: AppTypography.tagCardBrand),
            const SizedBox(height: 4),
            Text(
              product.name,
              style: AppTypography.tagCardName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              formatPrice(product.price, l10n.localeName),
              style: AppTypography.tagCardPrice,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.postStyledCount(product.styledCount),
              style: AppTypography.tagCardMeta,
            ),
            const SizedBox(height: 12),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: _CardButton(
                    label: l10n.postSeeLooks,
                    filled: true,
                    onTap: () => context.openProductLooks(product.id),
                  ),
                ),
                Expanded(
                  // Saves the item to the wardrobe.
                  child: _CardButton(
                    label: inWardrobe ? l10n.postSaved : l10n.postSave,
                    filled: false,
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
            gradient: filled ? AppColors.brandGradient : null,
            border: filled ? null : Border.all(color: AppColors.outlineStrong),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            label,
            style: AppTypography.tagCardButton.copyWith(
              color: filled ? Colors.white : null,
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
        // PROVISIONAL look and icon until the post frame is exported.
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xCCFAFAF7),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: const Icon(
            Icons.chevron_left,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
