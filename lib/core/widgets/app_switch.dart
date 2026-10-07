import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Compact 40×24 switch from the sign-up terms row.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: _duration,
          width: 40,
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: value ? AppColors.switchTrackOn : AppColors.switchTrackOff,
            borderRadius: BorderRadius.circular(100),
          ),
          child: AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOut,
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: const SizedBox.square(
              dimension: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
