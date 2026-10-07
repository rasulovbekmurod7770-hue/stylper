import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/validation_messages.dart';
import '../../../../core/presentation/submission_status.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fill_viewport_scroll_view.dart';
import '../../../../core/widgets/linked_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/snackbars.dart';
import '../auth_failure_message.dart';
import '../cubits/forgot_password_cubit.dart';

/// Figma: "Screen-ForgotPassword" (2775:2408).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<ForgotPasswordCubit>().submit(_email.text);
  }

  void _backToSignIn() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case SubmissionStatus.success:
            context.showMessage(l10n.resetLinkSent(state.sentTo!));
            _backToSignIn();
          case SubmissionStatus.failure:
            context.showMessage(state.failure!.message(l10n));
          case SubmissionStatus.idle || SubmissionStatus.inProgress:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: FillViewportScrollView(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                    builder: (context, state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _BackButton(
                            label: l10n.back,
                            onPressed: _backToSignIn,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ScreenHeader(
                          title: l10n.forgotPasswordTitle,
                          subtitle: l10n.forgotPasswordSubtitle,
                          spacing: 12,
                          subtitleLineHeight: 1.5,
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: l10n.emailLabel,
                          iconAsset: AppIcons.mail,
                          controller: _email,
                          hintText: l10n.emailHint,
                          hintStyle: AppTypography.input.copyWith(
                            color: AppColors.textPlaceholder,
                          ),
                          errorText: state.emailError?.message(l10n),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.send,
                          autofillHints: const [AutofillHints.email],
                          autocorrect: false,
                          onChanged: (_) => context
                              .read<ForgotPasswordCubit>()
                              .fieldChanged(),
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 24),
                        _SecureHint(text: l10n.resetLinkHint),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          label: l10n.sendResetLink,
                          isLoading: state.status.isInProgress,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: LinkedText(
                    template: l10n.backToSignIn('{link}'),
                    links: {
                      '{link}': TextLink(l10n.backToSignInLink, _backToSignIn),
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
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.controlFillStrong,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.inputBorder),
        ),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: SvgPicture.asset(
                AppIcons.arrowLeft,
                width: 20,
                height: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecureHint extends StatelessWidget {
  const _SecureHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(AppIcons.check, width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.hint)),
        ],
      ),
    );
  }
}
