import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/wardrobe_failure.dart';
import '../../domain/usecases/wardrobe_usecases.dart';

final class WardrobeMembershipState extends Equatable {
  const WardrobeMembershipState({
    this.overrides = const {},
    this.failure,
    this.failureCount = 0,
  });

  /// Products saved / removed in this session, by product id. They win over
  /// what a screen loaded, so every "save to wardrobe" control agrees.
  final Map<String, bool> overrides;

  /// The last save that failed; [failureCount] changes with each one.
  final WardrobeFailure? failure;
  final int failureCount;

  /// Whether [productId] is in the wardrobe, given the [loaded] state.
  bool contains(String productId, {required bool loaded}) =>
      overrides[productId] ?? loaded;

  @override
  List<Object?> get props => [overrides, failure, failureCount];
}

/// App-wide wardrobe membership. Toggles update optimistically and roll back
/// if the API refuses.
class WardrobeMembershipCubit extends Cubit<WardrobeMembershipState> {
  WardrobeMembershipCubit(this._setInWardrobe)
    : super(const WardrobeMembershipState());

  final SetInWardrobe _setInWardrobe;
  final _inFlight = <String>{};

  /// Adds or removes [productId]; true when the API confirmed the change.
  Future<bool> toggle(String productId, {required bool current}) async {
    if (!_inFlight.add(productId)) return false;
    _put(productId, !current);
    final result = await _setInWardrobe(
      WardrobeToggle(productId, saved: !current),
    );
    if (isClosed || !_inFlight.remove(productId)) return false;
    return result.match(
      (failure) {
        _put(productId, current, failure: failure);
        return false;
      },
      (saved) {
        _put(productId, saved);
        return true;
      },
    );
  }

  /// Records that [itemId] left the wardrobe some other way (e.g. removed on
  /// the category screen).
  void removed(String itemId) => _put(itemId, false);

  /// Records an item the user just added themselves, so screens that list
  /// the wardrobe refresh.
  void added(String itemId) => _put(itemId, true);

  /// Forgets this session's changes, e.g. when another user signs in.
  void reset() {
    _inFlight.clear();
    emit(const WardrobeMembershipState());
  }

  void _put(String productId, bool saved, {WardrobeFailure? failure}) {
    emit(
      WardrobeMembershipState(
        overrides: {...state.overrides, productId: saved},
        failure: failure ?? state.failure,
        failureCount: state.failureCount + (failure == null ? 0 : 1),
      ),
    );
  }
}
