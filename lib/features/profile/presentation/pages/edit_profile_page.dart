import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/validation_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../domain/entities/profile_settings.dart';
import '../cubits/edit_profile_cubit.dart';
import '../profile_failure_message.dart';

/// Edit Profile: name, username and bio. Not in Figma; built from the
/// profile-setup form's pieces. Pops with `true` once saved.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    context.read<EditProfileCubit>().save(
      name: _name.text,
      username: _username.text,
      bio: _bio.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<EditProfileCubit>();

    return BlocListener<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case EditProfileStatus.ready when state.failure == null:
            // Loaded: start from what the profile shows.
            final profile = state.profile!;
            _name.text = profile.name;
            _username.text = profile.handle;
            _bio.text = profile.bio;
          case EditProfileStatus.ready when !state.usernameTaken:
            context.showMessage(state.failure!.message(l10n));
          case EditProfileStatus.saved:
            context.pop(true);
          case _:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenTopBar(title: l10n.editProfileTitle),
              Expanded(
                child: BlocBuilder<EditProfileCubit, EditProfileState>(
                  builder: (context, state) => switch (state.status) {
                    EditProfileStatus.loading => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    EditProfileStatus.loadFailure => LoadErrorView(
                      message: state.failure!.message(l10n),
                      onRetry: cubit.load,
                    ),
                    _ => ListView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        8,
                        24,
                        24 + MediaQuery.paddingOf(context).bottom,
                      ),
                      children: [
                        AppTextField(
                          label: l10n.profileNameLabel,
                          iconAsset: AppIcons.tabProfile,
                          controller: _name,
                          hintText: l10n.profileNameHint,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              ProfileLimits.maxNameLength,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: l10n.usernameLabel,
                          iconAsset: AppIcons.atSign,
                          controller: _username,
                          hintText: l10n.usernameHint,
                          errorText: state.usernameTaken
                              ? state.failure!.message(l10n)
                              : state.usernameError?.message(l10n),
                          textInputAction: TextInputAction.next,
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
                        AppTextField(
                          label: l10n.profileBioLabel,
                          iconAsset: AppIcons.messageCircle,
                          controller: _bio,
                          hintText: l10n.profileBioHint,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              ProfileLimits.maxBioLength,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: l10n.profileSave,
                          isLoading: state.status == EditProfileStatus.saving,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
