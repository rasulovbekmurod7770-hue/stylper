import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/snackbars.dart';

/// The main tabs, in branch order of the router's shell route.
enum MainTab { home, search, explore, profile }

/// Hosts the current main tab under the floating tab bar from the Figma Home
/// frame ("bottom-nav-container", 2775:2643). The body extends behind the
/// bar; pages read the bar's height from `MediaQuery.paddingOf(context)`.
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
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: _FloatingTabBar(
        currentTab: currentTab,
        onTabSelected: onTabSelected,
      ),
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  const _FloatingTabBar({
    required this.currentTab,
    required this.onTabSelected,
  });

  final MainTab currentTab;
  final ValueChanged<MainTab> onTabSelected;

  /// Figma leaves 22px under the bar; never sit on the home indicator.
  static const _bottomGap = 22.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = math.max(
      _bottomGap,
      MediaQuery.viewPaddingOf(context).bottom,
    );

    Widget tab(MainTab tab, String icon, String label) => _TabButton(
      icon: icon,
      label: label,
      selected: tab == currentTab,
      onTap: () => onTabSelected(tab),
    );

    // Figma centres the 272×56 bar 5px left of the middle; it's centred here.
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Center(
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.navBorder),
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            // Drawn under the border, like Figma's inside stroke.
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                tab(MainTab.home, AppIcons.tabHome, l10n.tabHome),
                tab(MainTab.search, AppIcons.tabSearch, l10n.tabSearch),
                _CreateButton(
                  label: l10n.tabCreate,
                  onTap: () => context.showMessage(l10n.comingSoon),
                ),
                tab(MainTab.explore, AppIcons.tabExplore, l10n.tabExplore),
                tab(MainTab.profile, AppIcons.tabProfile, l10n.tabProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A 40px tab: the selected one sits in a brand-gradient circle with a dark
/// icon, the others are grey.
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: selected ? AppColors.brandGradient : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                selected ? AppColors.textPrimary : AppColors.iconInactive,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 32px "+" between the tabs ("tab-explore" 2775:2648 in Figma).
class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SvgPicture.asset(AppIcons.tabCreate, width: 32, height: 32),
      ),
    );
  }
}
