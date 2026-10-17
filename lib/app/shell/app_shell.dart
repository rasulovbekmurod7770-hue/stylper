import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/snackbars.dart';
import '../../features/post/presentation/cubits/post_engagement_cubit.dart';
import '../../features/post/presentation/post_failure_message.dart';
import '../../features/profile/presentation/cubits/following_cubit.dart';
import '../../features/profile/presentation/profile_failure_message.dart';
import '../../features/wardrobe/presentation/cubits/wardrobe_membership_cubit.dart';
import '../../features/wardrobe/presentation/wardrobe_failure_message.dart';
import '../session/sign_in_prompt.dart';
import 'app_tab_bar.dart';

export 'app_tab_bar.dart' show MainTab;

/// Hosts every in-app screen (the tabs and the screens opened inside them)
/// over the one [AppTabBar]. The body extends behind the bar; pages read its
/// height from `MediaQuery.paddingOf(context)` to keep their last items
/// clear of it.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.child,
  });

  final MainTab currentTab;
  final ValueChanged<MainTab> onTabSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Likes, saves, wardrobe changes and follows the API refused (rolled
    // back).
    return MultiBlocListener(
      listeners: [
        BlocListener<PostEngagementCubit, PostEngagementState>(
          listenWhen: (previous, current) =>
              current.failureCount != previous.failureCount,
          listener: (context, state) =>
              context.showMessage(state.failure!.message(context.l10n)),
        ),
        BlocListener<WardrobeMembershipCubit, WardrobeMembershipState>(
          listenWhen: (previous, current) =>
              current.failureCount != previous.failureCount,
          listener: (context, state) =>
              context.showMessage(state.failure!.message(context.l10n)),
        ),
        BlocListener<FollowingCubit, FollowingState>(
          listenWhen: (previous, current) =>
              current.failureCount != previous.failureCount,
          listener: (context, state) =>
              context.showMessage(state.failure!.message(context.l10n)),
        ),
      ],
      child: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: AppTabBar(
          currentTab: currentTab,
          onTabSelected: onTabSelected,
          // Posting covers the tabs; guests are asked to sign in first.
          onCreate: () => runSignedIn(
            context,
            () => context.push(AppRoutes.create),
            message: context.l10n.signInToPost,
          ),
        ),
      ),
    );
  }
}
