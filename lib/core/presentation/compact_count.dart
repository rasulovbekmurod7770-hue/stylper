/// Short counter label used on feed cards: `48`, `1.2k`, `3.4M`.
///
/// Truncates rather than rounds, so 1,299 likes never read as "1.3k".
String compactCount(int count) {
  if (count < 1000) return '$count';
  final (divisor, suffix) = count < 1000000 ? (1000, 'k') : (1000000, 'M');
  final tenths = count * 10 ~/ divisor;
  final (whole, decimal) = (tenths ~/ 10, tenths % 10);
  return whole >= 100 || decimal == 0
      ? '$whole$suffix'
      : '$whole.$decimal$suffix';
}
