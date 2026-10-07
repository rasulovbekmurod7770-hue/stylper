import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Form submit button: 52px, radius 14, vertical brand-red → pink gradient.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Semantics(
      button: true,
      enabled: enabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onPressed == null && !isLoading ? 0.5 : 1,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: _radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.brandRed, AppColors.brandPink],
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: _radius,
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                height: 52,
                child: Center(
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : Text(label, style: AppTypography.button),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
