import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/features/onboarding/data/datasources/style_quiz_local_data_source.dart';
import 'package:stylper/features/onboarding/domain/entities/style_quiz.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final items = const StyleQuizLocalDataSource().getItems();

  test('offers several tops and bottoms to flip through', () {
    final categories = items.map((item) => item.category);
    expect(categories.where((c) => c == OutfitCategory.top).length, 6);
    expect(categories.where((c) => c == OutfitCategory.bottom).length, 6);
    expect(items.map((item) => item.id).toSet(), hasLength(items.length));
  });

  test('every item image is bundled', () async {
    for (final item in items) {
      final data = await rootBundle.load(item.imagePath);
      expect(data.lengthInBytes, greaterThan(0), reason: item.imagePath);
    }
  });
}
