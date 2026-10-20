import 'package:flutter/widgets.dart';

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

  /// The name and "Brand … price" lines under the photo, in the shared scale
  /// (Figma's 10 / 9px Inter lines make it 39px).
  static const _infoHeight = 6 + 18 + 4 + 17 + 6.0;

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
            style: AppTypography.overline,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          // Card (photo 90 + name / brand line) + gap + pills.
          height: 90 + _infoHeight + 6 + 19,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: open,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            child: ColoredBox(
              color: AppColors.surfaceCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The cut-out fills the photo's height, on a light backdrop.
                  Container(
                    height: 90,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: AppColors.imageBackdrop,
                    child: Image(
                      image: imageFromPath(product.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: OutfitDetails._infoHeight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.shortName,
                            style: AppTypography.captionStrong.copyWith(
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.brand,
                                  style: AppTypography.meta,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatPrice(product.price, l10n.localeName),
                                style: AppTypography.meta,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: filled ? AppColors.brandGradient : null,
            color: filled ? null : AppColors.surfaceCard,
            border: Border.all(
              color: selected ? AppColors.brandRed : AppColors.outlineButton,
              width: selected ? 1 : 0.4,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(7)),
          ),
          // Longer translations shrink to fit the 19px pill.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: AppTypography.micro, maxLines: 1),
          ),
        ),
      ),
    );
  }
}
