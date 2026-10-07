import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/validation_messages.dart';
import '../../../../core/presentation/submission_status.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fill_viewport_scroll_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../domain/entities/profile_details.dart';
import '../cubits/profile_setup_cubit.dart';
import '../onboarding_failure_message.dart';
import '../widgets/gender_selector.dart';

/// Figma: "profile-setup" (2775:2501).
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _username = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<ProfileSetupCubit>().submit(
      username: _username.text,
      age: _age.text,
      heightCm: _height.text,
      weightKg: _weight.text,
    );
  }

  void _goToStyleQuiz() => context.go(AppRoutes.styleQuiz);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ProfileSetupCubit>();

    return BlocListener<ProfileSetupCubit, ProfileSetupState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SubmissionStatus.success) _goToStyleQuiz();
        if (state.status == SubmissionStatus.failure && !state.usernameTaken) {
          context.showMessage(state.failure!.message(l10n));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: FillViewportScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 61, 24, 24),
              child: BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
                builder: (context, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScreenHeader(
                      title: l10n.profileSetupTitle,
                      subtitle: l10n.profileSetupSubtitle,
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: l10n.usernameLabel,
                      iconAsset: AppIcons.atSign,
                      controller: _username,
                      hintText: l10n.usernameHint,
                      errorText: state.usernameTaken
                          ? state.failure!.message(l10n)
                          : state.usernameError?.message(l10n),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newUsername],
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[@A-Za-z0-9_.]'),
                        ),
                        LengthLimitingTextInputFormatter(21),
                      ],
                      onChanged: (_) => cubit.fieldChanged(),
                    ),
                    const SizedBox(height: 16),
                    GenderSelector(
                      label: l10n.genderLabel,
                      maleLabel: l10n.genderMale,
                      femaleLabel: l10n.genderFemale,
                      selected: state.gender,
                      errorText: state.genderError?.message(l10n),
                      onSelected: cubit.genderSelected,
                    ),
                    const SizedBox(height: 16),
                    _NumberField(
                      label: l10n.ageLabel,
                      iconAsset: AppIcons.calendar,
                      controller: _age,
                      hintText: l10n.ageHint,
                      maxLength: 3,
                      errorText: state.ageError?.message(
                        l10n,
                        min: ProfileLimits.minAge,
                        max: ProfileLimits.maxAge,
                      ),
                      onChanged: cubit.fieldChanged,
                    ),
                    const SizedBox(height: 16),
                    _NumberField(
                      label: l10n.heightLabel,
                      iconAsset: AppIcons.ruler,
                      controller: _height,
                      hintText: l10n.heightHint,
                      maxLength: 3,
                      errorText: state.heightError?.message(
                        l10n,
                        min: ProfileLimits.minHeightCm,
                        max: ProfileLimits.maxHeightCm,
                      ),
                      onChanged: cubit.fieldChanged,
                    ),
                    const SizedBox(height: 16),
                    _NumberField(
                      label: l10n.weightLabel,
                      iconAsset: AppIcons.scale,
                      controller: _weight,
                      hintText: l10n.weightHint,
                      maxLength: 3,
                      textInputAction: TextInputAction.done,
                      errorText: state.weightError?.message(
                        l10n,
                        min: ProfileLimits.minWeightKg,
                        max: ProfileLimits.maxWeightKg,
                      ),
                      onChanged: cubit.fieldChanged,
                      onSubmitted: _submit,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: l10n.continueButton,
                      isLoading: state.status.isInProgress,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: state.status.isInProgress
                            ? null
                            : _goToStyleQuiz,
                        child: Text(
                          l10n.skipForNow,
                          style: AppTypography.secondaryAction,
                        ),
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

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.iconAsset,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    required this.onChanged,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final String label;
  final String iconAsset;
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final VoidCallback onChanged;
  final String? errorText;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      iconAsset: iconAsset,
      controller: controller,
      hintText: hintText,
      errorText: errorText,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      onChanged: (_) => onChanged(),
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
    );
  }
}
