import 'package:flutter/widgets.dart';

import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../../domain/entities/post.dart';

/// Two-column staggered grid of "Trending Card"s (Figma 2775:2625); each card
/// opens its post. Each post goes into the currently shorter column, which
/// reproduces the Figma arrangement for the seed data. Cards are 12px apart
/// both ways; Figma's lower, unfinished cards sit 19 and 24px down and use
/// 12px corners — the finished card component is followed.
class PostGrid extends StatelessWidget {
  const PostGrid({super.key, required this.posts});

  final List<PostPreview> posts;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - _gap) / 2;
        final (left, right) = _split(posts, columnWidth);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Column(posts: left)),
            const SizedBox(width: _gap),
            Expanded(child: _Column(posts: right)),
          ],
        );
      },
    );
  }

  static (List<PostPreview>, List<PostPreview>) _split(
    List<PostPreview> posts,
    double columnWidth,
  ) {
    final left = <PostPreview>[], right = <PostPreview>[];
    var (leftHeight, rightHeight) = (0.0, 0.0);
    for (final post in posts) {
      final height = columnWidth / post.aspectRatio + _gap;
      if (leftHeight <= rightHeight) {
        left.add(post);
        leftHeight += height;
      } else {
        right.add(post);
        rightHeight += height;
      }
    }
    return (left, right);
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.posts});

  final List<PostPreview> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, post) in posts.indexed) ...[
          if (index > 0) const SizedBox(height: PostGrid._gap),
          AspectRatio(
            aspectRatio: post.aspectRatio,
            child: _PostCard(post: post),
          ),
        ],
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final PostPreview post;

  @override
  Widget build(BuildContext context) {
    final (caption, handle) = (post.caption, post.authorHandle);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.openPost(post.id),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FeedPhoto(path: post.imagePath, radius: 20),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (caption != null)
                  Text(
                    caption,
                    style: AppTypography.feedCardCaption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (handle != null) ...[
                  const SizedBox(height: 2),
                  Text('@$handle', style: AppTypography.feedCardHandle),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
