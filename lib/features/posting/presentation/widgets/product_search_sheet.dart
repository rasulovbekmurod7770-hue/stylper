import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../product/domain/entities/product.dart';
import '../../../wardrobe/domain/entities/wardrobe.dart';
import '../../../wardrobe/presentation/wardrobe_category_label.dart';
import '../cubits/tag_search_cubit.dart';
import '../posting_failure_message.dart';
import 'posting_widgets.dart';

/// Opens the item search (Figma "Screen2-AddHotspotTags", sheet variants);
/// completes with the chosen product, or null if dismissed.
Future<ProductSummary?> showProductSearch(BuildContext context) {
  final search = context.read<TagSearchCubit>();
  return showModalBottomSheet<ProductSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        BlocProvider.value(value: search, child: const _ProductSearch()),
  );
}

class _ProductSearch extends StatefulWidget {
  const _ProductSearch();

  @override
  State<_ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<_ProductSearch> {
  late final _query = TextEditingController(
    text: context.read<TagSearchCubit>().state.query,
  );

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TagSearchCubit>();
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      // Rise with the keyboard, shrinking to what's left above it.
      padding: EdgeInsets.only(bottom: keyboard),
      child: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          height: math.min(
            MediaQuery.sizeOf(context).height * 0.7,
            constraints.maxHeight,
          ),
          child: BlocBuilder<TagSearchCubit, TagSearchState>(
            builder: (context, state) => Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.outlineStrong,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 30,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final category in const [
                        WardrobeCategories.tops,
                        WardrobeCategories.bottoms,
                        WardrobeCategories.shoes,
                        WardrobeCategories.accessories,
                      ])
                        _Chip(
                          label: wardrobeCategoryLabel(l10n, category),
                          selected: state.category == category,
                          onTap: () => cubit.toggleCategory(category),
                        ),
                      _Chip(
                        label: l10n.wardrobeTitle,
                        selected: state.mine,
                        wardrobe: true,
                        onTap: cubit.toggleMine,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _query,
                    autofocus: true,
                    onChanged: cubit.setQuery,
                    textInputAction: TextInputAction.search,
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.postingSearchHint,
                      hintStyle: AppTypography.labelMuted.copyWith(
                        color: AppColors.textSubtle,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textSubtle,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(child: _results(context, state)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _results(BuildContext context, TagSearchState state) {
    final l10n = context.l10n;
    final failure = state.failure;
    if (failure != null && state.results.isEmpty) {
      return _Message(failure.message(l10n));
    }
    if (state.results.isEmpty) {
      return state.searching
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _Message(l10n.postingNoResults);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: state.results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        final product = state.results[index];
        return ProductResultCard(
          product: product,
          onTap: () => Navigator.of(context).pop(product),
        );
      },
    );
  }
}

/// A filter chip: categories turn cyan when picked; "My Wardrobe" is red.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.wardrobe = false,
  });

  final String label;
  final bool selected;
  final bool wardrobe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final filledRed = wardrobe && selected;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: filledRed
                  ? null
                  : selected
                  ? AppColors.chipSelected
                  : AppColors.surfaceMuted,
              gradient: filledRed ? AppColors.brandGradient : null,
              border: wardrobe && !selected
                  ? Border.all(color: AppColors.brandPink)
                  : null,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: filledRed
                    ? Colors.white
                    : wardrobe
                    ? AppColors.brandRose
                    : AppColors.textSubtle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Text(text, style: AppTypography.body, textAlign: TextAlign.center),
  );
}
