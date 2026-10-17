import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubits/post_draft_cubit.dart';

/// Wraps the whole posting flow: leaving it with back (from the first step)
/// asks before throwing away a started post. Later steps just go back one.
class DiscardGuard extends StatelessWidget {
  const DiscardGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final empty = context.select(
      (PostDraftCubit cubit) => cubit.state.draft.isEmpty,
    );
    return PopScope(
      canPop: empty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await confirmDiscard(context) && context.mounted) {
          _leave(context);
        }
      },
      child: child,
    );
  }
}

/// Closes the posting flow, asking first if a post was started.
Future<void> closePosting(BuildContext context) async {
  final empty = context.read<PostDraftCubit>().state.draft.isEmpty;
  if (!empty && !await confirmDiscard(context)) return;
  if (context.mounted) _leave(context);
}

/// Back to the screen posting was opened from.
void _leave(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(AppRoutes.home);

/// Asks before throwing away a started post.
Future<bool> confirmDiscard(BuildContext context) async {
  final l10n = context.l10n;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            l10n.postingDiscardTitle,
            style: AppTypography.subheading,
          ),
          content: Text(l10n.postingDiscardBody, style: AppTypography.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel, style: AppTypography.bodyStrong),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                l10n.postingDiscard,
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ) ??
      false;
}
