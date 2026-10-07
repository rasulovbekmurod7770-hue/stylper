import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/snackbars.dart';
import '../auth_failure_message.dart';
import '../cubits/social_sign_in_cubit.dart';

/// Shows a snackbar whenever Google/Apple sign-in fails.
class SocialSignInErrorListener extends StatelessWidget {
  const SocialSignInErrorListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocialSignInCubit, SocialSignInState>(
      listenWhen: (previous, current) =>
          current.failure != null && previous.failure != current.failure,
      listener: (context, state) =>
          context.showMessage(state.failure!.message(context.l10n)),
      child: child,
    );
  }
}
