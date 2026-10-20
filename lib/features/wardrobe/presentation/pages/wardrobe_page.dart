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
/// category. Styled from the frame's design context
/// (design/figma/specs/13_wardrobe_…). The back button isn't in the frame:
/// the screen is opened from the profile and needs a way back, so it sits in
/// the frame's empty band above the title.
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
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 46,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: TopBarBackButton(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  // "header-area": title and "Quick Scan".
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
                          _QuickScanButton(onTap: comingSoon),
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
                      // Figma's card is 204px; the shared scale's count
                      // line needs 3px more.
                      childAspectRatio: 167 / 207,
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

/// "add-quick-btn": a small "+ Quick Scan" pill on a left-to-right brand
/// gradient.
class _QuickScanButton extends StatelessWidget {
  const _QuickScanButton({required this.onTap});

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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.brandRed, AppColors.brandPink],
            ),
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(AppIcons.plusSmall, width: 12, height: 12),
              const SizedBox(width: 4),
              Text(
                context.l10n.wardrobeQuickScan,
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
/// many items it has. Opens the category. Figma fills the thumbnail with a
/// photo; catalog items are cut-outs, so they're fitted on a soft panel.
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
            color: AppColors.surfaceMuted,
            border: Border.all(color: AppColors.socialBorder),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
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
                    borderRadius: BorderRadius.all(Radius.circular(16)),
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

/// "add-item-card": a wide card with a red "+" disc to add a new item.
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
            color: AppColors.surfaceMuted,
            border: Border.all(color: AppColors.socialBorder),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandRed,
                ),
                child: SvgPicture.asset(AppIcons.plus, width: 16, height: 16),
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
