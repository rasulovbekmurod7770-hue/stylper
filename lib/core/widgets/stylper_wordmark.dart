import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../theme/app_typography.dart';

/// "Stylper" logotype with the translucent "hel" (→ helper) and "e" (→ Style)
/// overlays, positioned exactly as the Figma group (2779:3643).
class StylperWordmark extends StatelessWidget {
  const StylperWordmark({super.key});

  static const size = Size(187.142, 118.07);

  // Figma trims these text boxes to cap height, so their tops are cap lines;
  // Poppins Bold cap height is 0.705em → 36.55px at 51.84px.
  static const _capHeight = 36.55;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 27.29,
            child: SvgPicture.asset(
              AppIcons.stylperWordmark,
              width: 187.142,
              height: 61.69,
            ),
          ),
          const Positioned(
            left: 98.24,
            top: 0,
            child: _BaselineText('hel', baseline: _capHeight),
          ),
          const Positioned(
            left: 66.1,
            top: 0,
            child: _BaselineText('e', baseline: 81.07 + _capHeight),
          ),
        ],
      ),
    );
  }
}

class _BaselineText extends StatelessWidget {
  const _BaselineText(this.text, {required this.baseline});

  final String text;
  final double baseline;

  @override
  Widget build(BuildContext context) {
    return Baseline(
      baseline: baseline,
      baselineType: TextBaseline.alphabetic,
      child: Text(text, style: AppTypography.wordmarkOverlay),
    );
  }
}
