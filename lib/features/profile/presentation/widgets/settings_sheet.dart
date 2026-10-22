import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/session/session_cubit.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../domain/entities/profile_settings.dart';
import '../cubits/settings_cubit.dart';

/// Settings for the signed-in user (not in Figma): privacy and notification
/// toggles, and signing out. Needs a [SettingsCubit] above [context].
Future<void> showSettingsSheet(BuildContext context) {
  final session = context.read<SessionCubit>();
  final settings = context.read<SettingsCubit>()..load();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    showDragHandle: true,
    builder: (sheetContext) => BlocProvider.value(
      value: settings,
      child: SettingsSheet(
        onSignOut: () {
          Navigator.of(sheetContext).pop();
          session.signOut();
        },
      ),
    ),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                l10n.profileSettings,
                style: AppTypography.subheading,
              ),
            ),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) => switch (state.status) {
                SettingsStatus.loading => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                ),
                SettingsStatus.loadFailure => _Note(
                  l10n.errorUnknown,
                  onRetry: context.read<SettingsCubit>().load,
                ),
                SettingsStatus.ready => _Toggles(state: state),
              },
            ),
            const Divider(height: 24, color: AppColors.outlineSoft),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.logout, color: AppColors.accent),
              title: Text(
                l10n.signOut,
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.accent,
                ),
              ),
              onTap: onSignOut,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Toggles extends StatelessWidget {
  const _Toggles({required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = state.settings;
    void change(ProfileSettings Function(ProfileSettings) update) =>
        context.read<SettingsCubit>().change(update);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(l10n.settingsPrivacy),
        _ToggleRow(
          title: l10n.settingsPrivateAccount,
          hint: l10n.settingsPrivateAccountHint,
          value: settings.isPrivate,
          onChanged: (on) => change((s) => s.copyWith(isPrivate: on)),
        ),
        _ToggleRow(
          title: l10n.settingsBrandFeatures,
          hint: l10n.settingsBrandFeaturesHint,
          value: settings.allowBrandFeatures,
          onChanged: (on) => change((s) => s.copyWith(allowBrandFeatures: on)),
        ),
        _ToggleRow(
          title: l10n.settingsShowLikeCounts,
          value: settings.showLikeCounts,
          onChanged: (on) => change((s) => s.copyWith(showLikeCounts: on)),
        ),
        _SectionTitle(l10n.settingsNotifications),
        _ToggleRow(
          title: l10n.settingsNotifyBrandActivity,
          hint: l10n.settingsNotifyBrandActivityHint,
          value: settings.notifyBrandActivity,
          onChanged: (on) =>
              change((s) => s.copyWith(notifyBrandActivity: on)),
        ),
        _ToggleRow(
          title: l10n.settingsNotifyDrops,
          hint: l10n.settingsNotifyDropsHint,
          value: settings.notifyDrops,
          onChanged: (on) => change((s) => s.copyWith(notifyDrops: on)),
        ),
        if (state.saveFailed) _Note(l10n.settingsSaveFailed),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Text(text.toUpperCase(), style: AppTypography.overline),
    );
  }
}

/// A setting: its title, an optional explanation, and a switch. The whole
/// row toggles it.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String title;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyStrong),
                    if (hint case final hint?)
                      Text(
                        hint,
                        style: AppTypography.captionMuted.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text, {this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: AppColors.accent),
            ),
          ),
          if (onRetry case final retry?)
            TextButton(onPressed: retry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}
