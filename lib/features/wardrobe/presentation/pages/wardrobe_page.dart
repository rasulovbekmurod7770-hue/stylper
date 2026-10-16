import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/image_source.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../domain/entities/wardrobe.dart';
import '../cubits/wardrobe_cubit.dart';
import '../cubits/wardrobe_membership_cubit.dart';
import '../wardrobe_category_label.dart';
import '../wardrobe_failure_message.dart';

/// Figma: "Wardrobe — Light" (2789:226) — the signed-in user's clothes by
/// category, under the same gradient logo as Home. Layout follows the
/// frame's cached metadata; styling is PROVISIONAL until its design context
/// is fetched. The back button isn't in the frame: the screen is opened from
/// the profile and needs a way back.
class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void comingSoon() => context.showMessage(l10n.comingSoon);

    // This page stays alive under other tabs; refresh the counts whenever
    // something is saved to or removed from the wardrobe anywhere.
    return BlocListener<WardrobeMembershipCubit, WardrobeMembershipState>(
      listenWhen: (previous, current) =>
          previous.overrides != current.overrides,
      listener: (context, _) => context.read<WardrobeCubit>().load(),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<WardrobeCubit, WardrobeState>(
            builder: (context, state) => CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _LogoRow()),
                SliverToBoxAdapter(
                  // "header-area": title and the quick "Add item" button.
                  child: SizedBox(
                    height: 54,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.wardrobeTitle,
                              style: AppTypography.heading,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _QuickAddButton(onTap: comingSoon),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.categories.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 167 / 204,
                      children: [
                        for (final category in state.categories)
                          _CategoryCard(category: category),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      MediaQuery.paddingOf(context).bottom + 24,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _AddItemCard(onTap: comingSoon),
                    ),
                  ),
                ] else if (state.status == WardrobeStatus.failure)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadErrorView(
                      message: state.failure!.message(l10n),
                      onRetry: context.read<WardrobeCubit>().load,
                    ),
                  )
                else
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The gradient logo centred, with Back on the left.
class _LogoRow extends StatelessWidget {
  const _LogoRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SvgPicture.asset(
            AppIcons.stylperLogoGradient,
            width: 95,
            height: 31.6667,
          ),
          const Positioned(left: 20, top: 0, child: TopBarBackButton()),
        ],
      ),
    );
  }
}

/// "add-quick-btn": a small outlined "+ Add item" pill.
class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 25,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineStrong),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 12, color: AppColors.textPrimary),
              const SizedBox(width: 4),
              Text(
                context.l10n.wardrobeAddItem,
                style: AppTypography.captionStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "category-card" (167×204): the newest item's photo, the category and how
/// many items it has. Opens the category.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final WardrobeCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final image = category.imagePath;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          await context.openWardrobeCategory(category.id);
          // Items may have been removed there.
          if (context.mounted) context.read<WardrobeCubit>().load();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.hairline),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: image == null
                      ? const Icon(
                          Icons.checkroom_outlined,
                          color: AppColors.textMuted,
                        )
                      : Image(image: imageFromPath(image), fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                wardrobeCategoryLabel(l10n, category.id),
                style: AppTypography.bodyStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                l10n.wardrobeItemCount(category.itemCount),
                style: AppTypography.captionMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "add-item-card": a dashed-looking wide card to add a new item.
class _AddItemCard extends StatelessWidget {
  const _AddItemCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineStrong),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandGradient,
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.wardrobeAddNewItem,
                style: AppTypography.bodyStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
