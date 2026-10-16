import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/image_source.dart';
import '../../../../core/presentation/price_format.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../wardrobe/presentation/wardrobe_actions.dart';
import '../../domain/entities/product.dart';
import '../cubits/product_detail_cubit.dart';
import '../product_failure_message.dart';
import '../widgets/product_card.dart';

/// Figma: "product-detail" (2775:3077) — the exact item: photo, brand, price
/// and where to buy it, real people wearing it, the styles they wear it in,
/// and similar items. Layout follows the frame's cached metadata; styling is
/// PROVISIONAL until its design context is fetched.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) => switch (state) {
            ProductDetailState(:final detail?) => _ProductView(detail: detail),
            ProductDetailState(status: ProductDetailStatus.failure) => Column(
              children: [
                const ScreenTopBar(),
                Expanded(
                  child: LoadErrorView(
                    message: state.failure!.message(l10n),
                    onRetry: context.read<ProductDetailCubit>().load,
                  ),
                ),
              ],
            ),
            _ => const Column(
              children: [
                ScreenTopBar(),
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}

class _ProductView extends StatelessWidget {
  const _ProductView({required this.detail});

  final ProductDetail detail;

  static const _gutter = 24.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = detail.product;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ScreenTopBar(
            title: l10n.productTitle,
            trailing: TopBarButton(
              label: l10n.postShare,
              onTap: () => context.showMessage(l10n.comingSoon),
              // PROVISIONAL icon until the frame's "share-2" is exported.
              icon: const Icon(
                Icons.share_outlined,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(_gutter, 16, _gutter, 0),
          sliver: SliverList.list(
            children: [
              _ProductImage(path: product.imagePath),
              const SizedBox(height: 16),
              Text(
                product.brand.toUpperCase(),
                style: AppTypography.productBrand,
              ),
              const SizedBox(height: 8),
              Text(product.name, style: AppTypography.productName),
              const SizedBox(height: 8),
              _PriceRow(detail: detail),
              const SizedBox(height: 16),
              _Actions(detail: detail),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: _Divider()),
        if (detail.looks.isNotEmpty) ...[
          SliverToBoxAdapter(child: _SeeItOnPeople(detail: detail)),
          const SliverToBoxAdapter(child: _Divider()),
        ],
        if (detail.styles.isNotEmpty) ...[
          SliverToBoxAdapter(child: _HowPeopleStyleIt(detail: detail)),
          const SliverToBoxAdapter(child: _Divider()),
        ],
        if (detail.similar.isNotEmpty)
          SliverToBoxAdapter(child: _SimilarStyle(products: detail.similar)),
        SliverToBoxAdapter(
          // Room to scroll the last cards above the floating tab bar.
          child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
        ),
      ],
    );
  }
}

/// "ProductImage" (342×300): the cut-out on a soft panel.
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 342 / 300,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Image(image: imageFromPath(path), fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// "PriceRow": the price, and "Available at {store}" linking to the store.
class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.detail});

  final ProductDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = detail.store;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formatPrice(detail.product.price, l10n.localeName),
          style: AppTypography.productPrice,
        ),
        const Spacer(),
        if (store != null)
          Flexible(
            child: Semantics(
              link: true,
              child: GestureDetector(
                onTap: () => _openStore(context, store),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${l10n.productAvailableAt} ',
                        style: AppTypography.productStoreLabel,
                      ),
                      TextSpan(
                        text: store.name,
                        style: AppTypography.productStoreLink,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "CTA_Row": Save to Wardrobe and Buy Now (46px).
class _Actions extends StatelessWidget {
  const _Actions({required this.detail});

  final ProductDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final id = detail.product.id;
    final inWardrobe = watchInWardrobe(context, id, loaded: detail.inWardrobe);
    final store = detail.store;

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            filled: false,
            // PROVISIONAL icons until the frame's "bookmark" / "shopping-bag"
            // are exported.
            icon: inWardrobe ? Icons.bookmark : Icons.bookmark_border,
            label: inWardrobe ? l10n.inWardrobe : l10n.productSaveToWardrobe,
            selected: inWardrobe,
            onTap: () => toggleInWardrobe(context, id, inWardrobe: inWardrobe),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            filled: true,
            icon: Icons.shopping_bag_outlined,
            label: l10n.productBuyNow,
            onTap: store == null
                ? () => context.showMessage(l10n.comingSoon)
                : () => _openStore(context, store),
          ),
        ),
      ],
    );
  }
}

Future<void> _openStore(BuildContext context, Store store) async {
  final message = context.l10n.errorOpenStore;
  final opened = await launchUrl(
    store.url,
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);
  if (!opened && context.mounted) context.showMessage(message);
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.filled,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final bool filled;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = filled ? Colors.white : AppColors.textPrimary;
    return Semantics(
      button: true,
      toggled: filled ? null : selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: filled ? AppColors.brandGradient : null,
            border: filled
                ? null
                : Border.all(
                    color: selected
                        ? AppColors.brandRed
                        : AppColors.outlineStrong,
                  ),
            borderRadius: const BorderRadius.all(Radius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.brandRed : color,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.productButton.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "SeeItOnPeopleSection": the first four looks in a 2×2 grid, and a link
/// to all of them.
class _SeeItOnPeople extends StatelessWidget {
  const _SeeItOnPeople({required this.detail});

  final ProductDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = detail.product;
    final looks = detail.looks.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.productSeeItOnPeople,
            style: AppTypography.productSectionTitle,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.productStyledBy(
              detail.styledCount,
              product.shortName.toLowerCase(),
            ),
            style: AppTypography.productSectionSubtitle,
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 165 / 170,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              for (final look in looks)
                GestureDetector(
                  onTap: () => context.openPost(look.id),
                  child: FeedPhoto(path: look.imagePath, radius: 16),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            link: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.openProductLooks(product.id),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.productSeeAllLooks,
                    style: AppTypography.productLink,
                  ),
                  const SizedBox(width: 4),
                  // PROVISIONAL icon until the frame's "arrow-right" is
                  // exported.
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.brandRed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "HowPeopleStyleItSection": a pill per style; each opens the looks in it.
class _HowPeopleStyleIt extends StatelessWidget {
  const _HowPeopleStyleIt({required this.detail});

  final ProductDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              context.l10n.productHowPeopleStyleIt,
              style: AppTypography.productSubsectionTitle,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: detail.styles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final style = detail.styles[index];
                return Semantics(
                  button: true,
                  child: GestureDetector(
                    onTap: () => context.openProductLooks(
                      detail.product.id,
                      style: style.name,
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.inputBorder),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(26),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox.square(
                            dimension: 36,
                            child: FeedPhoto(path: style.imagePath, radius: 18),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            style.name,
                            style: AppTypography.productStylePill,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "SimilarStyleSection": a row of product cards.
class _SimilarStyle extends StatelessWidget {
  const _SimilarStyle({required this.products});

  final List<ProductSummary> products;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              context.l10n.productSimilarStyle,
              style: AppTypography.productSubsectionTitle,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            // Figma's 194px card plus room for the text's line heights.
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  ProductCard(product: products[index]),
            ),
          ),
        ],
      ),
    );
  }
}

/// "DividerWrap": a hairline with 8px above and below, inset 24px.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    child: SizedBox(height: 1, child: ColoredBox(color: AppColors.hairline)),
  );
}
