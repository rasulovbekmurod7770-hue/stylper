import 'package:flutter/widgets.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../../../post/presentation/open_post.dart';
import '../../domain/entities/home_feed.dart';

/// "People Wearing Section" (2775:2605): a label with a short rule, then a
/// horizontally scrolling row of 108px person cards; each opens that person's
/// outfit post.
class PeopleWearingSection extends StatelessWidget {
  const PeopleWearingSection({super.key, required this.people});

  final List<PersonPreview> people;

  static const _cardSize = 108.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.homePeopleWearing.toUpperCase(),
              style: AppTypography.feedSectionLabel,
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 24,
              height: 1,
              child: ColoredBox(color: AppColors.hairline),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: _cardSize + 8 + 18,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Let cards scroll out under the screen edge, past the gutter.
            clipBehavior: Clip.none,
            itemCount: people.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final person = people[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => openPost(context, person.postId),
                child: SizedBox(
                  width: _cardSize,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox.square(
                        dimension: _cardSize,
                        child: FeedPhoto(path: person.photoPath, radius: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        person.name,
                        style: AppTypography.feedPersonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
