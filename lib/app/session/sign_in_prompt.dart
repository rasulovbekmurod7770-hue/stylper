import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/snackbars.dart';
import 'session_cubit.dart';

/// Runs [action] for signed-in users; guests get a prompt to sign in instead
/// ([message], or the like / save one), so nothing changes on screen and then
/// changes back.
void runSignedIn(BuildContext context, VoidCallback action, {String? message}) {
  final session = context.read<SessionCubit>();
  if (session.state is! SessionGuest) return action();
  final l10n = context.l10n;
  context.showMessage(
    message ?? l10n.signInToInteract,
    actionLabel: l10n.signIn,
    onAction: session.leaveGuestMode,
  );
}
