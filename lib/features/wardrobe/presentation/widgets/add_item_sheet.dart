import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/wardrobe.dart';
import '../cubits/add_item_cubit.dart';
import '../cubits/wardrobe_membership_cubit.dart';
import '../wardrobe_category_label.dart';
import '../wardrobe_failure_message.dart';

/// Finds the sheet's "Add Item" button in tests, in any language.
@visibleForTesting
const addItemSubmitKey = ValueKey('add-item-submit');

/// Opens "Item details" (Figma 2974:66565) to add clothes no brand on
/// Stylper sells to the user's wardrobe, with [category] picked if known;
/// completes with the new item, or null if dismissed. Needs an
/// [AddItemCubit] above [context].
Future<WardrobeItem?> showAddItemSheet(
  BuildContext context, {
  String? category,
}) async {
  final cubit = context.read<AddItemCubit>()..start(category: category);
  final membership = context.read<WardrobeMembershipCubit>();
  final item = await showModalBottomSheet<WardrobeItem>(
    context: context,
    // Over the tab bar, which sits above the tabs' own navigators.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: AppColors.sheetBorder),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _AddItemForm()),
  );
  // Lets screens that list the wardrobe refresh.
  if (item != null) membership.added(item.id);
  return item;
}

class _AddItemForm extends StatelessWidget {
  const _AddItemForm();

  static const _categories = WardrobeCategories.all;

  /// Whole soʻm, up to 10 digits, grouped as they're typed ("350 000").
  static TextInputFormatter _price(String locale) {
    final grouping = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    );
    return TextInputFormatter.withFunction((previous, next) {
      final digits = next.text.replaceAll(RegExp(r'\D'), '');
      if (digits.length > 10) return previous;
      final text = digits.isEmpty ? '' : grouping.format(int.parse(digits));
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AddItemCubit>();
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bottom = keyboard > 0 ? 0.0 : MediaQuery.paddingOf(context).bottom;

    return Padding(
      // Rise with the keyboard.
      padding: EdgeInsets.only(bottom: keyboard),
      child: BlocBuilder<AddItemCubit, AddItemState>(
        builder: (context, state) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 32, 20, bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.addItemTitle, style: AppTypography.subheading),
              const SizedBox(height: 5),
              Text(l10n.addItemSubtitle, style: AppTypography.captionMuted),
              const SizedBox(height: 20),
              _Field(
                label: l10n.addItemName,
                child: TextField(
                  autofocus: true,
                  onChanged: cubit.setName,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  style: _inputStyle,
                  decoration: _input(l10n.addItemNameHint),
                ),
              ),
              const SizedBox(height: 18),
              _Field(
                label: l10n.addItemBrand,
                child: TextField(
                  onChanged: cubit.setBrand,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: _inputStyle,
                  decoration: _input(l10n.addItemBrandHint),
                ),
              ),
              const SizedBox(height: 18),
              // Not in Figma: the wardrobe groups items by category.
              _Field(
                label: l10n.addItemCategory,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in _categories)
                      _CategoryChip(
                        key: ValueKey(category),
                        label: wardrobeCategoryLabel(l10n, category),
                        selected: state.category == category,
                        onTap: () => cubit.setCategory(category),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _Field(
                label: l10n.addItemPrice,
                optional: true,
                child: TextField(
                  onChanged: cubit.setPrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_price(l10n.localeName)],
                  textInputAction: TextInputAction.done,
                  style: _inputStyle,
                  decoration:
                      _input(
                        l10n.addItemPriceHint,
                        error: state.priceValid
                            ? null
                            : l10n.addItemPriceInvalid,
                      ).copyWith(
                        suffixText: l10n.currencySom,
                        suffixStyle: AppTypography.body,
                      ),
                ),
              ),
              const SizedBox(height: 28),
              if (state.failure case final failure?) ...[
                Text(
                  failure.message(l10n),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _AddButton(
                key: addItemSubmitKey,
                enabled: state.canSubmit,
                busy: state.submitting,
                onTap: () async {
                  final item = await cubit.submit();
                  if (item != null && context.mounted) {
                    Navigator.of(context).pop(item);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final _inputStyle = AppTypography.body.copyWith(
    color: AppColors.textPrimary,
  );

  static InputDecoration _input(String hint, {String? error}) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: color),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body,
      errorText: error,
      errorStyle: AppTypography.caption.copyWith(color: AppColors.accent),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: border(AppColors.inputBorder),
      focusedBorder: border(AppColors.outlineStrong),
      errorBorder: border(AppColors.accent),
      focusedErrorBorder: border(AppColors.accent),
    );
  }
}

/// A label ("Optional" on the right when it is) over its input.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.child,
    this.optional = false,
  });

  final String label;
  final bool optional;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.label)),
            if (optional)
              Text(
                context.l10n.addItemOptional,
                style: AppTypography.labelMuted,
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// A category to pick, as the item search's filter chips (cyan when picked).
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.chipSelected : AppColors.surfaceMuted,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          // As wide as the label, centred vertically.
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: selected ? AppColors.textPrimary : AppColors.textSubtle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "CTAButton": the brand gradient, dark text as the app's other gradient
/// buttons (Figma draws this one with white text).
class _AddButton extends StatelessWidget {
  const _AddButton({
    super.key,
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled || busy ? 1 : 0.5,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
            child: busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : Text(
                    context.l10n.addItemSubmit,
                    style: AppTypography.subheading,
                  ),
          ),
        ),
      ),
    );
  }
}
