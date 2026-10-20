import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_assets.dart';
import '../l10n/l10n.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A 60px bar with a back button, a centred [title] and an optional trailing
/// action — the product screen's "Header" (Figma 2775:3084).
class ScreenTopBar extends StatelessWidget {
  const ScreenTopBar({super.key, this.title, this.trailing});

  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const TopBarBackButton(),
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  : Text(
                      title,
                      style: AppTypography.subheading,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            SizedBox.square(dimension: 36, child: trailing),
          ],
        ),
      ),
    );
  }
}

/// A 36px round button for a top bar: tinted, as the product header's
/// (2775:3085), or on the soft card colour with a faint outline, as the
/// profile's (2775:3297).
class TopBarButton extends StatelessWidget {
  const TopBarButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.icon,
    this.card = false,
  });

  final String label;
  final VoidCallback onTap;
  final Widget icon;
  final bool card;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: card ? AppColors.surfaceCard : AppColors.iconButtonFill,
            border: card ? Border.all(color: AppColors.socialBorder) : null,
          ),
          child: icon,
        ),
      ),
    );
  }
}

/// Pops the current screen, or goes home when there's nothing to pop.
class TopBarBackButton extends StatelessWidget {
  const TopBarBackButton({super.key, this.card = false});

  final bool card;

  @override
  Widget build(BuildContext context) {
    return TopBarButton(
      card: card,
      label: context.l10n.back,
      onTap: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.home),
      icon: SvgPicture.asset(AppIcons.arrowLeft, width: 20, height: 20),
    );
  }
}
