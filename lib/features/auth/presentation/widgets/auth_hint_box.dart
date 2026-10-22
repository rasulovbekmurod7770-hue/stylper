import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// A tinted box with an icon and a short reassuring note, as on the
/// forgot-password screen (Figma 2775:2408).
class AuthHintBox extends StatelessWidget {
  const AuthHintBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(AppIcons.check, width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.hint)),
        ],
      ),
    );
  }
}
