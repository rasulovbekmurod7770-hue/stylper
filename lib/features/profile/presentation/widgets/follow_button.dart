import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/session/sign_in_prompt.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/user_profile.dart';
import '../cubits/following_cubit.dart';

/// A small Follow / Following pill, e.g. next to a post's author. Agrees with
/// their profile through the app-wide [FollowingCubit]; guests are asked to
/// sign in.
class FollowButton extends StatelessWidget {
  const FollowButton({super.key, required this.userId, required this.loaded});

  final String userId;

  /// Whether the screen loaded them as followed, and their follower count.
  final FollowState loaded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final following = context.select(
      (FollowingCubit cubit) => cubit.state.of(userId, loaded).following,
    );

    // PROVISIONAL look (Figma's post frame has no Follow): the profile's
    // Follow button, made compact.
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => runSignedIn(
          context,
          () => context.read<FollowingCubit>().toggle(userId, loaded),
          message: l10n.signInToFollow,
        ),
        child: Container(
          height: 28,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: following ? null : AppColors.brandGradient,
            border: following
                ? Border.all(color: AppColors.outlineStrong)
                : null,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            following ? l10n.profileFollowingButton : l10n.profileFollow,
            style: AppTypography.captionStrong.copyWith(
              color: following ? null : Colors.white,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
