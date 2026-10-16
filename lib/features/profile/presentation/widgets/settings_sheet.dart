import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/session/session_cubit.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Settings for the signed-in user (not in Figma): for now, signing out.
Future<void> showSettingsSheet(BuildContext context) {
  final session = context.read<SessionCubit>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                l10n.profileSettings,
                style: AppTypography.screenTitle,
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.logout, color: AppColors.accent),
              title: Text(
                l10n.signOut,
                style: AppTypography.button.copyWith(color: AppColors.accent),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                session.signOut();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
