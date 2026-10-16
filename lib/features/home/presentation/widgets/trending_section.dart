import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/widgets/post_grid.dart';

/// "Trending Section" (2775:2619): a city label over a staggered post grid.
class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key, required this.city, required this.posts});

  final String city;
  final List<PostPreview> posts;

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
                style: AppTypography.overline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        PostGrid(posts: posts),
      ],
    );
  }
}
