import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/session/sign_in_prompt.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/compact_count.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/user_profile.dart';
import '../cubits/following_cubit.dart';
import 'settings_sheet.dart';

/// The pinned bar over a profile ("hero-top" in Figma 2775:3285). Your own
/// profile has Share and Settings; someone else's has Back and More. Once the
/// big header scrolls away, it shows the avatar, name and handle — the
/// "condensed-header" of Figma "Profile 4" (2775:3374).
class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({
    super.key,
    required this.profile,
    required this.collapsed,
  });

  final UserProfile profile;
  final bool collapsed;

  static const height = 64.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void comingSoon() => context.showMessage(l10n.comingSoon);
    final leading = profile.isMe
        ? TopBarButton(
            card: true,
            label: l10n.profileShare,
            onTap: comingSoon,
            icon: SvgPicture.asset(AppIcons.share, width: 18, height: 18),
          )
        : const TopBarBackButton(card: true);
    final trailing = profile.isMe
        ? TopBarButton(
            card: true,
            label: l10n.profileSettings,
            onTap: () => showSettingsSheet(context),
            icon: SvgPicture.asset(AppIcons.settings, width: 18, height: 18),
          )
        // Not in Figma: someone else's profile has More instead.
        : TopBarButton(
            card: true,
            label: l10n.postMore,
            onTap: comingSoon,
            icon: SvgPicture.asset(
              AppIcons.moreHorizontal,
              width: 15,
              height: 3,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          );

    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Your own compact header starts with the avatar, as in Figma.
            if (!(profile.isMe && collapsed)) ...[
              leading,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: AnimatedOpacity(
                opacity: collapsed ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: !collapsed,
                  child: _CompactIdentity(profile: profile),
                ),
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _CompactIdentity extends StatelessWidget {
  const _CompactIdentity({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(name: profile.name, imagePath: profile.avatarPath, size: 54),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: AppTypography.subheading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '@${profile.handle}',
                style: AppTypography.captionMuted.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "hero-content": avatar, name, handle, bio, counts and the two buttons.
class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key, required this.profile});

  final UserProfile profile;

  /// Scrolled past this, the top bar shows the compact identity.
  static const collapseOffset = 150.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // "avatar-shell": a faint ring around the 88px photo.
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineSoft),
            ),
            child: UserAvatar(
              name: profile.name,
              imagePath: profile.avatarPath,
              size: 88,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.name,
            style: AppTypography.display,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '@${profile.handle}',
            style: AppTypography.bodyStrong.copyWith(color: AppColors.brandRed),
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              profile.bio,
              style: AppTypography.labelMuted.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 14),
          _Stats(profile: profile),
          const SizedBox(height: 14),
          _Actions(profile: profile),
        ],
      ),
    );
  }
}

/// "stats-row": 48 Posts • 1.2k Followers • 340 Following.
class _Stats extends StatelessWidget {
  const _Stats({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void comingSoon() => context.showMessage(l10n.comingSoon);
    // Includes a follow made anywhere in the app this session.
    final followers = context.select(
      (FollowingCubit cubit) =>
          cubit.state.of(profile.id, profile.followState).followerCount,
    );

    Widget stat(int count, String label, {VoidCallback? onTap}) =>
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Text(
            '${compactCount(count)} $label',
            style: AppTypography.label,
          ),
        );
    const dot = SizedBox.square(
      dimension: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.statDot,
        ),
      ),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 4,
      children: [
        stat(profile.postCount, l10n.profilePostsLabel(profile.postCount)),
        dot,
        stat(
          followers,
          l10n.profileFollowersLabel(followers),
          onTap: comingSoon,
        ),
        dot,
        stat(
          profile.followingCount,
          l10n.profileFollowingLabel(profile.followingCount),
          onTap: comingSoon,
        ),
      ],
    );
  }
}

/// Edit Profile + My Wardrobe on your own profile; Follow + Message on
/// someone else's.
class _Actions extends StatelessWidget {
  const _Actions({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void comingSoon() => context.showMessage(l10n.comingSoon);
    final following = context.select(
      (FollowingCubit cubit) =>
          cubit.state.of(profile.id, profile.followState).following,
    );

    final (first, second) = profile.isMe
        ? (
            ProfileButton(
              label: l10n.profileEdit,
              filled: false,
              onTap: comingSoon,
            ),
            ProfileButton(
              label: l10n.profileMyWardrobe,
              filled: true,
              onTap: context.openWardrobe,
            ),
          )
        : (
            ProfileButton(
              label: following
                  ? l10n.profileFollowingButton
                  : l10n.profileFollow,
              filled: !following,
              onTap: () => runSignedIn(
                context,
                () => context.read<FollowingCubit>().toggle(
                  profile.id,
                  profile.followState,
                ),
                message: l10n.signInToFollow,
              ),
            ),
            ProfileButton(
              label: l10n.profileMessage,
              filled: false,
              onTap: comingSoon,
            ),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: SizedBox(width: 140, child: first)),
        const SizedBox(width: 10),
        Flexible(child: SizedBox(width: 140, child: second)),
      ],
    );
  }
}

/// "edit-profile-btn": a 36px outlined pill, or filled with the brand
/// gradient — dark text on both, as in Figma.
class ProfileButton extends StatelessWidget {
  const ProfileButton({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: filled ? AppColors.brandGradient : null,
            border: Border.all(color: AppColors.outlineMedium),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            label,
            style: AppTypography.captionStrong,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
