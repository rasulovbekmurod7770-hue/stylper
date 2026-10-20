import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/image_source.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../domain/entities/wardrobe.dart';
import '../cubits/wardrobe_items_cubit.dart';
import '../cubits/wardrobe_membership_cubit.dart';
import '../wardrobe_category_label.dart';
import '../wardrobe_failure_message.dart';

/// One wardrobe category (not in Figma): a grid of its items. A catalog item
/// opens its product page; the ✕ removes an item from the wardrobe.
class WardrobeCategoryPage extends StatelessWidget {
  const WardrobeCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<WardrobeItemsCubit>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenTopBar(title: wardrobeCategoryLabel(l10n, cubit.category)),
            Expanded(
              child: BlocBuilder<WardrobeItemsCubit, WardrobeItemsState>(
                builder: (context, state) => switch (state.status) {
                  WardrobeItemsStatus.ready when state.items.isEmpty => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.wardrobeEmpty,
                        style: AppTypography.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  WardrobeItemsStatus.ready => GridView.count(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      MediaQuery.paddingOf(context).bottom + 24,
                    ),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 167 / 214,
                    children: [
                      for (final item in state.items) _ItemCard(item: item),
                    ],
                  ),
                  WardrobeItemsStatus.failure => LoadErrorView(
                    message: state.failure!.message(l10n),
                    onRetry: cubit.load,
                  ),
                  WardrobeItemsStatus.loading => const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final WardrobeItem item;

  Future<void> _remove(BuildContext context) async {
    final l10n = context.l10n;
    final items = context.read<WardrobeItemsCubit>();
    final removed = await context.read<WardrobeMembershipCubit>().toggle(
      item.productId ?? item.id,
      current: true,
    );
    if (!removed) return;
    items.removed(item);
    if (context.mounted) context.showMessage(l10n.wardrobeRemoved);
  }

  @override
  Widget build(BuildContext context) {
    final productId = item.productId;
    final brand = item.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: productId == null ? null : () => context.openProduct(productId),
      child: Container(
        padding: const EdgeInsets.all(12),
        // The wardrobe's "category-card" look (2789:258).
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          border: Border.all(color: AppColors.socialBorder),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Image(
                      image: imageFromPath(item.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Semantics(
                      button: true,
                      label: context.l10n.wardrobeRemove,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _remove(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              style: AppTypography.captionStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (brand != null) ...[
              const SizedBox(height: 2),
              Text(brand, style: AppTypography.captionMuted),
            ],
          ],
        ),
      ),
    );
  }
}
