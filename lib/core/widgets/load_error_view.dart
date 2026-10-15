import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_typography.dart';

/// A centred error [message] with a "Try again" button, for screens whose
/// content failed to load.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.retry, style: AppTypography.link),
            ),
          ],
        ),
      ),
    );
  }
}
