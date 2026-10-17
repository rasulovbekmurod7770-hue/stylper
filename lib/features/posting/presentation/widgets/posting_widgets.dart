import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/image_source.dart';
import '../../../../core/presentation/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feed_photo.dart';
import '../../../post/presentation/widgets/tagged_photo.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/post_draft.dart';

/// "TopBar" of the posting steps: close (step 1) or back, the title, and
/// "Next" when there's a next step.
class PostingTopBar extends StatelessWidget {
  const PostingTopBar({
    super.key,
    required this.title,
    this.onClose,
    this.onNext,
    this.showNext = true,
  });

  final String title;

  /// Step 1 closes the flow instead of going back.
  final VoidCallback? onClose;

  /// Null while "Next" isn't possible yet (e.g. no photo chosen).
  final VoidCallback? onNext;
  final bool showNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final close = onClose;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Semantics(
                  button: true,
                  label: close == null ? l10n.back : l10n.close,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: close ?? () => context.pop(),
                    child: SizedBox.square(
                      dimension: 36,
                      child: Center(
                        child: close == null
                            ? SvgPicture.asset(
                                AppIcons.arrowLeft,
                                width: 20,
                                height: 20,
                              )
                            // PROVISIONAL icon until "x-circle" is exported.
                            : const Icon(
                                Icons.highlight_off,
                                size: 22,
                                color: AppColors.textPrimary,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: AppTypography.subheading,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 80,
            child: !showNext
                ? null
                : Semantics(
                    button: true,
                    enabled: onNext != null,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onNext,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            l10n.postingNext,
                            style: AppTypography.bodyStrong.copyWith(
                              color: onNext == null
                                  ? AppColors.outlineStrong
                                  : AppColors.brandRose,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// "StepIndicator": four dashes; the current step is long and rose.
class PostingSteps extends StatelessWidget {
  const PostingSteps({super.key, required this.current});

  /// 0–3.
  final int current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 19,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          for (var step = 0; step < 4; step++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: step == current ? 24 : 8,
              height: 3,
              decoration: BoxDecoration(
                color: step == current
                    ? AppColors.brandRose
                    : AppColors.surfaceMuted,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Horizontal product card": the cut-out, name, brand and price.
class ProductResultCard extends StatelessWidget {
  const ProductResultCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final ProductSummary product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: ColoredBox(
            color: AppColors.surfaceCard,
            child: SizedBox(
              height: 84,
              child: Row(
                children: [
                  Container(
                    width: 112,
                    color: AppColors.imageBackdrop,
                    padding: const EdgeInsets.all(8),
                    child: Image(
                      image: imageFromPath(product.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTypography.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(product.brand, style: AppTypography.meta),
                          const Spacer(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              formatPrice(product.price, l10n.localeName),
                              style: AppTypography.captionMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "ImageCanvas": the photo with its tags. Tapping the photo reports where
/// (as fractions), to tag the clothes there; each tag can be removed. It has
/// the post screen's proportions, so tags land where they will be shown.
class TagCanvas extends StatelessWidget {
  const TagCanvas({
    super.key,
    required this.photoPath,
    required this.tags,
    required this.onTapPhoto,
    required this.onRemoveTag,
    this.pending,
  });

  final String photoPath;
  final List<DraftTag> tags;
  final void Function(double x, double y) onTapPhoto;
  final ValueChanged<DraftTag> onRemoveTag;

  /// Where the user just tapped, while they pick the item.
  final Offset? pending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pending = this.pending;
    return AspectRatio(
      aspectRatio: TaggedPhoto.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTapUp: (details) => onTapPhoto(
                      (details.localPosition.dx / size.width).clamp(0, 1),
                      (details.localPosition.dy / size.height).clamp(0, 1),
                    ),
                    child: FeedPhoto(path: photoPath, radius: 0),
                  ),
                ),
                // "Tap anywhere on the photo to tag clothes".
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: IgnorePointer(
                    child: Center(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xB3414248),
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Text(
                            l10n.postingTapToTag,
                            style: AppTypography.onPhotoLabel,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                for (final tag in tags)
                  _PlacedTag(
                    tag: tag,
                    canvas: size,
                    onRemove: () => onRemoveTag(tag),
                  ),
                if (pending != null)
                  Positioned(
                    left: pending.dx * size.width - 6,
                    top: pending.dy * size.height - 6,
                    child: const _Dot(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.brandPink,
      border: Border.all(color: Colors.white, width: 2),
    ),
  );
}

/// A placed tag: the dot, and "Brand · Item" with a ✕ to remove it.
class _PlacedTag extends StatelessWidget {
  const _PlacedTag({
    required this.tag,
    required this.canvas,
    required this.onRemove,
  });

  final DraftTag tag;
  final Size canvas;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final center = Offset(tag.x * canvas.width, tag.y * canvas.height);
    final flip = tag.x > 0.55;
    return Positioned(
      left: flip ? null : center.dx - 6,
      right: flip ? canvas.width - center.dx - 6 : null,
      top: center.dy - 13,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: flip ? TextDirection.rtl : TextDirection.ltr,
        children: [
          const _Dot(),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xE6F5F4F2),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: canvas.width * 0.5),
                    child: Text(
                      '${tag.brand} · ${tag.label}',
                      style: AppTypography.captionStrong,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: context.l10n.postingRemoveTag,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onRemove,
                      child: const SizedBox.square(
                        dimension: 22,
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "TipBox": a hint with an info icon.
class PostingTip extends StatelessWidget {
  const PostingTip({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        child: Row(
          children: [
            // PROVISIONAL icon until "info" is exported.
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.brandPink,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.postingTip,
                style: AppTypography.meta.copyWith(color: AppColors.textSubtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A search field look-alike ("SearchBar") that opens the search.
class PostingSearchField extends StatelessWidget {
  const PostingSearchField({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 41,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.textSubtle),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.postingSearchHint,
                  style: AppTypography.labelMuted.copyWith(
                    color: AppColors.textSubtle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
