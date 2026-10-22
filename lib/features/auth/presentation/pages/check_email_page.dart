import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/fill_viewport_scroll_view.dart';
import '../../../../core/widgets/linked_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../widgets/auth_hint_box.dart';

/// Shown after sign-up when the account must be confirmed through the link
/// emailed to [email] before signing in. Not in Figma; built from the
/// forgot-password screen's pieces.
class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: FillViewportScrollView(
          child: Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScreenHeader(
                      title: l10n.checkEmailTitle,
                      subtitle: l10n.checkEmailSubtitle(email),
                      spacing: 12,
                      subtitleLineHeight: 1.5,
                    ),
                    const SizedBox(height: 32),
                    AuthHintBox(text: l10n.checkEmailHint),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: l10n.goToSignIn,
                      onPressed: () => context.go(AppRoutes.signIn),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: LinkedText(
                  template: l10n.wrongEmailPrompt('{link}'),
                  links: {
                    '{link}': TextLink(
                      l10n.signUpAgainLink,
                      () => context.go(AppRoutes.signUp),
                    ),
                  },
                  style: AppTypography.footer,
                  linkStyle: AppTypography.footerLink,
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
