import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/wardrobe.dart';
import '../../domain/failures/wardrobe_failure.dart';
import '../../domain/usecases/wardrobe_usecases.dart';

enum WardrobeStatus { loading, ready, failure }

final class WardrobeState extends Equatable {
  const WardrobeState({
    this.status = WardrobeStatus.loading,
    this.categories = const [],
    this.failure,
  });

  final WardrobeStatus status;
  final List<WardrobeCategory> categories;
  final WardrobeFailure? failure;

  @override
  List<Object?> get props => [status, categories, failure];
}

/// The wardrobe's categories with their item counts.
class WardrobeCubit extends Cubit<WardrobeState> {
  WardrobeCubit(this._getWardrobe) : super(const WardrobeState());

  final GetWardrobe _getWardrobe;

  Future<void> load() async {
    // Keep the cards on screen while reloading (e.g. back from a category).
    if (state.categories.isEmpty) emit(const WardrobeState());
    final result = await _getWardrobe(const NoParams());
    if (isClosed) return;
    emit(
      result.match(
        (failure) => WardrobeState(
          status: WardrobeStatus.failure,
          categories: state.categories,
          failure: failure,
        ),
        (categories) =>
            WardrobeState(status: WardrobeStatus.ready, categories: categories),
      ),
    );
  }
}
