import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wardrobe.dart';
import '../../domain/failures/wardrobe_failure.dart';
import '../../domain/usecases/wardrobe_usecases.dart';

enum WardrobeItemsStatus { loading, ready, failure }

final class WardrobeItemsState extends Equatable {
  const WardrobeItemsState({
    this.status = WardrobeItemsStatus.loading,
    this.items = const [],
    this.failure,
  });

  final WardrobeItemsStatus status;
  final List<WardrobeItem> items;
  final WardrobeFailure? failure;

  @override
  List<Object?> get props => [status, items, failure];
}

/// The items in one wardrobe category.
class WardrobeItemsCubit extends Cubit<WardrobeItemsState> {
  WardrobeItemsCubit(this._getItems, {required this.category})
    : super(const WardrobeItemsState());

  final GetWardrobeItems _getItems;
  final String category;

  Future<void> load() async {
    emit(const WardrobeItemsState());
    final result = await _getItems(category);
    if (isClosed) return;
    emit(
      result.match(
        (failure) => WardrobeItemsState(
          status: WardrobeItemsStatus.failure,
          failure: failure,
        ),
        (items) =>
            WardrobeItemsState(status: WardrobeItemsStatus.ready, items: items),
      ),
    );
  }

  /// Drops [item] from the list once it has left the wardrobe.
  void removed(WardrobeItem item) => emit(
    WardrobeItemsState(
      status: state.status,
      items: [
        for (final other in state.items)
          if (other.id != item.id) other,
      ],
    ),
  );
}
