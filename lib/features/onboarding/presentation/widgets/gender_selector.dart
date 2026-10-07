import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/profile_details.dart';

/// Two pill options; the selected one gets the brand gradient.
class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.label,
    required this.maleLabel,
    required this.femaleLabel,
    required this.selected,
    required this.onSelected,
    this.errorText,
  });

  final String label;
  final String maleLabel;
  final String femaleLabel;
  final Gender? selected;
  final ValueChanged<Gender> onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppTypography.fieldLabel),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Option(
                label: maleLabel,
                selected: selected == Gender.male,
                onTap: () => onSelected(Gender.male),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Option(
                label: femaleLabel,
                selected: selected == Gender.female,
                onTap: () => onSelected(Gender.female),
              ),
            ),
          ],
        ),
        if (errorText case final error?) ...[
          const SizedBox(height: 6),
          Text(error, style: AppTypography.fieldError),
        ],
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(22));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        decoration: selected
            ? const BoxDecoration(
                borderRadius: _radius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.brandRed, AppColors.brandPink],
                ),
              )
            : BoxDecoration(
                borderRadius: _radius,
                color: AppColors.inputFill,
                border: Border.all(color: AppColors.inputBorder),
              ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _radius,
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: selected
                    ? AppTypography.chipSelected
                    : AppTypography.chip,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
