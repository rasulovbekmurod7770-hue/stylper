import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/css_gradient.dart';
import '../../../../core/widgets/linked_text.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../../core/widgets/soft_glow.dart';
import '../../domain/entities/style_quiz.dart';
import '../cubits/style_quiz_cubit.dart';
import '../onboarding_failure_message.dart';
import '../widgets/product_tag.dart';

/// Figma: "Dress like you." (2775:2389) — the user picks a top and a bottom
/// they like. The composition is laid out on the 390×766 Figma canvas (the
/// frame minus status bar and home indicator) and scaled to fit the screen.
class StyleQuizPage extends StatelessWidget {
  const StyleQuizPage({super.key});

  static const canvas = Size(390, 766);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<StyleQuizCubit, StyleQuizState>(
      listenWhen: (previous, current) =>
          current.status == StyleQuizStatus.failure &&
          previous.status != current.status,
      listener: (context, state) =>
          context.showMessage(state.failure!.message(l10n)),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: FittedBox(
              child: SizedBox.fromSize(
                size: canvas,
                child: BlocBuilder<StyleQuizCubit, StyleQuizState>(
                  builder: (context, state) => _QuizCanvas(state: state),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizCanvas extends StatelessWidget {
  const _QuizCanvas({required this.state});

  final StyleQuizState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<StyleQuizCubit>();
    final (top, bottom) = (state.top, state.bottom);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          left: 59,
          top: 261,
          child: SoftGlow(diameter: 283, blurSigma: 56.6),
        ),
        if (top != null)
          _ItemImage(
            item: top,
            rect: const Rect.fromLTWH(79.52, 153, 225.128, 185.832),
          ),
        _ChevronButton(
          asset: AppIcons.chevronLeftTall,
          rect: const Rect.fromLTWH(51, 261, 20, 23),
          label: l10n.previousItem(l10n.topsCategory),
          onTap: () => cubit.cycleTop(-1),
        ),
        _ChevronButton(
          asset: AppIcons.chevronLeftTall,
          rect: const Rect.fromLTWH(313, 261, 20, 23),
          mirrored: true,
          label: l10n.nextItem(l10n.topsCategory),
          onTap: () => cubit.cycleTop(1),
        ),
        _ChevronButton(
          asset: AppIcons.chevronLeft,
          rect: const Rect.fromLTWH(51, 447, 20, 22),
          label: l10n.previousItem(l10n.bottomsCategory),
          onTap: () => cubit.cycleBottom(-1),
        ),
        _ChevronButton(
          asset: AppIcons.chevronLeft,
          rect: const Rect.fromLTWH(313, 447, 20, 22),
          mirrored: true,
          label: l10n.nextItem(l10n.bottomsCategory),
          onTap: () => cubit.cycleBottom(1),
        ),
        if (bottom != null)
          _ItemImage(
            item: bottom,
            rect: const Rect.fromLTWH(106.55, 362.84, 174.995, 309.158),
          ),
        Positioned(
          left: 97,
          top: 703,
          width: 196,
          height: 31.972,
          child: _LikeButton(
            isLoading: state.status == StyleQuizStatus.submitting,
            onPressed: top != null && bottom != null ? cubit.submit : null,
          ),
        ),
        if (bottom != null)
          _CenteredAt(
            center: const Offset(276.57, 375),
            child: ProductTag(name: bottom.name, brand: bottom.brand),
          ),
        if (top != null)
          _CenteredAt(
            center: const Offset(108.5, 160.2),
            child: ProductTag(name: top.name, brand: top.brand),
          ),
        const Positioned(left: 51, top: _QuizTitle.top, child: _QuizTitle()),
      ],
    );
  }
}

class _QuizTitle extends StatelessWidget {
  const _QuizTitle();

  /// Figma places the CSS text box at y=72 with its baseline 19.26px lower;
  /// the line's ascent (Playfair 1.082em at 41.757px) puts the box top here.
  static const top = 72 + 19.26 - 45.18;
  static const _maxWidth = 288.0;

  // The gradient spans Figma's 282×25 text box, which starts 25.92px below
  // this widget's top.
  static final _gradientRect = Rect.fromLTWH(0, 72 - top, 282, 25.054);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (_) => cssLinearGradient(
        angleDegrees: 188.2152,
        colors: const [AppColors.brandRed, AppColors.brandPlum],
        stops: const [0.11905, 0.88095],
        rect: _gradientRect,
      ),
      child: SizedBox(
        width: _maxWidth,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topLeft,
          child: LinkedText(
            template: l10n.styleQuizTitle('{you}'),
            links: {'{you}': TextLink(l10n.styleQuizTitleEmphasis, null)},
            style: AppTypography.quizTitle,
            linkStyle: AppTypography.quizTitleAccent,
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.item, required this.rect});

  final OutfitItem item;
  final Rect rect;

  @override
  Widget build(BuildContext context) {
    final path = item.imagePath;
    return Positioned.fromRect(
      rect: rect,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: path.startsWith('http')
            ? Image.network(path, key: ValueKey(item.id), fit: BoxFit.cover)
            : Image.asset(path, key: ValueKey(item.id), fit: BoxFit.cover),
      ),
    );
  }
}

/// A chevron drawn at its Figma [rect], with a 44×44 tap target around it.
class _ChevronButton extends StatelessWidget {
  const _ChevronButton({
    required this.asset,
    required this.rect,
    required this.label,
    required this.onTap,
    this.mirrored = false,
  });

  final String asset;
  final Rect rect;
  final String label;
  final VoidCallback onTap;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: Rect.fromCenter(center: rect.center, width: 44, height: 44),
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: Transform.flip(
              flipX: mirrored,
              child: SvgPicture.asset(
                asset,
                width: rect.width,
                height: rect.height,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  static const _radius = BorderRadius.all(Radius.circular(22.936));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppColors.brandPlum,
      borderRadius: _radius,
      child: InkWell(
        borderRadius: _radius,
        onTap: isLoading ? null : onPressed,
        child: Center(
          child: isLoading
              ? const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: Colors.white,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LinkedText(
                      template: l10n.likeThisOutfit('{outfit}'),
                      links: {
                        '{outfit}': TextLink(l10n.likeThisOutfitEmphasis, null),
                      },
                      style: AppTypography.quizAction,
                      linkStyle: AppTypography.quizAction.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _CenteredAt extends StatelessWidget {
  const _CenteredAt({required this.center, required this.child});

  final Offset center;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx,
      top: center.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: child,
      ),
    );
  }
}
