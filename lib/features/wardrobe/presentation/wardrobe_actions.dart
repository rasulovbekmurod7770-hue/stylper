import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/session/sign_in_prompt.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/snackbars.dart';
import 'cubits/wardrobe_membership_cubit.dart';

/// Whether [productId] is in the wardrobe, rebuilding when it changes.
bool watchInWardrobe(
  BuildContext context,
  String productId, {
  required bool loaded,
}) => context.select(
  (WardrobeMembershipCubit cubit) =>
      cubit.state.contains(productId, loaded: loaded),
);

/// Adds [productId] to the wardrobe, or removes it ([inWardrobe]). Guests
/// are asked to sign in. With [announce], a snackbar confirms the change —
/// for small controls whose own change is easy to miss.
void toggleInWardrobe(
  BuildContext context,
  String productId, {
  required bool inWardrobe,
  bool announce = false,
}) => runSignedIn(context, () async {
  final l10n = context.l10n;
  final done = await context.read<WardrobeMembershipCubit>().toggle(
    productId,
    current: inWardrobe,
  );
  if (done && announce && context.mounted) {
    context.showMessage(inWardrobe ? l10n.wardrobeRemoved : l10n.wardrobeAdded);
  }
});
