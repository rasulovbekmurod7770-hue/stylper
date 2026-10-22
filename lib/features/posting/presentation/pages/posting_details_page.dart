import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/style_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../cubits/post_draft_cubit.dart';
import '../widgets/posting_widgets.dart';

/// Figma: "Screen3-PostDetails" (2820:198) — caption, location, the outfit's
/// styles and the brands it mentions. Styling is PROVISIONAL (from the
/// frame's screenshot).
class PostingDetailsPage extends StatefulWidget {
  const PostingDetailsPage({super.key});

  @override
  State<PostingDetailsPage> createState() => _PostingDetailsPageState();
}

class _PostingDetailsPageState extends State<PostingDetailsPage> {
  late final _caption = TextEditingController(
    text: context.read<PostDraftCubit>().state.draft.caption,
  );
  late final _location = TextEditingController(
    text: context.read<PostDraftCubit>().state.draft.location,
  );

  @override
  void dispose() {
    _caption.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PostDraftCubit>();
    final state = context.watch<PostDraftCubit>().state;
    final draft = state.draft;
    final photo = draft.photoPath;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PostingTopBar(
              title: l10n.postingDetails,
              onNext: () => context.push(AppRoutes.createPublish),
            ),
            const PostingSteps(current: 2),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                children: [
                  // "MiniPreviewCard".
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          SizedBox.square(
                            dimension: 80,
                            child: photo == null
                                ? null
                                : FeedPhoto(path: photo, radius: 10),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.postingReadyToPublish,
                                  style: AppTypography.label,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.postingItemsTagged(draft.tags.length),
                                  style: AppTypography.captionMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _Section(l10n.postingCaption),
                  TextField(
                    controller: _caption,
                    onChanged: cubit.setCaption,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    style: _inputStyle,
                    decoration: _field(l10n.postingCaptionHint)
                        .copyWith(counterText: ''),
                  ),
                  _Section(l10n.postingLocation),
                  TextField(
                    controller: _location,
                    onChanged: cubit.setLocation,
                    textCapitalization: TextCapitalization.words,
                    style: _inputStyle,
                    decoration: _field(l10n.postingLocationHint).copyWith(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          AppIcons.mapPin,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            AppColors.brandPink,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _Section(l10n.profileStyleDna),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final style in state.styleOptions)
                        _StylePill(
                          label: l10n.styleLabel(style),
                          selected: draft.styles.contains(style),
                          onTap: () => cubit.toggleStyle(style),
                        ),
                    ],
                  ),
                  _Section(l10n.postingMentionedBrands),
                  if (draft.brands.isEmpty)
                    Text(
                      l10n.postingNoBrands,
                      style: AppTypography.captionMuted,
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final brand in draft.brands)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.outlineStrong,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                            child: Text(
                              brand,
                              style: AppTypography.captionStrong,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final _inputStyle = AppTypography.label.copyWith(
    fontWeight: FontWeight.w400,
  );

  static InputDecoration _field(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.labelMuted.copyWith(color: AppColors.textSubtle),
    filled: true,
    fillColor: AppColors.surfaceMuted,
    contentPadding: const EdgeInsets.all(14),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(title.toUpperCase(), style: AppTypography.overline),
  );
}

/// A "Style DNA" pill: pink when picked.
class _StylePill extends StatelessWidget {
  const _StylePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandPink : AppColors.surfaceMuted,
            border: selected ? null : Border.all(color: AppColors.inputBorder),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: selected ? Colors.white : AppColors.textSubtle,
            ),
          ),
        ),
      ),
    );
  }
}
