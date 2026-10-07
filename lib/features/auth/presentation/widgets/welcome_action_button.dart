import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// The 60px buttons on the welcome screen: a filled pink gradient variant and
/// an outlined variant.
class WelcomeActionButton extends StatelessWidget {
  const WelcomeActionButton.filled({
    super.key,
    required this.label,
    required this.onPressed,
  }) : _filled = true;

  const WelcomeActionButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
  }) : _filled = false;

  final String label;
  final VoidCallback onPressed;
  final bool _filled;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    final decoration = _filled
        ? const BoxDecoration(
            borderRadius: _radius,
            gradient: LinearGradient(
              colors: [AppColors.brandPink, AppColors.brandPinkLight],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33FF627B),
                offset: Offset(0, 12),
                blurRadius: 12,
              ),
            ],
          )
        : BoxDecoration(
            borderRadius: _radius,
            color: AppColors.controlFill,
            border: Border.all(color: AppColors.outlineStrong),
          );

    return Semantics(
      button: true,
      child: DecoratedBox(
        decoration: decoration,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _radius,
            onTap: onPressed,
            child: SizedBox(
              height: 60,
              child: Center(
                child: Text(label, style: AppTypography.welcomeButton),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
