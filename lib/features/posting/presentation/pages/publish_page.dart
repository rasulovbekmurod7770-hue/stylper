import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/style_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';
import '../cubits/post_draft_cubit.dart';
import '../cubits/published_posts_cubit.dart';
import '../posting_failure_message.dart';
import '../widgets/posting_widgets.dart';

/// Figma: "Screen4-FinalizePublish" (2820:253) — the post as others will see
/// it, whether brands may feature it, and Publish. There's no "Share to
/// followers": every post is visible to everyone on Stylper. Styling is
/// PROVISIONAL (from the frame's screenshot).
///
/// Needs the signed-in user's [ProfileCubit] for the preview's name.
class PublishPage extends StatelessWidget {
  const PublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PostDraftCubit>();

    return BlocListener<PostDraftCubit, PostDraftState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case PublishStatus.published:
            context.read<PublishedPostsCubit>().published(
              state.publishedPostId!,
            );
            context.go(AppRoutes.profile);
            context.showMessage(l10n.postingPublished);
          case PublishStatus.failure:
            context.showMessage(state.failure!.message(l10n));
          case PublishStatus.editing || PublishStatus.publishing:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<PostDraftCubit, PostDraftState>(
            builder: (context, state) => Column(
              children: [
                PostingTopBar(title: l10n.postingPublish, showNext: false),
                const PostingSteps(current: 3),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    children: [
                      _PreviewCard(state: state),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.postingAllowBrandFeature,
                                  style: AppTypography.label,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.postingAllowBrandFeatureHint,
                                  style: AppTypography.meta,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          AppSwitch(
                            value: state.draft.allowBrandFeature,
                            onChanged: cubit.setAllowBrandFeature,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Always in reach, however long the preview is.
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    children: [
                      _PublishButton(
                        busy: state.status == PublishStatus.publishing,
                        onTap: cubit.publish,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.postingVisibleToEveryone,
                        style: AppTypography.meta,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "PreviewCard": who's posting, the photo, the caption and the styles.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.state});

  final PostDraftState state;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    final photo = draft.photoPath;
    final profile = context.select((ProfileCubit cubit) => cubit.state.profile);
    final place = draft.location.trim();
    final handle = profile == null ? '' : '@${profile.handle}';

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: ColoredBox(
        color: AppColors.surfaceMuted,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  UserAvatar(
                    name: profile?.name ?? '',
                    imagePath: profile?.avatarPath,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile?.name ?? '', style: AppTypography.label),
                        Text(
                          [
                            handle,
                            place,
                          ].where((s) => s.isNotEmpty).join(' · '),
                          style: AppTypography.meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (photo != null)
              AspectRatio(
                // Figma's preview (350×390), a little shorter than the post
                // screen's photo, so Publish fits below it.
                aspectRatio: 350 / 390,
                child: FeedPhoto(path: photo, radius: 0),
              ),
            if (draft.caption.trim().isNotEmpty || draft.styles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (draft.caption.trim().isNotEmpty)
                      Text(
                        draft.caption.trim(),
                        style: AppTypography.label.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    if (draft.styles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: [
                          for (final style in draft.styles)
                            Text(
                              '#${context.l10n.styleLabel(style).replaceAll(' ', '')}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.brandPink,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "CTAButton": Publish to Stylper.
class _PublishButton extends StatelessWidget {
  const _PublishButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !busy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: busy ? null : onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.all(Radius.circular(26)),
          ),
          child: busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                )
              : Text(
                  context.l10n.postingPublishCta,
                  style: AppTypography.bodyStrong,
                ),
        ),
      ),
    );
  }
}
