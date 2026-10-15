import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_typography.dart';

/// Stand-in for a main tab whose screen isn't built yet.
class TabPlaceholderPage extends StatelessWidget {
  const TabPlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTypography.title.copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            Text(context.l10n.comingSoon, style: AppTypography.subtitle),
          ],
        ),
      ),
    );
  }
}
