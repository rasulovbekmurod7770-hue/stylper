import '../domain/style_keys.dart';
import 'l10n.dart';

extension StyleLabels on AppLocalizations {
  /// The label of a `StyleKeys` key. [short] is for tight spots (Home's
  /// chips): "Street" for streetwear. An unknown key is shown as it is.
  String styleLabel(String key, {bool short = false}) => switch (key) {
    StyleKeys.minimal => styleMinimal,
    StyleKeys.casual => styleCasual,
    StyleKeys.streetwear => short ? styleStreetwearShort : styleStreetwear,
    StyleKeys.neutral => styleNeutral,
    StyleKeys.oversized => styleOversized,
    StyleKeys.smartCasual => styleSmartCasual,
    _ => key,
  };
}
