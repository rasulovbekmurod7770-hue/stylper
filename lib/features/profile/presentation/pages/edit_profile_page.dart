import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/validation_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../uploads/presentation/upload_failure_message.dart';
import '../../domain/entities/profile_settings.dart';
import '../cubits/edit_profile_cubit.dart';
import '../profile_failure_message.dart';

/// Edit Profile: photo, name, username and bio. Not in Figma; built from the
/// profile-setup form's pieces and the profile's avatar. Pops with `true` once
/// saved.
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

    return MultiBlocListener(
      listeners: [
        BlocListener<EditProfileCubit, EditProfileState>(
          listenWhen: (previous, current) =>
              previous.status == EditProfileStatus.loading &&
              current.status == EditProfileStatus.ready,
          // Loaded: start from what the profile shows.
          listener: (context, state) {
            final profile = state.profile!;
            _name.text = profile.name;
            _username.text = profile.handle;
            _bio.text = profile.bio;
          },
        ),
        BlocListener<EditProfileCubit, EditProfileState>(
          listenWhen: (previous, current) =>
              current.failure != previous.failure &&
              current.status == EditProfileStatus.ready &&
              !current.usernameTaken,
          listener: (context, state) {
            if (state.failure case final failure?) {
              context.showMessage(failure.message(l10n));
            }
          },
        ),
        BlocListener<EditProfileCubit, EditProfileState>(
          listenWhen: (previous, current) =>
              current.photoFailure != previous.photoFailure,
          listener: (context, state) {
            if (state.photoFailure case final failure?) {
              context.showMessage(failure.message(l10n));
            }
          },
        ),
        BlocListener<EditProfileCubit, EditProfileState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == EditProfileStatus.saved,
          listener: (context, state) => context.pop(true),
        ),
      ],
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
                        _PhotoField(state: state),
                        const SizedBox(height: 16),
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

/// The profile photo, tappable to pick, take or remove one; dimmed with a
/// spinner while a picked photo uploads.
class _PhotoField extends StatelessWidget {
  const _PhotoField({required this.state});

  final EditProfileState state;

  static const _size = 88.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasPhoto = state.photoPath != null;
    final onTap = state.status == EditProfileStatus.ready
        ? () => _showPhotoSheet(context, hasPhoto: hasPhoto)
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              UserAvatar(
                name: state.profile!.name,
                imagePath: state.photoPath,
                size: _size,
              ),
              if (state.uploadingPhoto)
                const SizedBox.square(
                  dimension: _size,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glass,
                    ),
                    child: Center(
                      child: SizedBox.square(
                        dimension: 28,
                        child: CircularProgressIndicator(
                          color: AppColors.background,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            hasPhoto ? l10n.profilePhotoChange : l10n.profilePhotoAdd,
            style: AppTypography.captionStrong.copyWith(
              color: AppColors.brandRose,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showPhotoSheet(BuildContext context, {required bool hasPhoto}) {
  final cubit = context.read<EditProfileCubit>();
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    showDragHandle: true,
    builder: (sheetContext) {
      Widget action(
        IconData icon,
        String label,
        VoidCallback onTap, {
        Color color = AppColors.textPrimary,
      }) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: AppTypography.bodyStrong.copyWith(color: color),
        ),
        onTap: () {
          Navigator.of(sheetContext).pop();
          onTap();
        },
      );
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            action(
              Icons.photo_library_outlined,
              l10n.profilePhotoLibrary,
              cubit.choosePhoto,
            ),
            if (cubit.canTakePhoto)
              action(
                Icons.photo_camera_outlined,
                l10n.profilePhotoCamera,
                () => cubit.choosePhoto(camera: true),
              ),
            if (hasPhoto)
              action(
                Icons.delete_outline,
                l10n.profilePhotoRemove,
                cubit.removePhoto,
                color: AppColors.accent,
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
