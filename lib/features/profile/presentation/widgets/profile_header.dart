import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/session/sign_in_prompt.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/compact_count.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/user_profile.dart';
import '../cubits/profile_cubit.dart';
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
    // PROVISIONAL icons until the frames' button icons are exported.
    final leading = profile.isMe
        ? TopBarButton(
            label: l10n.profileShare,
            onTap: comingSoon,
            icon: const Icon(
              Icons.ios_share,
              size: 18,
              color: AppColors.textPrimary,
            ),
          )
        : const TopBarBackButton();
    final trailing = profile.isMe
        ? TopBarButton(
            label: l10n.profileSettings,
            onTap: () => showSettingsSheet(context),
            icon: const Icon(
              Icons.settings_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
          )
        : TopBarButton(
            label: l10n.postMore,
            onTap: comingSoon,
            icon: const Icon(
              Icons.more_horiz,
              size: 18,
              color: AppColors.textPrimary,
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
        UserAvatar(name: profile.name, imagePath: profile.avatarPath, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: AppTypography.profileCompactName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '@${profile.handle}',
                style: AppTypography.profileCompactHandle,
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
          // "avatar-shell": a brand-gradient ring around the 88px photo.
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brandGradient,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: UserAvatar(
                name: profile.name,
                imagePath: profile.avatarPath,
                size: 88,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.name,
            style: AppTypography.profileName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text('@${profile.handle}', style: AppTypography.profileHandle),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              profile.bio,
              style: AppTypography.profileBio,
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

    Widget stat(int count, String label, {VoidCallback? onTap}) =>
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: compactCount(count),
                  style: AppTypography.profileStatCount,
                ),
                TextSpan(
                  text: ' $label',
                  style: AppTypography.profileStatLabel,
                ),
              ],
            ),
          ),
        );
    const dot = SizedBox.square(
      dimension: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textMuted,
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
          profile.followerCount,
          l10n.profileFollowersLabel(profile.followerCount),
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
              label: profile.followedByMe
                  ? l10n.profileFollowingButton
                  : l10n.profileFollow,
              filled: !profile.followedByMe,
              onTap: () => runSignedIn(
                context,
                context.read<ProfileCubit>().toggleFollow,
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

/// "edit-profile-btn": a 36px pill, filled with the brand gradient or
/// outlined.
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
    // PROVISIONAL look until the frame's design context is cached.
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
            border: filled ? null : Border.all(color: AppColors.outlineStrong),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            label,
            style: AppTypography.profileButton.copyWith(
              color: filled ? Colors.white : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
