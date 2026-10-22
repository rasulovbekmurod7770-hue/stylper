import '../../../core/l10n/l10n.dart';
import '../domain/entities/wardrobe.dart';

/// The category's name in the user's language; unknown ids as sent.
String wardrobeCategoryLabel(AppLocalizations l10n, String category) =>
    switch (category) {
      WardrobeCategories.outerwear => l10n.wardrobeOuterwear,
      WardrobeCategories.tops => l10n.wardrobeTops,
      WardrobeCategories.bottoms => l10n.wardrobeBottoms,
      WardrobeCategories.shoes => l10n.wardrobeShoes,
      WardrobeCategories.accessories => l10n.wardrobeAccessories,
      _ => category,
    };
