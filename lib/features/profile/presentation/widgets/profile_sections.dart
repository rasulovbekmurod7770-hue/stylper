import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/style_labels.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/cubits/post_engagement_cubit.dart';
import '../../domain/entities/user_profile.dart';

/// "style-dna-section": the person's style tags, each a faint chip with a
/// brand-red dot.
class StyleDnaSection extends StatelessWidget {
  const StyleDnaSection({super.key, required this.styles});

  final List<String> styles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.profileStyleDna.toUpperCase(),
          style: AppTypography.overline,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final style in styles)
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.controlFillStrong,
                  border: Border.all(color: AppColors.outlineSoft),
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox.square(
                      dimension: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brandRed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.styleLabel(style),
                      style: AppTypography.captionStrong,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// "my-style-section": a large look beside two small ones; each opens its
/// post.
class MyStyleSection extends StatelessWidget {
  const MyStyleSection({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final looks = profile.recentPosts.take(3).toList();

    Widget look(PostPreview post) => GestureDetector(
      onTap: () => context.openPost(post.id),
      child: FeedPhoto(path: post.imagePath, radius: 20),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (profile.isMe ? l10n.profileMyStyle : l10n.profileStyle)
              .toUpperCase(),
          style: AppTypography.overline,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 320,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: look(looks.first)),
              if (looks.length > 1) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: look(looks[1])),
                      if (looks.length > 2) ...[
                        const SizedBox(height: 12),
                        Expanded(child: look(looks[2])),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

enum ProfileTab { posts, saved, styleBoards }

/// "tab-header": Posts / Saved / Style Boards over a faint rule, the active
/// one underlined in brand red.
class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<ProfileTab> tabs;
  final ProfileTab selected;
  final ValueChanged<ProfileTab> onSelected;

  static const height = 44.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.socialBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            for (final tab in tabs)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: tab == selected,
                  child: GestureDetector(
                    key: ValueKey(tab),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelected(tab),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          switch (tab) {
                            ProfileTab.posts => l10n.profileTabPosts,
                            ProfileTab.saved => l10n.profileTabSaved,
                            ProfileTab.styleBoards =>
                              l10n.profileTabStyleBoards,
                          },
                          style: tab == selected
                              ? AppTypography.bodyStrong
                              : AppTypography.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 40,
                          height: 2,
                          child: tab == selected
                              ? const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.brandRed,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(1),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "posts-grid": three columns of 112×114 thumbnails; each opens its post.
class ProfilePostsGrid extends StatelessWidget {
  const ProfilePostsGrid({super.key, required this.posts});

  final List<PostPreview> posts;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 112 / 114,
      children: [
        for (final post in posts)
          GestureDetector(
            onTap: () => context.openPost(post.id),
            child: FeedPhoto(path: post.imagePath, radius: 18),
          ),
      ],
    );
  }
}

/// The Saved tab (Figma "Profile 4" grid): two staggered columns of
/// "saved-card"s — the photo with a bookmark that unsaves it, and who posted
/// it. Posts unsaved this session drop out.
class SavedPostsGrid extends StatelessWidget {
  const SavedPostsGrid({super.key, required this.posts});

  final List<SavedPost> posts;

  static const _gap = 16.0;
  static const _infoHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final engagement = context.watch<PostEngagementCubit>().state;
    final visible = [
      for (final saved in posts)
        if (engagement.overrides[saved.post.id]?.saved ?? true) saved,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - _gap) / 2;
        final columns = (<SavedPost>[], <SavedPost>[]);
        var (left, right) = (0.0, 0.0);
        for (final saved in visible) {
          final height = width / saved.post.aspectRatio + _infoHeight + _gap;
          if (left <= right) {
            columns.$1.add(saved);
            left += height;
          } else {
            columns.$2.add(saved);
            right += height;
          }
        }
        Widget column(List<SavedPost> items) => Column(
          children: [
            for (final (index, saved) in items.indexed) ...[
              if (index > 0) const SizedBox(height: _gap),
              _SavedCard(saved: saved),
            ],
          ],
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: column(columns.$1)),
            const SizedBox(width: _gap),
            Expanded(child: column(columns.$2)),
          ],
        );
      },
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.saved});

  final SavedPost saved;

  @override
  Widget build(BuildContext context) {
    final post = saved.post;
    final author = saved.author;
    const shape = BorderRadius.all(Radius.circular(24));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.openPost(post.id),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: shape,
        ),
        // The outline is drawn over the photo's top edge.
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: AppColors.socialBorder),
          borderRadius: shape,
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: post.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FeedPhoto(path: post.imagePath, radius: 0),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _UnsaveButton(saved: saved),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: SavedPostsGrid._infoHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    UserAvatar(
                      name: author.name,
                      imagePath: author.avatarPath,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '@${author.handle}',
                        style: AppTypography.captionMuted.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "bookmark-tag": a dark translucent disc with the gradient bookmark;
/// tapping unsaves.
class _UnsaveButton extends StatelessWidget {
  const _UnsaveButton({required this.saved});

  final SavedPost saved;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.postSaved,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.read<PostEngagementCubit>().toggleSave(
          saved.post.id,
          saved.engagement,
        ),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0x80000000),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            AppIcons.bookmarkFilled,
            width: 14,
            height: 14,
          ),
        ),
      ),
    );
  }
}
