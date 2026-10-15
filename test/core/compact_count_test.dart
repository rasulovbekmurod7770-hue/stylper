import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/presentation/compact_count.dart';

void main() {
  test('formats feed counters like the design', () {
    expect(compactCount(48), '48');
    expect(compactCount(999), '999');
    expect(compactCount(1000), '1k');
    expect(compactCount(1248), '1.2k');
    expect(compactCount(1299), '1.2k', reason: 'truncates, never rounds up');
    expect(compactCount(12500), '12.5k');
    expect(compactCount(999999), '999k');
    expect(compactCount(3400000), '3.4M');
  });
}
