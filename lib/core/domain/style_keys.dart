/// The styles posts are tagged with and Style DNA is made of. They are stored
/// and sent as these keys everywhere (the database rejects any other value,
/// migration 0003); screens show them through `styleLabel`.
abstract final class StyleKeys {
  static const minimal = 'minimal';
  static const casual = 'casual';
  static const streetwear = 'streetwear';
  static const neutral = 'neutral';
  static const oversized = 'oversized';
  static const smartCasual = 'smart_casual';

  static const all = [
    minimal,
    casual,
    streetwear,
    neutral,
    oversized,
    smartCasual,
  ];
}
