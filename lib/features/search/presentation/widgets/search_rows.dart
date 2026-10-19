import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/image_source.dart';
import '../../../../core/router/tab_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../post/domain/entities/post.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/widgets/follow_button.dart';
import '../../domain/entities/search_results.dart';

// Built from the claude.ai "Stylper Prototype" (Search screen); there's no
// Figma frame yet, so the styling is PROVISIONAL.

/// A brand's logo, or a monogram until it has one: its first two letters
/// (or its words' initials), as in the prototype.
class BrandAvatar extends StatelessWidget {
  const BrandAvatar({super.key, required this.brand, this.size = 44});

  final BrandSummary brand;
  final double size;

  static String monogram(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.length > 1
        ? words.take(2).map((word) => word[0]).join()
        : name.trim().substring(0, name.trim().length.clamp(0, 2));
    return letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final logo = brand.logoPath;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceMuted,
        border: Border.all(color: AppColors.inputBorder),
        image: logo == null
            ? null
            : DecorationImage(image: imageFromPath(logo), fit: BoxFit.cover),
      ),
      child: logo != null
          ? null
          : ExcludeSemantics(
              child: Text(
                monogram(brand.name),
                style: AppTypography.captionStrong.copyWith(
                  fontSize: size * 0.27,
                ),
              ),
            ),
    );
  }
}

/// "Brands on Stylper": a brand's circle with its name under it.
class BrandChip extends StatelessWidget {
  const BrandChip({super.key, required this.brand});

  final BrandSummary brand;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: brand.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openBrand(context, brand),
        child: SizedBox(
          width: 64,
          child: Column(
            children: [
              BrandAvatar(brand: brand, size: 56),
              const SizedBox(height: 6),
              ExcludeSemantics(
                child: Text(
                  brand.name,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The brand profile (Figma 2856:1809) isn't built yet.
void openBrand(BuildContext context, BrandSummary brand) =>
    context.showMessage(context.l10n.comingSoon);

/// A brand in the results: logo, name with the official badge, @username,
/// how many items it sells, and whether it's a local brand.
class BrandRow extends StatelessWidget {
  const BrandRow({super.key, required this.brand});

  final BrandSummary brand;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Row(
      onTap: () => openBrand(context, brand),
      leading: BrandAvatar(brand: brand),
      title: Row(
        children: [
          Flexible(
            child: Text(
              brand.name,
              style: AppTypography.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (brand.isVerified) ...[
            const SizedBox(width: 4),
            // PROVISIONAL icon until a Figma badge is exported.
            Icon(
              Icons.verified,
              size: 14,
              color: AppColors.brandPink,
              semanticLabel: l10n.searchVerified,
            ),
          ],
        ],
      ),
      subtitle:
          '@${brand.handle} · ${l10n.searchBrandItems(brand.productCount)}',
      trailing: brand.isLocal
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: const BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Text(
                l10n.searchLocal,
                style: AppTypography.captionStrong.copyWith(
                  color: AppColors.brandRose,
                ),
              ),
            )
          : null,
    );
  }
}

/// A person in the results: photo, name, @username and Follow (not for
/// yourself). Opens their profile in the Search tab.
class PersonRow extends StatelessWidget {
  const PersonRow({super.key, required this.person});

  final PostAuthor person;

  @override
  Widget build(BuildContext context) {
    return _Row(
      onTap: () => context.openUser(person.id),
      leading: UserAvatar(
        name: person.name,
        imagePath: person.avatarPath,
        size: 44,
      ),
      title: Text(
        person.name,
        style: AppTypography.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: '@${person.handle}',
      trailing: person.isMe
          ? null
          : FollowButton(
              userId: person.id,
              loaded: FollowState(
                followerCount: person.followerCount,
                following: person.followedByMe,
              ),
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final VoidCallback onTap;
  final Widget leading;
  final Widget title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    leading,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTypography.captionMuted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing],
      ],
    );
  }
}
