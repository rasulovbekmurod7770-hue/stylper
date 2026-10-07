import 'package:flutter/widgets.dart';

import '../theme/app_typography.dart';

/// Title + subtitle block at the top of the auth and onboarding forms.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.spacing = 8,
    this.subtitleLineHeight = 1.4,
  });

  final String title;
  final String subtitle;
  final double spacing;
  final double subtitleLineHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTypography.title),
        SizedBox(height: spacing),
        Text(
          subtitle,
          style: AppTypography.subtitle.copyWith(height: subtitleLineHeight),
        ),
      ],
    );
  }
}
