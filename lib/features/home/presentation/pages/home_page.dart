import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../domain/entities/home_feed.dart';
import '../cubits/home_feed_cubit.dart';
import '../home_failure_message.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/people_wearing_section.dart';
import '../widgets/trending_section.dart';

/// Figma: "Home" (2775:2563) — the editorial feed. Spacing follows the
/// frame's "Editorial Feed" layout; the floating tab bar belongs to the app
/// shell, which reports its height through the bottom media padding.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _gutter = 12.0;
  static const _sectionGap = 36.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<HomeFeedCubit>();

    return BlocListener<HomeFeedCubit, HomeFeedState>(
      // A failed refresh keeps the old feed on screen and just says so.
      listenWhen: (previous, current) =>
          current.status == HomeFeedStatus.failure &&
          current.feed != null &&
          previous.status != current.status,
      listener: (context, state) =>
          context.showMessage(state.failure!.message(l10n)),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: cubit.load,
            child: BlocBuilder<HomeFeedCubit, HomeFeedState>(
              builder: (context, state) => CustomScrollView(
                // Pull-to-refresh must work on the spinner / error too.
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: _Header()),
                  switch (state) {
                    HomeFeedState(:final feed?) => SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        _gutter,
                        0,
                        _gutter,
                        MediaQuery.paddingOf(context).bottom + 24,
                      ),
                      sliver: SliverList.list(children: _sections(feed)),
                    ),
                    HomeFeedState(status: HomeFeedStatus.failure) =>
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _LoadError(
                          message: state.failure!.message(l10n),
                          onRetry: cubit.load,
                        ),
                      ),
                    _ => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static List<Widget> _sections(HomeFeed feed) => [
    const _ForYouHeading(),
    const SizedBox(height: 16),
    FeaturedCarousel(posts: feed.featured),
    const SizedBox(height: _sectionGap),
    PeopleWearingSection(people: feed.peopleWearing),
    const SizedBox(height: _sectionGap),
    TrendingSection(city: feed.city, posts: feed.trending),
  ];
}

/// The gradient Stylper logo with the "For you · Following" feed tabs under
/// it; the feed starts 93px below the safe-area top, as in the frame.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 93,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Figma puts the logo 2px above the status bar's bottom edge.
          Positioned(
            top: -2,
            child: SvgPicture.asset(
              AppIcons.stylperLogoGradient,
              width: 95,
              height: 31.6667,
            ),
          ),
          // Cap-trimmed labels centred 55.5px down → baseline at 60.2px.
          const Positioned(
            top: 0,
            child: Baseline(
              baseline: 60.2,
              baselineType: TextBaseline.alphabetic,
              child: _FeedTabs(),
            ),
          ),
        ],
      ),
    );
  }
}

/// "For you" is the only feed so far; "Following" is shown dimmed.
class _FeedTabs extends StatelessWidget {
  const _FeedTabs();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget tab(String label, {required bool selected, VoidCallback? onTap}) =>
        Semantics(
          button: true,
          selected: selected,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 64.175),
              child: Opacity(
                opacity: selected ? 1 : 0.5,
                child: Text(label, style: AppTypography.feedTab),
              ),
            ),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        tab(l10n.homeForYou, selected: true),
        const SizedBox(width: 8.1),
        tab(
          l10n.homeFollowing,
          selected: false,
          onTap: () => context.showMessage(l10n.comingSoon),
        ),
      ],
    );
  }
}

class _ForYouHeading extends StatelessWidget {
  const _ForYouHeading();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeForYou.toUpperCase(),
          style: AppTypography.feedSectionLabel,
        ),
        const SizedBox(height: 6),
        Text(l10n.homeForYouTitle, style: AppTypography.feedSectionTitle),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.retry, style: AppTypography.link),
            ),
          ],
        ),
      ),
    );
  }
}
