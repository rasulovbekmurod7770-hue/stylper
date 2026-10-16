import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/image_source.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../wardrobe/presentation/wardrobe_actions.dart';
import '../../domain/entities/post.dart';
import '../../../../core/presentation/price_format.dart';

/// "Outfit-Details-Section" (2775:2897): a 110px card per tagged product —
/// cut-out photo, item and "Brand price" — with "Shop" and "Add to wardrobe"
/// under it. Scrolls sideways when there are more than fit. A card and "Shop"
/// open the product; "Add to wardrobe" saves it.
class OutfitDetails extends StatelessWidget {
  const OutfitDetails({super.key, required this.products});

  final List<TaggedProduct> products;

  static const _cardWidth = 110.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.postOutfitDetails.toUpperCase(),
            style: AppTypography.feedSectionLabel,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 129 + 6 + 19,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 18),
            itemBuilder: (context, index) => SizedBox(
              width: _cardWidth,
              child: _ProductCard(product: products[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final TaggedProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void open() => context.openProduct(product.id);
    final inWardrobe = watchInWardrobe(
      context,
      product.id,
      loaded: product.inWardrobe,
    );

    // PROVISIONAL look (fills, radii, pill styles) until the post frame is
    // exported; sizes are from Figma.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: open,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.hairline),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 90,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Image(
                    image: imageFromPath(product.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 39 - 2, // minus the 1px border, top and bottom
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.shortName,
                          style: AppTypography.productCardName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.brand} '
                          '${formatPrice(product.price, l10n.localeName)}',
                          style: AppTypography.productCardMeta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 19,
          child: Row(
            children: [
              _Pill(label: l10n.postShop, filled: true, onTap: open),
              const SizedBox(width: 2),
              Expanded(
                child: _Pill(
                  label: inWardrobe ? l10n.inWardrobe : l10n.postAddToWardrobe,
                  filled: false,
                  selected: inWardrobe,
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
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.filled,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  /// An outlined pill in its "on" state (e.g. already in the wardrobe).
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 34),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: filled ? AppColors.brandGradient : null,
            border: filled
                ? null
                : Border.all(
                    color: selected
                        ? AppColors.brandRed
                        : AppColors.outlineStrong,
                  ),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          // Longer translations shrink to fit the 19px pill.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTypography.productPill.copyWith(
                color: filled ? Colors.white : null,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
