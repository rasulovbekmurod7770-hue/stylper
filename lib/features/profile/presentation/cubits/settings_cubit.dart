import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/profile_settings.dart';
import '../../domain/usecases/profile_usecases.dart';

enum SettingsStatus { loading, loadFailure, ready }

final class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.loading,
    this.settings = const ProfileSettings(),
    this.saveFailed = false,
  });

  final SettingsStatus status;
  final ProfileSettings settings;

  /// The last change couldn't be saved and was undone.
  final bool saveFailed;

  @override
  List<Object?> get props => [status, settings, saveFailed];
}

/// The Settings sheet's toggles: each change shows at once and is undone if
/// it can't be saved.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._getSettings, this._updateSettings)
    : super(const SettingsState());

  final GetSettings _getSettings;
  final UpdateSettings _updateSettings;

  Future<void> load() async {
    emit(const SettingsState());
    final result = await _getSettings(const NoParams());
    if (isClosed) return;
    emit(
      result.match(
        (_) => const SettingsState(status: SettingsStatus.loadFailure),
        (settings) =>
            SettingsState(status: SettingsStatus.ready, settings: settings),
      ),
    );
  }

  Future<void> change(
    ProfileSettings Function(ProfileSettings settings) update,
  ) async {
    if (state.status != SettingsStatus.ready) return;
    final previous = state.settings;
    final next = update(previous);
    emit(SettingsState(status: SettingsStatus.ready, settings: next));
    final result = await _updateSettings(next);
    // A newer change replaced this one; its own result decides.
    if (isClosed || result.isRight() || state.settings != next) return;
    emit(
      SettingsState(
        status: SettingsStatus.ready,
        settings: previous,
        saveFailed: true,
      ),
    );
  }
}
