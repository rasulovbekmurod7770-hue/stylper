import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/presentation/compact_count.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/home_feed.dart';
import 'feed_photo.dart';

/// "Hero Card" + "Hero Meta" (2775:2581 / 2775:2589): a swipeable post with
/// its style chips, and its author and counters underneath. The three Figma
/// "Home" frames are its three pages.
class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key, required this.posts});

  final List<FeaturedPost> posts;

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
          child: PageView.builder(
            itemCount: posts.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => _HeroCard(post: posts[index]),
          ),
        ),
        const SizedBox(height: 16),
        _PostMeta(post: current),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.post});

  final FeaturedPost post;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FeedPhoto(path: post.imagePath, radius: 24),
        if (post.tags.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              verticalDirection: VerticalDirection.up,
              children: [
                for (final (index, tag) in post.tags.indexed)
                  _HeroTag(label: tag, highlighted: index == 0),
              ],
            ),
          ),
      ],
    );
  }
}

/// "Hero Tags" chip: the main style is filled with the brand gradient, the
/// rest are frosted.
class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? null : const Color(0x1AFFFFFF),
        gradient: highlighted ? AppColors.brandGradient : null,
        border: Border.all(color: const Color(0x26FFFFFF)),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        // The border is drawn inside the padding, as Figma does.
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: AppTypography.heroTag),
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
        SizedBox.square(
          dimension: 36,
          child: FeedPhoto.circle(path: author.avatarPath),
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
        _Counter(icon: AppIcons.heart, count: post.likeCount),
        const SizedBox(width: 16),
        _Counter(icon: AppIcons.messageCircle, count: post.commentCount),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.icon, required this.count});

  final String icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(icon, width: 16, height: 16),
        const SizedBox(width: 6),
        Text(compactCount(count), style: AppTypography.feedCount),
      ],
    );
  }
}
