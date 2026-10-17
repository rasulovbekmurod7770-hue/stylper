import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/session/session_cubit.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../../core/widgets/stylper_wordmark.dart';
import '../../../post/presentation/cubits/post_engagement_cubit.dart';
import '../../../posting/presentation/cubits/published_posts_cubit.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/saved_posts_cubit.dart';
import '../profile_failure_message.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_sections.dart';

/// Figma: "Profile" (2775:3285) and, for the Saved tab, "Profile 4"
/// (2775:3374) — someone's personal style: who they are, their style DNA,
/// their looks, and (on your own profile) what you saved. Layout follows
/// the frames' cached metadata; styling is PROVISIONAL until their design
/// context is fetched.
///
/// Needs a [ProfileCubit] and, for your own profile, a [SavedPostsCubit].
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              current.followFailureCount != previous.followFailureCount,
          listener: (context, state) =>
              context.showMessage(state.failure!.message(l10n)),
        ),
        // Your profile stays alive under other tabs; show a post you just
        // published.
        BlocListener<PublishedPostsCubit, String?>(
          listener: (context, _) {
            final profile = context.read<ProfileCubit>();
            final isMe =
                profile.userId == ProfileRepository.me ||
                (profile.state.profile?.isMe ?? false);
            if (isMe) profile.refresh();
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) => switch (state) {
              ProfileState(status: ProfileStatus.ready, :final profile?) =>
                _ProfileView(profile: profile),
              ProfileState(status: ProfileStatus.failure) => Column(
                children: [
                  const ScreenTopBar(),
                  Expanded(
                    child: LoadErrorView(
                      message: state.failure!.message(l10n),
                      onRetry: context.read<ProfileCubit>().load,
                    ),
                  ),
                ],
              ),
              _ => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView({required this.profile});

  final UserProfile profile;

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _scroll = ScrollController();
  var _collapsed = false;
  var _tab = ProfileTab.posts;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final collapsed = _scroll.offset > ProfileHero.collapseOffset;
      if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _select(ProfileTab tab) {
    setState(() => _tab = tab);
    // Saved posts change elsewhere in the app, so reload on every visit.
    if (tab == ProfileTab.saved) context.read<SavedPostsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = widget.profile;
    final tabs = [
      ProfileTab.posts,
      // Saved posts are private.
      if (profile.isMe) ProfileTab.saved,
      ProfileTab.styleBoards,
    ];
    const gutter = EdgeInsets.symmetric(horizontal: 20);

    // The profile stays alive under other tabs; keep the Saved tab current
    // when posts are saved or unsaved anywhere.
    return BlocListener<PostEngagementCubit, PostEngagementState>(
      listenWhen: (previous, current) =>
          previous.overrides != current.overrides,
      listener: (context, _) {
        if (_tab == ProfileTab.saved) context.read<SavedPostsCubit>().load();
      },
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedBox(
              height: ProfileTopBar.height,
              child: ProfileTopBar(profile: profile, collapsed: _collapsed),
            ),
          ),
          SliverToBoxAdapter(child: ProfileHero(profile: profile)),
          if (profile.styles.isNotEmpty)
            SliverPadding(
              padding: gutter.copyWith(top: 22),
              sliver: SliverToBoxAdapter(
                child: StyleDnaSection(styles: profile.styles),
              ),
            ),
          if (profile.recentPosts.isNotEmpty)
            SliverPadding(
              padding: gutter.copyWith(top: 20),
              sliver: SliverToBoxAdapter(
                child: MyStyleSection(profile: profile),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedBox(
              height: ProfileTabBar.height,
              child: ProfileTabBar(
                tabs: tabs,
                selected: _tab,
                onSelected: _select,
              ),
            ),
          ),
          SliverPadding(
            padding: gutter.copyWith(top: 16),
            sliver: switch (_tab) {
              ProfileTab.posts when profile.recentPosts.isNotEmpty =>
                ProfilePostsGrid(posts: profile.recentPosts),
              ProfileTab.posts => _EmptyTab(l10n.profileNoPosts),
              ProfileTab.saved => const _SavedTab(),
              ProfileTab.styleBoards => _EmptyTab(l10n.profileStyleBoardsSoon),
            },
          ),
          SliverToBoxAdapter(
            // Room to scroll the last row above the floating tab bar.
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
          ),
        ],
      ),
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SavedPostsCubit, SavedPostsState>(
      builder: (context, state) => switch (state.status) {
        SavedPostsStatus.ready when state.posts.isEmpty => _EmptyTab(
          l10n.profileNoSaved,
        ),
        SavedPostsStatus.ready => SliverToBoxAdapter(
          child: SavedPostsGrid(posts: state.posts),
        ),
        SavedPostsStatus.failure => SliverToBoxAdapter(
          child: LoadErrorView(
            message: state.failure!.message(l10n),
            onRetry: context.read<SavedPostsCubit>().load,
          ),
        ),
        SavedPostsStatus.loading => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          ),
        ),
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          message,
          style: AppTypography.body,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PinnedBox extends SliverPersistentHeaderDelegate {
  const _PinnedBox({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(_PinnedBox oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}

/// The Profile tab for guests: sign in to get a profile.
class GuestProfileView extends StatelessWidget {
  const GuestProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.read<SessionCubit>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: StylperWordmark()),
              const SizedBox(height: 32),
              Text(
                l10n.profileGuestTitle,
                style: AppTypography.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.profileGuestMessage,
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ProfileButton(
                    label: l10n.signIn,
                    filled: true,
                    onTap: session.leaveGuestMode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
