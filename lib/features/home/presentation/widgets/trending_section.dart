import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/home_feed.dart';
import 'feed_photo.dart';

/// "Trending Section" (2775:2619): a city label, then a two-column staggered
/// grid of "Trending Card"s (2775:2625). Each post goes into the currently
/// shorter column, which reproduces the Figma arrangement for the seed data.
/// Cards are 12px apart both ways; Figma's lower, unfinished cards sit 19 and
/// 24px down and use 12px corners — the finished card component is followed.
class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key, required this.city, required this.posts});

  final String city;
  final List<TrendingPost> posts;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(AppIcons.mapPin, width: 16, height: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.homeTrendingIn(city).toUpperCase(),
                style: AppTypography.feedSectionLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnWidth = (constraints.maxWidth - _gap) / 2;
            final columns = _split(posts, columnWidth);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Column(posts: columns.$1)),
                const SizedBox(width: _gap),
                Expanded(child: _Column(posts: columns.$2)),
              ],
            );
          },
        ),
      ],
    );
  }

  static (List<TrendingPost>, List<TrendingPost>) _split(
    List<TrendingPost> posts,
    double columnWidth,
  ) {
    final left = <TrendingPost>[], right = <TrendingPost>[];
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

  final List<TrendingPost> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, post) in posts.indexed) ...[
          if (index > 0) const SizedBox(height: TrendingSection._gap),
          AspectRatio(
            aspectRatio: post.aspectRatio,
            child: _TrendingCard(post: post),
          ),
        ],
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.post});

  final TrendingPost post;

  @override
  Widget build(BuildContext context) {
    final (caption, handle) = (post.caption, post.authorHandle);
    return Stack(
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
    );
  }
}
