import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/money.dart';
import '../../domain/entities/wardrobe.dart';
import '../../domain/failures/wardrobe_failure.dart';
import '../../domain/usecases/wardrobe_usecases.dart';

final class AddItemState extends Equatable {
  const AddItemState({
    this.name = '',
    this.brand = '',
    this.category,
    this.price = '',
    this.submitting = false,
    this.failure,
  });

  final String name;
  final String brand;

  /// One of [WardrobeCategories]; the wardrobe groups items by it.
  final String? category;

  /// What the user typed in the optional price field.
  final String price;
  final bool submitting;
  final WardrobeFailure? failure;

  /// [price] in whole soʻm, like every price in the app (the field groups
  /// the digits, e.g. "350 000"); null when it's empty or not above 0.
  Money? get money {
    final amount = int.tryParse(price.replaceAll(RegExp(r'\D'), ''));
    return amount == null || amount <= 0
        ? null
        : Money(amount: amount, currency: appCurrency);
  }

  bool get priceValid => price.trim().isEmpty || money != null;

  /// Name, brand and category are required; the price is optional.
  bool get canSubmit =>
      name.trim().isNotEmpty &&
      brand.trim().isNotEmpty &&
      category != null &&
      priceValid &&
      !submitting;

  AddItemState copyWith({
    String? name,
    String? brand,
    String? category,
    String? price,
    bool? submitting,
    WardrobeFailure? Function()? failure,
  }) => AddItemState(
    name: name ?? this.name,
    brand: brand ?? this.brand,
    category: category ?? this.category,
    price: price ?? this.price,
    submitting: submitting ?? this.submitting,
    failure: failure == null ? this.failure : failure(),
  );

  @override
  List<Object?> get props => [
    name,
    brand,
    category,
    price,
    submitting,
    failure,
  ];
}

/// The "Item details" form (Figma 2974:66565): clothes the user adds to
/// their own wardrobe because no brand on Stylper sells them.
class AddItemCubit extends Cubit<AddItemState> {
  AddItemCubit(this._add) : super(const AddItemState());

  final AddWardrobeItem _add;

  /// A blank form, with [category] picked if known.
  void start({String? category}) => emit(AddItemState(category: category));

  void setName(String name) => emit(state.copyWith(name: name));

  void setBrand(String brand) => emit(state.copyWith(brand: brand));

  void setCategory(String category) => emit(state.copyWith(category: category));

  void setPrice(String price) => emit(state.copyWith(price: price));

  /// Saves the item to the wardrobe; the new item, or null if it failed
  /// (see [AddItemState.failure]) or the form isn't complete.
  Future<WardrobeItem?> submit() async {
    if (!state.canSubmit) return null;
    emit(state.copyWith(submitting: true, failure: () => null));
    final result = await _add(
      NewWardrobeItem(
        name: state.name.trim(),
        brand: state.brand.trim(),
        category: state.category!,
        price: state.money,
      ),
    );
    if (isClosed) return null;
    return result.match(
      (failure) {
        emit(state.copyWith(submitting: false, failure: () => failure));
        return null;
      },
      (item) {
        emit(state.copyWith(submitting: false));
        return item;
      },
    );
  }
}
