import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/session/sign_in_prompt.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/compact_count.dart';
import '../../domain/entities/post.dart';
import '../cubits/post_engagement_cubit.dart';

/// Heart + like count. Shows this session's likes from
/// [PostEngagementCubit] over the [loaded] state; guests are asked to sign in.
class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.postId,
    required this.loaded,
    required this.iconSize,
    required this.countStyle,
  });

  final String postId;
  final PostEngagement loaded;
  final double iconSize;
  final TextStyle countStyle;

  @override
  Widget build(BuildContext context) {
    final engagement = context.select(
      (PostEngagementCubit cubit) => cubit.state.of(postId, loaded),
    );
    final count = compactCount(engagement.likeCount);
    return Semantics(
      button: true,
      toggled: engagement.liked,
      label: context.l10n.postLike,
      value: count,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => runSignedIn(
          context,
          () => context.read<PostEngagementCubit>().toggleLike(
            postId,
            engagement,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              engagement.liked ? AppIcons.heartFilled : AppIcons.heart,
              width: iconSize,
              height: iconSize,
            ),
            const SizedBox(width: 6),
            ExcludeSemantics(child: Text(count, style: countStyle)),
          ],
        ),
      ),
    );
  }
}

/// Bookmark toggle for saving a post.
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.postId,
    required this.loaded,
    required this.iconSize,
  });

  final String postId;
  final PostEngagement loaded;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final engagement = context.select(
      (PostEngagementCubit cubit) => cubit.state.of(postId, loaded),
    );
    return Semantics(
      button: true,
      toggled: engagement.saved,
      label: context.l10n.postSave,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => runSignedIn(
          context,
          () => context.read<PostEngagementCubit>().toggleSave(
            postId,
            engagement,
          ),
        ),
        child: SvgPicture.asset(
          engagement.saved ? AppIcons.bookmarkFilled : AppIcons.bookmark,
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}
