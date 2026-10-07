import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/validation_messages.dart';
import '../../../../core/presentation/submission_status.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_password_field.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fill_viewport_scroll_view.dart';
import '../../../../core/widgets/linked_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/snackbars.dart';
import '../auth_failure_message.dart';
import '../cubits/sign_up_cubit.dart';
import '../widgets/auth_error_listeners.dart';
import '../widgets/social_auth_section.dart';

/// Figma: "sign-up" (2775:2441).
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<SignUpCubit>().submit(
      email: _email.text,
      password: _password.text,
      confirmPassword: _confirmPassword.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SignUpCubit>();

    return SocialSignInErrorListener(
      child: BlocListener<SignUpCubit, SignUpState>(
        listenWhen: (previous, current) =>
            current.status == SubmissionStatus.failure &&
            previous.status != current.status,
        listener: (context, state) =>
            context.showMessage(state.failure!.message(l10n)),
        child: Scaffold(
          body: SafeArea(
            child: FillViewportScrollView(
              child: AutofillGroup(
                child: Column(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: BlocBuilder<SignUpCubit, SignUpState>(
                        builder: (context, state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ScreenHeader(
                              title: l10n.createAccount,
                              subtitle: l10n.signUpSubtitle,
                            ),
                            const SizedBox(height: 24),
                            AppTextField(
                              label: l10n.emailLabel,
                              iconAsset: AppIcons.mail,
                              controller: _email,
                              hintText: l10n.emailHint,
                              errorText: state.emailError?.message(l10n),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              onChanged: (_) => cubit.fieldChanged(),
                            ),
                            const SizedBox(height: 16),
                            AppPasswordField(
                              label: l10n.passwordLabel,
                              controller: _password,
                              hintText: l10n.passwordHint,
                              showPasswordLabel: l10n.showPassword,
                              hidePasswordLabel: l10n.hidePassword,
                              errorText: state.passwordError?.message(l10n),
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              onChanged: (_) => cubit.fieldChanged(),
                            ),
                            const SizedBox(height: 16),
                            AppPasswordField(
                              label: l10n.confirmPasswordLabel,
                              controller: _confirmPassword,
                              hintText: l10n.confirmPasswordHint,
                              showPasswordLabel: l10n.showPassword,
                              hidePasswordLabel: l10n.hidePassword,
                              errorText: state.confirmPasswordError?.message(
                                l10n,
                              ),
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onChanged: (_) => cubit.fieldChanged(),
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 16),
                            _TermsRow(
                              accepted: state.termsAccepted,
                              errorText: state.termsError?.message(l10n),
                              onChanged: cubit.termsToggled,
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              label: l10n.createAccount,
                              isLoading: state.status.isInProgress,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 24),
                            SocialAuthSection(
                              dividerText: l10n.orSignUpWith,
                              dividerStyle: AppTypography.divider.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: LinkedText(
                        template: l10n.haveAccountPrompt('{link}'),
                        links: {
                          '{link}': TextLink(
                            l10n.signInLink,
                            () => context.go(AppRoutes.signIn),
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
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.accepted,
    required this.onChanged,
    this.errorText,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AppSwitch(value: accepted, onChanged: onChanged),
              const SizedBox(width: 12),
              Expanded(
                // TODO(stylper): open the documents once they are published.
                child: LinkedText(
                  template: l10n.termsAcceptance('{terms}', '{privacy}'),
                  links: {
                    '{terms}': TextLink(l10n.termsOfService, null),
                    '{privacy}': TextLink(l10n.privacyPolicy, null),
                  },
                  style: AppTypography.footer.copyWith(height: 1.3),
                  linkStyle: AppTypography.footerLink.copyWith(height: 1.3),
                ),
              ),
            ],
          ),
        ),
        if (errorText case final error?) ...[
          const SizedBox(height: 2),
          Text(error, style: AppTypography.fieldError),
        ],
      ],
    );
  }
}
