import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/reader_category.dart';
import 'package:reader_app/core/constants/app_constants.dart';

void main() {
  group('ReaderCategory Model Tests', () {
    test('ReaderCategory getDefaultCategories returns 4 categories', () {
      final categories = ReaderCategory.getDefaultCategories();

      expect(categories.length, 4);
      expect(categories[0].id, 'A');
      expect(categories[1].id, 'B');
      expect(categories[2].id, 'C');
      expect(categories[3].id, 'D');
    });

    test('Category A has correct default values', () {
      final categories = ReaderCategory.getDefaultCategories();
      final categoryA = categories.firstWhere((c) => c.id == 'A');

      expect(categoryA.name, 'Category A');
      expect(categoryA.lineCount, AppConstants.categoryALines);
      expect(categoryA.paragraphCount, AppConstants.categoryAParagraphs);
      expect(categoryA.lineCount, 100);
      expect(categoryA.paragraphCount, 10);
    });

    test('Category B has correct default values', () {
      final categories = ReaderCategory.getDefaultCategories();
      final categoryB = categories.firstWhere((c) => c.id == 'B');

      expect(categoryB.name, 'Category B');
      expect(categoryB.lineCount, AppConstants.categoryBLines);
      expect(categoryB.paragraphCount, AppConstants.categoryBParagraphs);
      expect(categoryB.lineCount, 70);
      expect(categoryB.paragraphCount, 7);
    });

    test('Category C has correct default values', () {
      final categories = ReaderCategory.getDefaultCategories();
      final categoryC = categories.firstWhere((c) => c.id == 'C');

      expect(categoryC.name, 'Category C');
      expect(categoryC.lineCount, AppConstants.categoryCLines);
      expect(categoryC.paragraphCount, AppConstants.categoryCParagraphs);
      expect(categoryC.lineCount, 50);
      expect(categoryC.paragraphCount, 5);
    });

    test('Category D has correct default values', () {
      final categories = ReaderCategory.getDefaultCategories();
      final categoryD = categories.firstWhere((c) => c.id == 'D');

      expect(categoryD.name, 'Category D');
      expect(categoryD.lineCount, AppConstants.categoryDLines);
      expect(categoryD.paragraphCount, AppConstants.categoryDParagraphs);
      expect(categoryD.lineCount, 30);
      expect(categoryD.paragraphCount, 3);
    });

    test('ReaderCategory serializes to JSON correctly', () {
      final category = ReaderCategory(
        id: 'X',
        name: 'Custom Category',
        description: 'Test category',
        lineCount: 150,
        paragraphCount: 15,
      );

      final json = category.toJson();

      expect(json['id'], 'X');
      expect(json['name'], 'Custom Category');
      expect(json['description'], 'Test category');
      expect(json['lineCount'], 150);
      expect(json['paragraphCount'], 15);
    });

    test('ReaderCategory deserializes from JSON correctly', () {
      final json = {
        'id': 'Y',
        'name': 'Test Category',
        'description': 'A test category',
        'lineCount': 200,
        'paragraphCount': 20,
      };

      final category = ReaderCategory.fromJson(json);

      expect(category.id, 'Y');
      expect(category.name, 'Test Category');
      expect(category.description, 'A test category');
      expect(category.lineCount, 200);
      expect(category.paragraphCount, 20);
    });

    test('ReaderCategory uses default paragraphCount if missing in JSON', () {
      final json = {
        'id': 'Z',
        'name': 'Missing Paragraph Count',
        'description': 'Test',
        'lineCount': 100,
      };

      final category = ReaderCategory.fromJson(json);

      expect(category.paragraphCount, AppConstants.categoryAParagraphs);
    });

    test('ReaderCategory toJson and fromJson are inverse operations', () {
      final original = ReaderCategory(
        id: 'TEST',
        name: 'Round Trip',
        description: 'Testing serialization',
        lineCount: 85,
        paragraphCount: 8,
      );

      final json = original.toJson();
      final restored = ReaderCategory.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.lineCount, original.lineCount);
      expect(restored.paragraphCount, original.paragraphCount);
    });

    test('ReaderCategory lineCount and paragraphCount are mutable', () {
      final category = ReaderCategory(
        id: 'MUTABLE',
        name: 'Mutable Test',
        description: 'Test mutability',
        lineCount: 50,
        paragraphCount: 5,
      );

      expect(category.lineCount, 50);
      expect(category.paragraphCount, 5);

      category.lineCount = 75;
      category.paragraphCount = 7;

      expect(category.lineCount, 75);
      expect(category.paragraphCount, 7);
    });
  });
}
