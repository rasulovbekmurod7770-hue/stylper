import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/compact_count.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/widgets/follow_button.dart';
import '../../domain/entities/post.dart';
import '../cubits/post_detail_cubit.dart';
import '../cubits/post_engagement_cubit.dart';
import '../post_failure_message.dart';
import '../widgets/engagement_buttons.dart';
import '../widgets/outfit_details.dart';
import '../widgets/post_grid.dart';
import '../widgets/tagged_photo.dart';

/// Figma: "home-feed-2" (2775:2840) — one outfit post: author, the photo
/// with its tagged items, like / comment / share / save, the items as
/// product cards, and similar posts. Figma draws it without the tab bar; the
/// app shows the bar on every in-app screen, so it keeps room for it.
///
/// Styled from the frame's design context (design/figma/specs/09_post_…),
/// in the shared Poppins scale instead of the frame's Inter.
class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<PostEngagementCubit, PostEngagementState>(
      listenWhen: (previous, current) =>
          current.failureCount != previous.failureCount,
      listener: (context, state) =>
          context.showMessage(state.failure!.message(l10n)),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<PostDetailCubit, PostDetailState>(
            builder: (context, state) => switch (state) {
              PostDetailState(:final post?) => _PostView(post: post),
              PostDetailState(status: PostDetailStatus.failure) =>
                _WithBackButton(
                  child: LoadErrorView(
                    message: state.failure!.message(l10n),
                    onRetry: context.read<PostDetailCubit>().load,
                  ),
                ),
              _ => const _WithBackButton(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _PostView extends StatelessWidget {
  const _PostView({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final caption = post.caption;
    return CustomScrollView(
      slivers: [
        // "Card-Outfit": author, photo, actions (and the caption) on the soft
        // card colour, closed by a hairline.
        SliverToBoxAdapter(
          child: ColoredBox(
            color: AppColors.surfaceCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AuthorRow(author: post.author, location: post.location),
                TaggedPhoto(post: post),
                _SocialActions(post: post),
                if (caption != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${post.author.name} ',
                            style: AppTypography.label.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                          TextSpan(text: caption),
                        ],
                      ),
                      style: AppTypography.labelMuted.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 1,
                  child: ColoredBox(color: AppColors.hairline),
                ),
              ],
            ),
          ),
        ),
        if (post.products.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverToBoxAdapter(
              child: OutfitDetails(
                products: post.products,
                authorName: post.author.name,
              ),
            ),
          ),
        if (post.similar.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
            sliver: SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    l10n.postSimilar.toUpperCase(),
                    style: AppTypography.overline,
                  ),
                ),
                const SizedBox(height: 14),
                PostGrid(posts: post.similar),
              ],
            ),
          ),
        SliverToBoxAdapter(
          // Room to scroll the last cards above the floating tab bar.
          child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
        ),
      ],
    );
  }
}

/// "User-Row" (52px): avatar, name (and where the photo was taken), Follow
/// (not on your own posts — people gather followers through their looks)
/// and a "more" button.
class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.author, this.location});

  final PostAuthor author;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              // The author opens their profile.
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.openUser(author.id),
                child: Row(
                  children: [
                    UserAvatar(
                      name: author.name,
                      imagePath: author.avatarPath,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            author.name,
                            style: AppTypography.label.copyWith(
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (location case final location?)
                            Text(
                              location,
                              style: AppTypography.meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!author.isMe) ...[
              const SizedBox(width: 12),
              FollowButton(
                userId: author.id,
                loaded: FollowState(
                  followerCount: author.followerCount,
                  following: author.followedByMe,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Semantics(
              button: true,
              label: l10n.postMore,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.showMessage(l10n.comingSoon),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(
                      AppIcons.moreHorizontal,
                      width: 15,
                      height: 3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Social-Actions" (48px): like, comments, share — and save on the right.
class _SocialActions extends StatelessWidget {
  const _SocialActions({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void comingSoon() => context.showMessage(l10n.comingSoon);

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            LikeButton(
              postId: post.id,
              loaded: post.engagement,
              iconSize: 18,
              countStyle: AppTypography.labelMuted,
            ),
            const SizedBox(width: 20),
            _IconAction(
              label: l10n.postComments,
              value: compactCount(post.commentCount),
              onTap: comingSoon,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.messageCircle,
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 6),
                  ExcludeSemantics(
                    child: Text(
                      compactCount(post.commentCount),
                      style: AppTypography.labelMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            _IconAction(
              label: l10n.postShare,
              onTap: comingSoon,
              child: SvgPicture.asset(AppIcons.send, width: 18, height: 18),
            ),
            const Spacer(),
            SaveButton(postId: post.id, loaded: post.engagement, iconSize: 18),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.label,
    required this.onTap,
    required this.child,
    this.value,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      value: value,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Loading / error states keep a way back.
class _WithBackButton extends StatelessWidget {
  const _WithBackButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenTopBar(),
        Expanded(child: child),
      ],
    );
  }
}
