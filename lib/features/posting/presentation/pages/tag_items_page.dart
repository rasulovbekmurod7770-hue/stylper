import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/post_draft.dart';
import '../cubits/post_draft_cubit.dart';
import '../cubits/tag_search_cubit.dart';
import '../widgets/posting_widgets.dart';
import '../widgets/product_search_sheet.dart';

/// Figma: "Screen2-AddHotspotTags" (2845:396 and variants) — tap the photo
/// where a piece of clothing is, then find that exact item from the brands'
/// catalogs. Styling is PROVISIONAL (from the frame's screenshot).
class TagItemsPage extends StatefulWidget {
  const TagItemsPage({super.key});

  @override
  State<TagItemsPage> createState() => _TagItemsPageState();
}

class _TagItemsPageState extends State<TagItemsPage> {
  /// Where the user tapped, while they pick the item.
  Offset? _pending;

  /// Tags the item at the tapped spot, or (from the search field) at a free
  /// spot down the middle.
  Future<void> _tag({Offset? at}) async {
    setState(() => _pending = at);
    final product = await showProductSearch(context);
    if (!mounted) return;
    setState(() => _pending = null);
    if (product != null) _add(product, at);
  }

  void _add(ProductSummary product, Offset? at) {
    final draft = context.read<PostDraftCubit>();
    final spot =
        at ?? Offset(0.5, 0.3 + 0.12 * (draft.state.draft.tags.length % 5));
    draft.addTag(
      DraftTag(
        productId: product.id,
        brand: product.brand,
        label: product.shortName,
        imagePath: product.imagePath,
        x: spot.dx,
        y: spot.dy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = context.watch<PostDraftCubit>();
    final photo = draft.state.draft.photoPath;
    final recent = context.select((TagSearchCubit cubit) => cubit.state.recent);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PostingTopBar(
              title: l10n.postingTagItems,
              onNext: () => context.push(AppRoutes.createDetails),
            ),
            const PostingSteps(current: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                children: [
                  if (photo != null)
                    TagCanvas(
                      photoPath: photo,
                      tags: draft.state.draft.tags,
                      pending: _pending,
                      onTapPhoto: (x, y) => _tag(at: Offset(x, y)),
                      onRemoveTag: draft.removeTag,
                    ),
                  const SizedBox(height: 16),
                  PostingSearchField(onTap: _tag),
                  if (recent.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.postingRecentTags,
                      style: AppTypography.bodyStrong,
                    ),
                    const SizedBox(height: 8),
                    for (final product in recent.take(3)) ...[
                      ProductResultCard(
                        product: product,
                        onTap: () => _add(product, null),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                  const SizedBox(height: 16),
                  const PostingTip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
