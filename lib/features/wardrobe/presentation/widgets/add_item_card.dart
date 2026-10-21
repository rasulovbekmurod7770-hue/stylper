import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// "add-item-card" (Figma 2789:279, 2974:66603): a wide card with a red "+"
/// disc to add clothes to the wardrobe — on the wardrobe and when tagging a
/// post.
class AddItemCard extends StatelessWidget {
  const AddItemCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            border: Border.all(color: AppColors.socialBorder),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandRed,
                ),
                child: SvgPicture.asset(AppIcons.plus, width: 16, height: 16),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.wardrobeAddNewItem,
                style: AppTypography.bodyStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
