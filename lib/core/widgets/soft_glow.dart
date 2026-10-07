import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

/// The blurred pink "Glow" circle from the Figma file.
///
/// Figma exports it as an SVG with `feGaussianBlur`, which flutter_svg can't
/// render, so it is drawn natively with the same radius, sigma and opacity.
class SoftGlow extends StatelessWidget {
  const SoftGlow({
    super.key,
    required this.diameter,
    required this.blurSigma,
    this.color = AppColors.brandPink,
    this.opacity = 0.14,
  });

  final double diameter;
  final double blurSigma;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
          tileMode: TileMode.decal,
        ),
        child: SizedBox.square(
          dimension: diameter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: opacity),
            ),
          ),
        ),
      ),
    );
  }
}
