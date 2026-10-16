import 'package:flutter/widgets.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/image_source.dart';
import '../../../../core/presentation/price_format.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/product.dart';

/// "ProductCard" (140×194): photo, brand, name and price; opens the product.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.openProduct(product.id),
        child: Container(
          width: 140,
          // 10px to the photo in Figma, including the 1px border.
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(color: AppColors.hairline),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Image(
                  image: imageFromPath(product.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                product.brand,
                style: AppTypography.productCardBrand,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                product.name,
                style: AppTypography.productCardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                formatPrice(product.price, l10n.localeName),
                style: AppTypography.productCardPrice,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
