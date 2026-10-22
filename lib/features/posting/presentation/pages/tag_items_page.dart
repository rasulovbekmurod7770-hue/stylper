import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../wardrobe/presentation/widgets/add_item_card.dart';
import '../../../wardrobe/presentation/widgets/add_item_sheet.dart';
import '../../domain/entities/post_draft.dart';
import '../../domain/entities/taggable_item.dart';
import '../cubits/post_draft_cubit.dart';
import '../cubits/tag_search_cubit.dart';
import '../widgets/item_search_sheet.dart';
import '../widgets/posting_widgets.dart';

/// Figma: "Screen2-AddHotspotTags" (2845:396 and variants) — tap the photo
/// where a piece of clothing is, then find that exact item from the brands'
/// catalogs, or (2974:66565) add clothes no brand on Stylper sells to your
/// wardrobe and tag those. Styling is PROVISIONAL (from the frame's
/// screenshot), except "Add New Item" and the item details sheet.
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
    if (!_canTagMore()) return;
    setState(() => _pending = at);
    final item = await showItemSearch(context);
    if (!mounted) return;
    setState(() => _pending = null);
    if (item != null) _add(item, at);
  }

  /// "Add New Item": adds clothes to the wardrobe, then tags them.
  Future<void> _addNew() async {
    if (!_canTagMore()) return;
    final search = context.read<TagSearchCubit>();
    final added = await showAddItemSheet(
      context,
      category: search.state.category,
    );
    if (added == null || !mounted) return;
    final item = TaggableItem.own(added);
    search.addedItem(item);
    _add(item, null);
  }

  /// Says so when the photo already has [PostDraft.maxTags] tags.
  bool _canTagMore() {
    if (context.read<PostDraftCubit>().state.draft.canTagMore) return true;
    context.showMessage(context.l10n.postingTagLimit(PostDraft.maxTags));
    return false;
  }

  void _add(TaggableItem item, Offset? at) {
    if (!_canTagMore()) return;
    final draft = context.read<PostDraftCubit>();
    final spot =
        at ?? Offset(0.5, 0.3 + 0.12 * (draft.state.draft.tags.length % 5));
    draft.addTag(DraftTag(item: item, x: spot.dx, y: spot.dy));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = context.watch<PostDraftCubit>();
    final photo = draft.state.draft.photoPath;
    final recent = context.select((TagSearchCubit cubit) => cubit.state.recent);
    final added = context.select((TagSearchCubit cubit) => cubit.state.added);

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
                  // Added here: listed right under the search (2974:67417).
                  for (final item in added) ...[
                    const SizedBox(height: 10),
                    ItemResultCard(item: item, onTap: () => _add(item, null)),
                  ],
                  const SizedBox(height: 10),
                  AddItemCard(onTap: _addNew),
                  if (recent.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.postingRecentTags,
                      style: AppTypography.bodyStrong,
                    ),
                    const SizedBox(height: 8),
                    for (final item in recent.take(3)) ...[
                      ItemResultCard(item: item, onTap: () => _add(item, null)),
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
