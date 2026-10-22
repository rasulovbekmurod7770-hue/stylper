import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

extension TabNavigation on BuildContext {
  /// The main tab the current screen belongs to, e.g. `/home`.
  String get currentTab {
    final path = GoRouterState.of(this).uri.path;
    return AppRoutes.mainTabs.firstWhere(
      (tab) => path == tab || path.startsWith('$tab/'),
      orElse: () => AppRoutes.home,
    );
  }

  /// Pushes a detail screen ([subPath], e.g. `post/1`) on the current tab's
  /// stack, so Back returns here and the tab bar stays on the same tab.
  void pushInTab(String subPath) => push('$currentTab/$subPath');

  void openPost(String postId) => pushInTab('post/$postId');

  void openProduct(String productId) => pushInTab('product/$productId');

  /// All looks of a product, optionally only those in [style].
  void openProductLooks(String productId, {String? style}) => pushInTab(
    Uri(
      path: 'product/$productId/looks',
      queryParameters: style == null ? null : {'style': style},
    ).toString(),
  );

  void openUser(String userId) => pushInTab('user/$userId');

  /// Completes with `true` once the profile was saved.
  Future<bool?> openEditProfile() =>
      push<bool>(AppRoutes.editProfile(tab: currentTab));

  /// The signed-in user's wardrobe, which lives in the Profile tab.
  void openWardrobe() => currentTab == AppRoutes.profile
      ? push(AppRoutes.wardrobe)
      : go(AppRoutes.wardrobe);

  /// Completes when the user comes back from the category.
  Future<void> openWardrobeCategory(String category) =>
      push<void>(AppRoutes.wardrobeCategory(category));
}
