import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/router/tab_navigation.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/compact_count.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../post/presentation/widgets/engagement_buttons.dart';
import '../../domain/entities/home_feed.dart';

/// "Hero Card" + "Hero Meta" (2775:2581 / 2775:2589): swipeable posts of the
/// selected style, with the style chips over the card and the author and
/// counters underneath. Tapping the card or the comment count opens the post.
///
/// Give it a key per style so switching styles starts from the first post.
class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({
    super.key,
    required this.posts,
    required this.styles,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  final List<FeaturedPost> posts;
  final List<String> styles;
  final String? selectedStyle;
  final ValueChanged<String> onStyleSelected;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final posts = widget.posts;
    if (posts.isEmpty) return const SizedBox.shrink();
    final current = posts[_page.clamp(0, posts.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: posts.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => context.openPost(posts[index].id),
                  child: FeedPhoto(path: posts[index].imagePath, radius: 24),
                ),
              ),
              // "Hero Tags": fixed over the pages, so they read as a filter.
              if (widget.styles.isNotEmpty)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    verticalDirection: VerticalDirection.up,
                    children: [
                      for (final style in widget.styles)
                        _StyleChip(
                          label: style,
                          selected: style == widget.selectedStyle,
                          onTap: () => widget.onStyleSelected(style),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PostMeta(post: current),
      ],
    );
  }
}

/// A "Hero Tags" chip: the selected style is filled with the brand gradient,
/// the rest are frosted.
class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? null : const Color(0x1AFFFFFF),
            gradient: selected ? AppColors.brandGradient : null,
            border: Border.all(color: const Color(0x26FFFFFF)),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Padding(
            // The border is drawn inside the padding, as Figma does.
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(label, style: AppTypography.heroTag),
          ),
        ),
      ),
    );
  }
}

class _PostMeta extends StatelessWidget {
  const _PostMeta({required this.post});

  final FeaturedPost post;

  @override
  Widget build(BuildContext context) {
    final author = post.author;
    return Row(
      children: [
        // The author opens their profile.
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.openUser(author.id),
            child: Row(
              children: [
                UserAvatar(
                  name: author.name,
                  imagePath: author.avatarPath,
                  size: 36,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: AppTypography.feedAuthorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${author.handle}',
                        style: AppTypography.feedHandle,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        LikeButton(
          postId: post.id,
          loaded: post.engagement,
          iconSize: 16,
          countStyle: AppTypography.feedCount,
        ),
        const SizedBox(width: 16),
        Semantics(
          button: true,
          label: context.l10n.postComments,
          value: compactCount(post.commentCount),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.openPost(post.id),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(AppIcons.messageCircle, width: 16, height: 16),
                const SizedBox(width: 6),
                ExcludeSemantics(
                  child: Text(
                    compactCount(post.commentCount),
                    style: AppTypography.feedCount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
